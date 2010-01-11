/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.events
{ 
	import reprise.external.HTTPStatus;
	
	import flash.events.Event;
	
	public class ResourceEvent extends CommandEvent
	{		
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const PROGRESS : String = 'resourceProgress';
		
		public static const ERROR_TIMEOUT : int = 1;
		public static const ERROR_HTTP : int = 2;
		public static const ERROR_UNKNOWN : int = 3;
		public static const ERROR_NO_ERROR : int = 4; //for the sake of completeness
		public static const USER_CANCELLED : int = 5;
			
		public var httpStatus : HTTPStatus;
		public var reason : int;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function ResourceEvent(type:String, didSucceed:Boolean = false, 
			reason:int = -1, status:HTTPStatus = null)
		{
			super(type);
			if (type == COMPLETE && !didSucceed && reason == -1)
			{
				log("ResourceEvent with negative success called " + 
					"without specifying a reason!");
			}
			success = didSucceed;
			httpStatus = status;
		}
		
		public override function clone() : Event
		{
			return new ResourceEvent(
				type, success, reason, httpStatus ? httpStatus.clone() : null);
		}
	}
}