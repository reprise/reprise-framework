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
	 * @author till
	 */
	public class TransitionEvent extends Event 
	{
		//----------------------             Public Properties              ----------------------//
		public static const TRANSITION_START : String = 'transitionStart';
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
			return _propertyName;
		}
		/**
		 * Returns the elapsed amount of time, in seconds.
		 * 
		 * Note that this property is not defined for events of type 
		 * ALL_TRANSITIONS_COMPLETE
		 */
		public function get elapsedTime() : int
		{
			return _elapsedTime;
		}
		public function set propertyName(name : String) : void
		{
			_propertyName = name;
		}
		public function set elapsedTime(time : int) : void
		{
			_elapsedTime = time;
		}

		//----------------------       Private / Protected Properties       ----------------------//
		protected var _propertyName : String;
		protected var _elapsedTime : int;

		
		//----------------------               Public Methods               ----------------------//
		public function TransitionEvent(type : String, bubbles : Boolean = false)
		{
			super(type, bubbles);
		}
		
		public override function toString() : String
		{
			var str : String = 'TransitionEvent.' + type;
			if (type == TRANSITION_START || 
				type == TRANSITION_COMPLETE || type == TRANSITION_CANCEL)
			{
				str += ', propertyName = ' + _propertyName;
			}
			if (type != TRANSITION_START)
			{
				str += ', elapsedTime = ' + _elapsedTime;
			}
			return str;
		}
	}
}
