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
		protected var _content : String;
		protected var _URL : String;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public function CSSSegment() {}
		
		
		public function content() : String
		{
			return _content;
		}
	
		public function setContent(val:String) : void
		{
			_content = val;
		}
		
		public function url() : String
		{
			return _URL;
		}
	
		public function setURL(val:String) : void
		{
			_URL = val;
		}
		
		
		public function toString() : String
		{
			return '[CSSSegment] url: ' + _URL + '\ncontent:\n' + _content;
		}
	}
}