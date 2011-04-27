/*
 * Copyright (c) 2006-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.commands
{
	import flash.events.EventDispatcher;

	import reprise.commands.events.CommandEvent;

	public class CommandBase extends EventDispatcher implements ICommand
	{
		////////////////////////       Private / Protected Properties       ////////////////////////
		protected var _success : Boolean;
		protected var _priority : int = 0;


		////////////////////////               Public Methods               ////////////////////////
		public function CommandBase()
		{
		}


		public function execute() : void
		{
		}

		public function get priority() : int
		{
			return _priority;
		}

		public function set priority(value : int) : void
		{
			if (value == _priority)
			{
				return;
			}
			_priority = value;
			if (hasEventListener(CommandEvent.PRIORITY_CHANGE))
			{
				dispatchEvent(new CommandEvent(CommandEvent.PRIORITY_CHANGE));
			}
		}

		public function get success() : Boolean
		{
			return _success;
		}
	}
}