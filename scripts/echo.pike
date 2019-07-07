#include "../Util.pmod"

string respond(FishyTagData tagData)
{
	string ret = "";

	for(int i = 0; i < sizeof(tagData.arguments); i++)
	{
		ret += (string)tagData.arguments[i];
	}

	return ret;
}