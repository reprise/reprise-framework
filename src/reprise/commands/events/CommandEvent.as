/*
 * Copyright (c) 2006-2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.commands.events
{
	import flash.events.Event;

	public class CommandEvent extends Event
	{
		public static const COMPLETE : String = 'commandComplete';
		public static const CANCEL : String = 'commandCancel';
		public static const PRIORITY_CHANGE : String = 'commandPriorityChange';
		
		public function CommandEvent(type : String)
		{
			super(type);
		}
	}
}