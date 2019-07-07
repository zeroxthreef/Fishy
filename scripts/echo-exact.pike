#include "../Util.pmod"

string respond(FishyTagData tagData)
{
	string ret = "";

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