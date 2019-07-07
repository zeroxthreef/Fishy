

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

string DetermineExtension(string path)
{
	array parts = path / ".";

	if(sizeof(parts) == 1)
		return UNDEFINED;
	
	if(parts[sizeof(parts) - 1] == "")
		return UNDEFINED;
	else
		return parts[sizeof(parts) - 1];
}

string DetermineFile(string path)
{
	array parts = path / "/";

	if(sizeof(parts) == 1)
		return UNDEFINED;

	return parts[sizeof(parts) - 1];
}

// set the globals to UNDEFINED if its a local tag
class FishyTagData
{
	public mapping globals;
	public mapping status;
	public mapping locals;
	public mapping config;
	public array arguments;
	public Protocols.HTTP.Server.Request request;
	public string callerFile;
	public string callerFileParent;

	void create(mapping globals, mapping status, mapping locals, mapping config, array arguments, Protocols.HTTP.Server.Request request, string callerFile)
	{
		this->globals = globals;
		this->status = status;
		this->locals = locals;
		this->config = config;
		this->arguments = arguments;
		this->request = request;
		this->callerFile = callerFile;
		this->callerFileParent = replace(callerFile, "/" + DetermineFile(callerFile), "");
	}

	void SetError(int value)
	{
		status->current_error = value;
	}

	void SetFault()
	{
		status->full_fault = true;
	}

};