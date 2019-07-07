#include "../Util.pmod"

//_must_ have at least 1 argument for the test
string respond(FishyTagData tagData)
{
	string ret = "";

	if((int)tagData.arguments[0])
		for(int i = 1; i < sizeof(tagData.arguments); i++)
		{
			if(search(tagData.arguments[i], " ") != -1)
				ret += "\"";

			ret += (string)tagData.arguments[i];

			if(search(tagData.arguments[i], " ") != -1)
				ret += "\"";
			
			ret += (i != sizeof(tagData.arguments) - 1 ? " " : "");
		}

	return ret;
}