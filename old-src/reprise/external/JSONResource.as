/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.external
{ 
	import com.cinqetdemi.JSON;
	
	public class JSONResource extends URLLoaderResource
	{
		public function JSONResource(url:String)
		{
			super(url);
		}

		public function setRequestJSON(json : Object) : void
		{
			setRequestData(JSON.stringify(json));
		}
		
		public override function content() : *
		{
			if (!_data)
			{
				return {};
			}
			return JSON.parse(_data);
		}
	}
}