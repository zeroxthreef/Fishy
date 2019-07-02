

mixed FindMapping(mapping map, string key)
{
	foreach(map; string k; mixed val)
	{
		if(k == key)
			return val;
	}

	return UNDEFINED;
}

mixed FindMappingBeginning(mapping map, string key)
{
	foreach(map; string k; mixed val)
	{
		if(strlen(k) <= strlen(key))
		{
			if(k == key[..strlen(k) - 1])
				return val;
		}
		
	}

	return UNDEFINED;
}

string DetermineSiteName(Protocols.HTTP.Server.Request request)
{
	string ret = request->request_headers->host;
	array parts = ret / ":";
	ret = parts[0];
	
	return ret;
}

//gets the final host, if it exists, or returns the default
string DetermineSiteRoute(string siteName, mapping globals, mapping conf)
{
	string site = FindMapping(globals->sites, siteName);

	if(site == UNDEFINED)
	{
		//test if prepending the default subdomain to the front makes it work
		//conf->defaults->default_subdomain + "." + siteName

		
		if(strlen(siteName) >= strlen("www."))
			if(siteName[..strlen("www")] == "www.")
				site = FindMapping(globals->sites, siteName[strlen("www") + 1..]);

		if(site != UNDEFINED)
			return siteName[strlen("www") + 1..];


		return conf->defaults->default_domain;
	}
	else
		return siteName;
}