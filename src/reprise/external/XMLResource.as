/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.external
{
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	 
	public class XMLResource extends FileResource
	{
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		protected var m_requestXML : XML;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function XMLResource(url:String) 
		{
			setRequestContentType('text/xml; charset=utf-8');
			m_requestMethod = URLRequestMethod.POST;
			super(url);
		}
		
		public function setRequestXML(xml : XML) : void
		{
			m_requestXML = xml;
		}

		public override function content() : *
		{
			var xml:XML = new XML(m_data.split("\r\n").join("\n"));
			return xml;
		}
		
		
		/***************************************************************************
		*							protected methods							   *
		***************************************************************************/
		protected override function createRequest() : URLRequest
		{
			var request : URLRequest = super.createRequest();
			if (m_requestXML)
			{
				request.data = m_requestXML.toXMLString();
			}
			return request;
		}
	}
}