mapping GetConfig(string config_file)
{
	string current_container = "", config = Stdio.read_file(config_file);
	string last_identifier = "", setting, data;
	mapping config_map = ([]);
	
	if(!config)
		error("no config file\n");
	
	// filter tabs
	config = replace(config, "\t", "");
	
	array(string) lines = config / "\n";
	
	foreach(lines, string line)
	{
		if(line[0..0] == "#" || strlen(line) == 0)
			continue;
		
		if(line == "{")
		{
			current_container = last_identifier;
			config_map += ([current_container:([])]);
		}
		else if(line == "}")
			current_container = "";
		else
			last_identifier = line;	
		
		if(search(line, "=") && strlen(current_container))
		{
			setting = line[0..search(line, "=") - 2];
			data = line[search(line, "=") + 2..];
			
			//TODO: add more filtering
			data = replace(data, "\\t", "\t");
			data = replace(data, "\\n", "\n");
			data = replace(data, "\\\\", "\\");
			
			// add to mapping
			if(strlen(setting))
				config_map[current_container] += ([setting:data]);
		}
		
	}

	return config_map;
}