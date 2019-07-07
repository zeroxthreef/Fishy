#!/usr/bin/env pike

/* NOTE: files in pages have to be structured as

dname.tld/subdomain

ALSO NOTE
catchalls are the www subdomain if another doesnt exist OR unspecified

entire site catchalls are in "default". THis folder is right in the root of pages
*/

/* notes on the globals mapping:

	the root of the mapping is laid out like this:
	scripts -> the global template scripts
	statuses -> various variables that are useful for retrieving the servers state
		sent_data
	sites -> all sites
		example_site
			scripts -> the template scripts local to only this site
			locals -> the interior mapping passed to all tags that are local to this


 */

import .Util;
import .Config;
import .Parser;
import Protocols.HTTP.Server;

mapping conf;
mapping (string:mixed)globals = ([]); //globals could be socket connections to things to allow reuse and all that
//DO NOTE THAT ALL SITES SHARE THE GLOBALS MAPPING

int main(int argc, array(string) argv)
{
	Port server;

	write("starting fishy\n");
	//init server
	if(init())
	{
		write("error initializing\n");
		return 1;
	}

	write("listening for connections\n");
	// begin the server callback
	server = Port(route, (int)conf->global->port);

	return -1; //took a while to figure out, but as a tip, -1 puts pike into an event listening mode
}

int init()
{
	//setup the config
	if(!Stdio.exist("fishy.conf"))
		Stdio.cp("fishy_defaults.conf", "fishy.conf");
	conf = GetConfig("fishy.conf");

	if((int)conf->ranges->enabled == 1)
	{
		write("ranges enabled\n");
		conf->headers += (["accept-ranges" : "bytes"]);
	}
	else
		conf->headers += (["accept-ranges" : "none"]);

	//setup the global mapping
	globals += (["scripts":([]), "statuses":([]) ]);

	//setup the statuses
	globals->statuses += (["sent_data":0]);

	//init all site scripts, template scripts, and global template scripts
	array(string) scriptNames = get_dir(conf->global->scripts);
	for(int i = 0; i < sizeof(scriptNames); i++)
	{
		write("compiling %s\n", scriptNames[i]);
		mixed err = catch
		{
			program script = compile_file(conf->global->scripts + "/" + scriptNames[i]);
			globals->scripts += ([(scriptNames[i])[..sizeof(scriptNames[i]) - (sizeof(".pike") + 1)] : script()]);
		};
		if(err)
		{
			write("error initializing template script %s. Check log for full details\n", scriptNames[i]);
			write("%s\n", err[0]);
		}
	}
	//globals->scripts->include.thing();
	//foreach( string file;)
		//write("hdey %s\n", file);
	
	//setup the sites mapping
	globals += (["sites":([])]);

	if(InitSites(conf->global->documents, conf->global->documents))
	{
		write("could not init all sites\n");
		return 1;
	}

	//write("globals %O\nconf %O\n", globals, conf);
	write("finished initializing everything\n");
	return 0;
}

void route(Request req)
{
	write("%s:%s\n", req->request_type, ParsePath(Protocols.HTTP.uri_decode(req->not_query)));
	mapping res = ([]); //data, file, error, length, modified, type, extra_heads, server
	//route to index.ext or directory OR index.ext
	//TODO make an in-memory representation of files that already exist. Also make a separate one for the actual file caches

	//determine the actual path

	//determine if we're accessing a virtual path or disk path
	mapping siteData = FindMapping(globals->sites, DetermineSiteRoute(DetermineSiteName(req), globals, conf));
	string filePath;
	
	filePath = FinalizePath(DetermineSiteRoute(DetermineSiteName(req), globals, conf), FindMappingBeginning(siteData->config->virtual_paths, ParsePath(Protocols.HTTP.uri_decode(req->not_query))), conf);


	//if its undefined, that means that the path requested wasnt in the virtual paths
	if(filePath == UNDEFINED)
		filePath = FinalizePath(DetermineSiteRoute(DetermineSiteName(req), globals, conf), ParsePath(Protocols.HTTP.uri_decode(req->not_query)), conf);

	//pike doesnt seem to have short circuiting in the if statements so this is a workaround
	if(filePath == UNDEFINED)
	{
		//also set the status code
		filePath = conf->global->error_templates + "/" + conf->global->catchall_error;
	}
	
	if(!Stdio.exist(filePath))
	{
		//also set the status code
		filePath = conf->global->error_templates + "/" + conf->global->catchall_error;
	}

	// _only_ respond with a string buffer if it is an fsh file. Use mmap'ed files for everything else
	if(DetermineExtension(filePath) == "fsh") //respond with the fsh file
	{
		res->data = TemplateParse(globals, conf, globals->sites->default, Stdio.read_file(filePath), filePath, req);
	}
	else
	{
		res->file = Stdio.File(filePath);
	}
	/*else if(!req->request_headers->range) //respond with the plain file, cached or uncached
	{
		//test if the file is to large to be sent in ram from the cache

		//TODO override this when ranges asked for
		if(Stdio.file_size(filePath) > (int)conf->cache->max_individual)
			res->file = Stdio.File(filePath);
		else
			res->data = Stdio.read_file(filePath);
	}

	//this is the final check. Placed in its own statement just in case if the client asks for
	//the range in a fsh file

	if(req->request_headers->range)
	{
		int fileSize = DetermineExtension(filePath) == "fsh" ? strlen(res->data) : Stdio.file_size(filePath);
		array(array) ranges = PaseRanges(req->request_headers->range, fileSize);

		//test if it should do content range or multipart/byteranges
		if(ranges == UNDEFINED)
		{
			res->data = UNDEFINED;
			res->error = 416;
		}
		else if(sizeof(ranges) == 1) //content range
		{
			res->error = 206;
			res->extra_heads = (["content-range" : "bytes " + ranges[0][0] + "-" + (ranges[0][0] + ranges[0][1]) + "/" + fileSize]);
			//super hacky, but I have to get the internal ranges to stop overwriting this because its broken
			res->start = 1;

			if(DetermineExtension(filePath) != "fsh")
				res->data = Stdio.read_bytes(filePath, ranges[0][0], ranges[0][1]);
			else
				res->data = res->data[ranges[0][0]..ranges[0][0] + ranges[0][1]];
			
		}
		else //multipart
		{

		}
	}
		
	*/

	//manage response headers
	if(conf->headers->server)
		res->server = conf->headers->server;
	
	foreach(conf->headers; string header; mixed data)
	{
		if(header != "server")
			res->extra_heads += ([header:data]);
	}
	
	res->type = DetermineMime(filePath);



	if(!res->error)
		res->error = 200;

	req->response_and_finish(res);

	//globals->statuses->sent_data = req->sent_data();
}

string ParsePath(string uri)
{
	string temp = uri;
	array(string) tempTok;

	//disallow backsashes
	temp = replace(temp, "\\", "");

	//filter for directory traversal
	temp = replace(temp, "../", "");
	temp = replace(temp, "../", "");
	temp = replace(temp, "~/", "");

	//TODO get rid of lots of slashes
	tempTok = temp / "/";
	temp = "";
	
	for(int i = 0; i < sizeof(tempTok); i++)
	{
		if(strlen(tempTok[i]))
			temp += "/" + tempTok[i];
	}

	return temp;
}

string FinalizePath(string site, string path, mapping config)
{
	string root = config->global->documents + "/" + site + "/" + config->defaults->default_htdocs;

	if(path == UNDEFINED)
		return UNDEFINED;

	//test for indexes
	//should access the cache file test func but also check for other things when testing for indexes

	//first, determine if the "file" is a directory or not
	if(Stdio.is_dir(root + path))
	{
		foreach(conf->indexes; string key; string value)
		{
			if(Stdio.is_file(root + path + "/" + value))
				return root + path + "/" + value;
		}

		//if theres no index, we have to reply with an error
	}
	else
		return root + path;
}

string DetermineMime(string path)
{
	string type = FindMapping(conf->mime, DetermineExtension(path));

	if(type == UNDEFINED)
		return conf->mime->_;
	else
		return type;
}

int InitSites(string path, string aboveDir)
{
	array(string) files = get_dir(path);

	for(int i = 0; i < sizeof(files); i++)
	{
		string file = files[i];

		//write("yeah %s/%s\n", path, (string)file);
		if(Stdio.is_dir(path + "/" + file))
		{
			if(aboveDir == conf->global->documents)
				globals->sites += ([file : (["scripts" : ([]), "locals" : ([]), "config" : ([]) ]) ]);
			if(InitSites(path + "/" + file, file))
				return 1;
		}
		else if(Stdio.is_file(path + "/" + file))
		{
			if(file == "init.pike" && aboveDir == conf->defaults->default_data)
			{
				string site = replace(replace(replace(path, conf->global->documents, ""), conf->defaults->default_data, ""), "/", "");
				write("initializing site %s\n", site );
				
				//init(mapping globals, mapping config, mapping locals)

				mapping siteMapping = FindMapping(globals->sites, site);

				mixed err = catch
				{
					program script = compile_file(path + "/" + file);
					object prog = script();

					if(prog.init(conf, siteMapping))
						return 1;
				};
				if(err)
				{
					write("error initializing site init script for %s. Check log for full details\n", site);
					write("%s\n", err[0]);
				}
			}
			else if(file == conf->defaults->default_config && aboveDir == conf->defaults->default_data)
			{
				string site = replace(replace(replace(path, conf->global->documents, ""), conf->defaults->default_data, ""), "/", "");
				mapping siteMapping = FindMapping(globals->sites, site);
				siteMapping->config = GetConfig(path + "/" + file);
			}
			else if(aboveDir == conf->global->scripts)
			{
				write("compiling local script %s\n", file);
				string site = replace(replace(replace(replace(path, conf->global->documents, ""), conf->defaults->default_data, ""), "/", ""), conf->global->scripts, "");
				
				mixed err = catch
				{
					program script = compile_file(path + "/" + file);
					mapping siteMapping = FindMapping(globals->sites, site);
					siteMapping->scripts += ([(file)[..sizeof(file) - (sizeof(".pike") + 1)] : script()]);
				};
				if(err)
				{
					write("error initializing local template script %s. Check log for full details\n", site);
					write("%s\n", err[0]);
				}
			}
		}
	}
	return 0;
}

array(array) PaseRanges(string rangeData, int fileSize)
{
	array parts = rangeData / "=";
	array(array) ret = ({});

	if(sizeof(parts) != 2)
		return UNDEFINED;
	
	
	if(parts[0] != "bytes")
		return UNDEFINED;

	parts = parts[1] / ", ";

	//work through all of the ranges

	foreach(parts, string range)
	{
		int begin, length;

		if(range[0..0] == "-" || range[strlen(range) - 1..] == "-") //wants range from/till
		{
			if(range[0..0] == "-") //wants end bytes
			{
				begin = fileSize - (int)range[1..];
				length = fileSize - begin;
			}
			else //wants bytes from a certain point to end
			{
				begin = (int)range;
				length = fileSize - begin;
			}
		}
		else if(sizeof((range / "-")) == 2) //wants range between
		{
			array bounds = range / "-";

			//make sure the bounds arent outside the files actual size

			begin = (int)bounds[0];
			length = (int)bounds[1];

			if(begin > length)
				continue;
			
			length = length - begin;

			if(begin > fileSize)
				continue;

		}
		else //invalid range format
			return UNDEFINED;

		ret += ({({begin, length})});
	}

	return ret;
}