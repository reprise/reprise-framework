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

package reprise.controls.html { 
	import reprise.controls.AbstractButton;
	import reprise.utils.GfxUtil;
	import reprise.events.HTMLEvent;
	
	
	public class Anchor extends AbstractButton
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var className : String = "a";
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_elementType : String = className;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function Anchor() {}	
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function createButtonDisplay() : void {}
	
		
		protected function buttonDisplay_click() : void
		{
			var event : HTMLEvent = new HTMLEvent(HTMLEvent.ANCHOR_CLICK, this);
			dispatchEvent(event);
		}
	}
}