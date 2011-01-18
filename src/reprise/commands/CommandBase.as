/*
 * Copyright (c) 2006-2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.commands
{
	import flash.events.EventDispatcher;

	public class CommandBase extends EventDispatcher implements ICommand
	{
		////////////////////////       Private / Protected Properties       ////////////////////////
		protected var _success : Boolean;
		protected var _id : int = 0;
		protected var _priority : int = 0;
		
		private var _queue : CompositeCommand;


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
			if (_queue)
			{
				_queue.invalidatePriorities();
			}
		}

		public function get id() : int
		{
			return _id;
		}

		public function set id(value : int) : void
		{
			_id = value;
		}

		public function get success() : Boolean
		{
			return _success;
		}

		public function get queue() : CompositeCommand
		{
			return _queue;
		}

		public function set queue(queue : CompositeCommand) : void
		{
			_queue = queue;
		}
	}
}