#include "../Util.pmod"

string respond(FishyTagData tagData)
{
	return (string)tagData.globals->statuses->current_error;
}