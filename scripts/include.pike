//TODO use the compilation handler and make it handle importing utils and stuff
//import Util;
#include "../Util.pmod"
//it would be a bad idea to remove this script. Includes files

//TODO talk to the caching system through this

string respond(FishyTagData tagData)
{
	string file = Stdio.read_file(tagData.callerFileParent + "/" + tagData.arguments[0]);

	if(file == UNDEFINED)
		return "file not found";
	else
		return file;
}