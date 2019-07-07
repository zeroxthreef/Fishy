#include "../Util.pmod"

//_must_ have at least 1 argument for the test
string respond(FishyTagData tagData)
{
	string ret = "";

	if((int)tagData.arguments[0])
		for(int i = 1; i < sizeof(tagData.arguments); i++)
		{
			ret += (string)tagData.arguments[i];
		}

	return ret;
}