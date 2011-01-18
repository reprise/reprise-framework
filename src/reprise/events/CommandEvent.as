/*
 * Copyright (c) 2006-2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.events
{
	import flash.events.Event;

	public class CommandEvent extends Event
	{
		public var success : Boolean;

		public function CommandEvent(type : String, success : Boolean)
		{
			super(type);
			this.success = success;
		}
	}
}