/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.controls.html 
{
	import reprise.controls.AbstractButton;
	import reprise.events.LabelEvent;
	
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;		

	public class Anchor extends AbstractButton
	{
		//----------------------             Public Properties              ----------------------//
		public static var className : String = "a";
		
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var m_href : String;
		protected var m_target : String;

		
		//----------------------               Public Methods               ----------------------//
		public function Anchor() {}	
		
		public function setHrefAttribute(value : String) : void
		{
			m_href = value;
		}
		public function setTargetAttribute(value : String) : void
		{
			m_target = value;
		}
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function buttonDisplay_click(event : MouseEvent) : void
		{
			var htmlEvent : LabelEvent = new LabelEvent(LabelEvent.LINK_CLICK, true);
			htmlEvent.href = m_href;
			htmlEvent.linkTarget = m_target;
			dispatchEvent(htmlEvent);
			
			if (!htmlEvent.isDefaultPrevented())
			{
				var request:URLRequest = new URLRequest(htmlEvent.href);
				navigateToURL(request, htmlEvent.linkTarget || '_self');
			}
		}
	}
}