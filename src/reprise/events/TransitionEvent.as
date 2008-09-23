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
	 * @author till
	 */
	public class TransitionEvent extends Event 
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const TRANSITION_COMPLETE : String = 'transitionComplete';
		public static const ALL_TRANSITIONS_COMPLETE : String = 'allTransitionComplete';
		public static const TRANSITION_CANCEL : String = 'transitionCancel';
		
		/**
		 * Returns the name of the property whose transition has ended.
		 * 
		 * Note that this property is not defined for events of type 
		 * ALL_TRANSITIONS_COMPLETE
		 */
		public function get propertyName() : String
		{
			return m_propertyName;
		}
		/**
		 * Returns the elapsed amount of time, in seconds.
		 * 
		 * Note that this property is not defined for events of type 
		 * ALL_TRANSITIONS_COMPLETE
		 */
		public function get elapsedTime() : Number
		{
			return m_elapsedTime;
		}
		public function set propertyName(name : String) : void
		{
			m_propertyName = name;
		}
		public function set elapsedTime(time : Number) : void
		{
			m_elapsedTime = time;
		}

		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_propertyName : String;
		protected var m_elapsedTime : Number;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function TransitionEvent(type : String)
		{
			super(type, true, false);
		}
		
		public override function toString() : String
		{
			var str : String = 'TransitionEvent.' + type;
			if (type == TRANSITION_COMPLETE || type == TRANSITION_CANCEL)
			{
				str += ', propertyName = ' + m_propertyName + 
					', elapsedTime = ' + m_elapsedTime;
			}
			return str;
		}
	}
}
