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

package reprise.events
{ 
	import reprise.ui.UIObject;
	
	import flash.events.Event;
	
	public class FocusEvent extends Event
	{
		public static const FOCUS_IN : String = 'focusIn';
		public static const FOCUS_OUT : String = 'focusOut';
		
		public var timestamp : Number;	
		public var relatedObject : UIObject;
		public var shiftKey : Boolean;
		public var keyCode : Number;
		
		
		public function FocusEvent(type : String, 
			bubbles : Boolean, cancelable : Boolean = true, 
			relatedObject : UIObject = null, 
			shiftKey : Boolean = false, keyCode : uint = 0)
		{
			super(type, bubbles, cancelable);
	
			this.relatedObject = relatedObject;
			this.shiftKey = shiftKey;
			this.keyCode = keyCode;
		}
		
		public override function clone() : Event
		{
			var focusEvent : FocusEvent = super.clone() as FocusEvent;
			focusEvent.timestamp = timestamp;
			focusEvent.relatedObject = relatedObject;
			focusEvent.shiftKey = shiftKey;
			focusEvent.keyCode = keyCode;
			
			return focusEvent;
		}
	}
}