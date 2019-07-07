#include "../Util.pmod"

//TODO make a mathf for floats
//depending on the operation, it can expect anywhere from 2 - 3 arguments

string respond(FishyTagData tagData)
{
	int ret;

	switch(tagData.arguments[0])
	{
		case "+":
			ret = ((int)tagData.arguments[1] + (int)tagData.arguments[2]);
		break;
		case "-":
			ret = ((int)tagData.arguments[1] - (int)tagData.arguments[2]);
		break;
		case "*":
			ret = ((int)tagData.arguments[1] * (int)tagData.arguments[2]);
		break;
		case "/":
			ret = ((int)tagData.arguments[1] / (int)tagData.arguments[2]);
		break;
		case "%":
			ret = ((int)tagData.arguments[1] % (int)tagData.arguments[2]);
		break;
		//TODO trig functions
	}

	return (string)ret;
}