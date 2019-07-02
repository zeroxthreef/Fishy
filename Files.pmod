//TODO actually cache the entire directory structure of directories. Monitor the entirity for changes aswell
//TODO also cache all error pages
import Cache;

class CacheFilesystem
{
	private int cacheStorage; //TODO make this use the cache module

	void create(int cache)
	{

	}

	//TODO make a request formatter in here. Use Stdio.append_path() and make sure it doesnt go below any paths OR Stdio.simplify_path()

	//used to get the "final" path for requests, like looking for an index/file. Will only return an index if it finds an index.ext or there is a file
	//input path needs to be formatted like pages/dname.tld/resource.txt
	//or pages/dname.tld/resource (resource could be a file with no ext or a dir) just not no trailing fslash
	string GetFullPathIndex(string path)
	{
		
	}

	int FileExists(string path)
	{
		return Stdio.exist(path); //TODO make this use the structure cache instead
	}

	//returns 0 if does not exist, 1 if file, and 2 if directory
	int IsDirFile(string path)
	{
		if(Stdio.is_dir(path))
			return 2;
		if(!FileExists(path))
			return 0;
		if(Stdio.is_file(path))
			return 1;
	}

	string GetFile(string path)
	{
		if(IsDirFile(path) == 1)
			return Stdio.read_file(path);
		else
			return 0;
	}
}