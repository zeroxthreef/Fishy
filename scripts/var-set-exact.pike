#include "../Util.pmod"

string respond(FishyTagData tagData)
{
	string set = "";

	for(int i = 1; i < sizeof(tagData.arguments); i++)
	{
		if(search(tagData.arguments[i], " ") != -1)
			set += "\"";

		set += (string)tagData.arguments[i];

		if(search(tagData.arguments[i], " ") != -1)
			set += "\"";
		
		set += (i != sizeof(tagData.arguments) - 1 ? " " : "");
	}

	tagData.locals->locals += ([(string)tagData.arguments[0] : set]);

	return "";
}