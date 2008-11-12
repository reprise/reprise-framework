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

package reprise.controls.html 
{
	import reprise.controls.AbstractButton;
	import reprise.events.LabelEvent;
	
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;		

	public class Anchor extends AbstractButton
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var className : String = "a";
		
		
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		protected var m_href : String;
		protected var m_target : String;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function Anchor() {}	
		
		public function setHrefAttribute(value : String) : void
		{
			m_href = value;
		}
		public function setTargetAttribute(value : String) : void
		{
			m_target = value;
		}
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function buttonDisplay_click(event : MouseEvent) : void
		{
			var htmlEvent : LabelEvent = new LabelEvent(LabelEvent.LINK_CLICK);
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