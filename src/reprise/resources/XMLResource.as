/*
* Copyright (c) 2006-2011 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.resources
{
	import flash.net.URLRequestMethod;

	public class XMLResource extends URLLoaderResource
	{
		//----------------------               Public Methods               ----------------------//
		public function XMLResource(url:String) 
		{
			super(url);
			requestContentType = 'text/xml; charset=utf-8';
			requestMethod = URLRequestMethod.POST;
		}
		
		public function set requestXML(xml : XML) : void
		{
			requestData = xml.toXMLString();
		}

		public override function content() : *
		{
			return new XML(_data);
		}
	}
}