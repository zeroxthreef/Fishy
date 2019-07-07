#include "../../../../Util.pmod"


string respond(FishyTagData tagData)
{
	//able to force the server to display the default error template
	//tagData.SetFault();
	return tagData.locals->locals->message;
}