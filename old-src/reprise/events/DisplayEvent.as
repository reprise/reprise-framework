/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.events
{
	import flash.events.Event;
	 
	/**
	 * @author Till Schneidereit
	 */
	public class DisplayEvent extends Event
	{
		//----------------------             Public Properties              ----------------------//
		public static const ADDED_TO_DOCUMENT : String = 'addedToDocument';
		public static const REMOVED_FROM_DOCUMENT : String = 'removedFromDocument';
		
		public static const SHOW_COMPLETE : String = "showComplete";
		public static const HIDE_COMPLETE : String = "hideComplete";
		public static const VISIBLE_CHANGED : String = "visibleChanged";
		public static const REMOVE : String = 'displayRemove';
		public static const INTERACTION_COMPLETE : String = "interactionComplete";
		public static const TOOLTIPDATA_CHANGED : String = 'tooltipDataChanged';
		public static const LOAD_COMPLETE : String = 'loadComplete';
		public static const LOAD_FAIL : String = 'loadFail';
		public static const VALIDATION_COMPLETE : String = 'validationComplete';
		public static const DOCUMENT_VALIDATION_COMPLETE : String = 
			'documentValidationComplete';

		
		//----------------------               Public Methods               ----------------------//
		public function DisplayEvent(type:String, 
			bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}