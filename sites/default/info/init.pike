//NOTE, everything necessary for domain and subdomain specific scripts is in here. This dir
//is not visible to http clients

//all subdomains have an init script that runs when everything starts up

//if you need to start threads to manage things further in the future, do so here


int init(mapping config, mapping locals)
{
	locals->locals += (["message":"hello, this was set from the site init"]);
	return 0;
}