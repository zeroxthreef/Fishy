import .Util;

//recursively parse tags

//template format is [@operation (optional)argument ...]
//can be unparsed if prefixed with another [ like: [[@operation (optional)argument ...]
//if the tag is, for example, [@include thingo.md], it will include a file into the current place
string TemplateParse(mapping globals, mapping config, mapping locals, string input, string file, Protocols.HTTP.Server.Request request)
{
	int pos = 0, instring = 0;
	string finalString = input, temp, temp_before, tag = UNDEFINED;
	//TODO replace "[[" with the html escape for "["
	//look for the next tag, run it, then try parsing again for recursion


	//NOTE just tokenize AFTER replacing all [[

	while((pos = search(finalString, "[@")) != -1)
	{
write("status: %s\n", finalString);
		//test if the tag has not been escaped
		if(finalString[pos - 1..pos] != "[[")
		{
			// /write("caught %s\n", finalString[pos..]);
			
			for(int i = 0; i < strlen(finalString[pos..]); i++)
			{
				temp_before = i ? finalString[pos + i - 1..pos + i - 1] : finalString[pos + i..pos + i];
				temp = finalString[pos + i..pos + i];

				if(temp == "\"" && temp_before != "\\")
				{
					if(!instring)
						instring = 1;
					else
						instring = 0;
				}
				else if(temp == "]" && !instring)
				{
					tag = finalString[pos..pos + i];
					break;
				}
			}

			mapping replacement = TemplateCommandParse(tag);

			finalString = replace(finalString, tag, TemplateExecute(file, replacement, globals, locals, config, request));

			if(globals->statuses->full_fault)
			{
				write("template encountered irrecoverable fault\n");
				return UNDEFINED;
			}
		}
		else //turn the tag left side into an html escape
		{
			temp = finalString[..pos - 2];
			finalString = temp + "&#91;" + finalString[pos + 1..];
		}
		
	}

	//if(replaced) //TODO TODO TODO DONT DO RECURSION, JUST MAKE THE LOOP TEST FOR IT
		//finalString = TemplateParse(globals, config, locals, finalString, request);
	
	return finalString;
}

mapping TemplateCommandParse(string tag)
{
	mapping ret = (["script" : "", "arguments" : ({}) ]);
	string temp = String.normalize_space(tag);
	int start;

	//parse the commands only if the tag actually has arguments
	if((start = search(temp, " ")) != -1)
	{
		ret->script = tag[strlen("[@")..start - 1];

		ret->arguments = Process.split_quoted_string(tag[strlen("[@") + strlen(ret->script)..strlen(tag) - 2]);
	}
	else
	{
		//still have to extract the script name
		ret->script = tag[strlen("[@")..strlen(tag) - 2];
	}

	return ret;
}

//TODO pass the scripts current parent folder and call script
string TemplateExecute(string file, mapping tag, mapping globals, mapping locals, mapping config, Protocols.HTTP.Server.Request request)
{
	object script;
	mapping site;

	//first look through the local scripts cause the global ones should be able to be overridden

	site = FindMapping(globals->sites, DetermineSiteRoute(DetermineSiteName(request), globals, config));


	script = FindMapping(site->scripts, tag->script);

	if(script == UNDEFINED)
		script = FindMapping(globals->scripts, tag->script);
	else
	{
		mixed err = catch
		{
			//dont pass the globals to the site specific functions just in case
			return script.respond(FishyTagData(UNDEFINED, globals->statuses, locals, config, tag->arguments, request, file));
		};
		if(err)
		{
			write("error running template script. Check log for details\n");
			write("%s\n", err[0]);
			return "TEMPLATE ERROR: \"" + tag->script + "\" ENCOUNTERED AN ERROR";
		}
	}
		


	if(script == UNDEFINED)
		return "TEMPLATE ERROR: \"" + tag->script + "\" NOT FOUND";
	else
	{
		mixed err = catch
		{
			return script.respond(FishyTagData(globals, globals->statuses, locals, config, tag->arguments, request, file));
		};
		if(err)
		{
			write("error running template script. Check log for details\n");
			write("%s\n", err[0]);
			return "TEMPLATE ERROR: \"" + tag->script + "\" ENCOUNTERED AN ERROR";
		}
	}
}