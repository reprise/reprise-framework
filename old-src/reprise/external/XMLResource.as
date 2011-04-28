/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.external
{
	import flash.net.URLRequestMethod;

	public class XMLResource extends URLLoaderResource
	{
		//----------------------               Public Methods               ----------------------//
		public function XMLResource(url:String) 
		{
			super(url);
			setRequestContentType('text/xml; charset=utf-8');
			setRequestMethod(URLRequestMethod.POST);
		}
		
		public function setRequestXML(xml : XML) : void
		{
			setRequestData(xml.toXMLString());
		}

		public override function content() : *
		{
			return new XML(m_data.split("\r\n").join("\n"));
		}
	}
}