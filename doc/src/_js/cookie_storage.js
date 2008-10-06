var Storage = new Class(
{
	initialize:function(cookieName)
	{
		this.cookieName = cookieName;
		var cookieContent = Cookie.read(this.cookieName);
		this.m_options = cookieContent 
			? JSON.decode(unescape(cookieContent))
			: {hideInheritedFields:false, hideProtectedFields:false, expandedPackages:[]};
	},
	
	valueForKey:function(key)
	{
		return this.m_options[key];
	},
	
	setValueForKey:function(value, key)
	{
		this.m_options[key] = value;
		this.save();
	},
	
	save:function()
	{
		Cookie.write(this.cookieName, escape(JSON.encode(this.m_options)), {duration:365});
	}
});