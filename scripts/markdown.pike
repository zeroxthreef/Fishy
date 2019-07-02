import Tools.Markdown; //need pike 8.1 _or_ just copy Tools.pmod/Markdown.pmod from the pike repo into your usr/local modules

string respond(mapping globals, mapping config, array arguments, Protocols.HTTP.Server.Request request)
{
	return parse(arguments[0], (["gfm":true, "tables":true, "breaks":true, "sanitize":false, "smartypants":true, "newline":true]));
}