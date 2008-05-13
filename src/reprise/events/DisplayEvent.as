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
	import flash.events.Event;
	 
	/**
	 * @author Till Schneidereit
	 */
	public class DisplayEvent extends Event
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const SHOW_COMPLETE : String = "showComplete";
		public static const HIDE_COMPLETE : String = "hideComplete";
		public static const VISIBLE_CHANGED : String = "visibleChanged";
		public static const REMOVE : String = 'displayRemove';
		public static const INTERACTION_COMPLETE : String = "interactionComplete";
		public static const TOOLTIPDATA_CHANGED : String = 'tooltipDataChanged';
		public static const LOAD_COMPLETE : String = 'loadComplete';
		public static const LOAD_FAIL : String = 'loadFail';
		public static const VALIDATION_COMPLETE : String = 'validationComplete';
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function DisplayEvent(type:String)
		{
			super(type);
		}
	}
}