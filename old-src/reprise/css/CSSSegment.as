/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css
{ 
	internal class CSSSegment
	{	
		//----------------------       Private / Protected Properties       ----------------------//
		protected var m_content : String;
		protected var m_URL : String;
		
		
		
		//----------------------               Public Methods               ----------------------//
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