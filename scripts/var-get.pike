#include "../Util.pmod"

string respond(FishyTagData tagData)
{
	string ret = FindMapping(tagData.locals->locals, tagData.arguments[0]);

	return ret != UNDEFINED ? ret : "";
}