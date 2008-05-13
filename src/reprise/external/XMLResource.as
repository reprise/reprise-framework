////////////////////////////////////////////////////////////////////////////////
//
//  Fork unstable media GmbH
//  Copyright 2006-2008 Fork unstable media GmbH
//  All Rights Reserved.
//
//  NOTICE: Fork unstable media permits you to use, modify, and distribute this
//  file in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package reprise.external
{ 
	import flash.xml.XMLDocument;
	public class XMLResource extends FileResource
	{
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function XMLResource(url:String) 
		{
			super(url);
		}
		
		public override function content() : *
		{
			var xml:XML = new XML(m_data.split("\r\n").join("\n"));
			return xml;
		}
	}
}