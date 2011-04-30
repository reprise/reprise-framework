/*
 * Copyright (c) 2006-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.resources.events
{
	import flash.events.Event;

	import reprise.commands.events.CommandEvent;

	public class ResourceEvent extends CommandEvent
	{
		public static const PROGRESS : String = 'resourceProgress';

		public static const ERROR_TIMEOUT : uint = 1;
		public static const ERROR_HTTP : uint = 2;
		public static const ERROR_IO : uint = 3;
		public static const ERROR_UNKNOWN : uint = 4;
		public static const ERROR_CANCELLED : uint = 5;

		public var success : Boolean;
		public var error : int;
		public var httpStatusCode : int;
		public var errorDescription : String;


		public function ResourceEvent(type : String, success : Boolean = true,
				error : int = -1, httpStatusCode : int = 0, errorDescription : String = '')
		{
			super(type);
			if (type === COMPLETE && !success && error === -1)
			{
				log("w ResourceEvent with negative success called " +
						"without specifying an error code");
			}
			this.error = error;
			this.success = success;
			this.httpStatusCode = httpStatusCode;
			this.errorDescription = errorDescription;
		}

		public override function clone() : Event
		{
			return new ResourceEvent(type, success, error, httpStatusCode, errorDescription);
		}
	}
}