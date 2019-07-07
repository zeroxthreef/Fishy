#include "../Util.pmod"

string respond(FishyTagData tagData)
{
	tagData.locals->locals += ([(string)tagData.arguments[0] : tagData.arguments[1]]);

	return "";
}