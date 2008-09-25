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

package reprise.css
{ 
	internal class CSSSegment
	{	
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_content : String;
		protected var m_URL : String;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSSSegment() {}
		
		
		public function content() : String
		{
			return m_content;
		}
	
		public function setContent(val:String) : void
		{
			m_content = val;
		}
		
		public function url() : String
		{
			return m_URL;
		}
	
		public function setURL(val:String) : void
		{
			m_URL = val;
		}
		
		
		public function toString() : String
		{
			return '[CSSSegment] url: ' + m_URL + '\ncontent:\n' + m_content;
		}
	}
}