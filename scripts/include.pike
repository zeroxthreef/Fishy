#include "../Util.pmod"
//it would be a bad idea to remove this script. Includes files

//TODO talk to the caching system through this

string respond(mapping globals, mapping config, array arguments, Protocols.HTTP.Server.Request request)
{
	string file = Stdio.read_file(config->global->documents + "/" + DetermineSiteRoute(DetermineSiteName(request), globals, config) + "/" + config->defaults->default_htdocs + "/" + arguments[0]);

	if(file == UNDEFINED)
		return "file not found";
	else
		return file;
}