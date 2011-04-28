/*
* Copyright (c) 2006-2011 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.commands
{
	import flash.display.Shape;
	import flash.events.Event;

	import reprise.data.collection.HashMap;

	public class FrameCommandExecutor
	{
		//----------------------       Private / Protected Properties       ----------------------//
		protected static var g_instance : FrameCommandExecutor;
		private	var	_commands : HashMap;
		protected var	_nextKeyIndex : int;
		private var	_enterFrameDispatcher : Shape;
		
	
	
		//----------------------               Public Methods               ----------------------//
		public static function instance() : FrameCommandExecutor
		{
			if (!g_instance)
			{
				g_instance = new FrameCommandExecutor();
			}
			return g_instance;
		}
					
		public function addCommand(cmd : ICommand) : void
		{
			addCommandWithName(cmd, getNextKey());
		}
		
		public function addCommandWithName(cmd : ICommand, key : String) : void
		{
			if (containsCommand(cmd))
			{	
				return;
			}
			
			if (	_commands.size())
			{
				_enterFrameDispatcher.addEventListener(Event.ENTER_FRAME, enterFrame);
			}
			
			var wrapper : Object =
			{
				command : cmd
			};
			_commands.setObjectForKey(wrapper, key);
		}
		
		public function removeCommand(cmd : ICommand) : void
		{
			_commands.removeObject(wrapperForCommand(cmd));
			if (	_commands.size())
			{
				_enterFrameDispatcher.removeEventListener(Event.ENTER_FRAME, enterFrame);
			}
		}
		
		public function removeCommandWithName(key : String) : void
		{
			_commands.removeObject(wrapperForName(key));
			if (!_commands.size())
			{
				_enterFrameDispatcher.removeEventListener(Event.ENTER_FRAME, enterFrame);
			}
		}
		
		public function delayCommand(cmd : ICommand) : void
		{
			if (containsCommand(cmd))
			{
				return;
			}
			
			if (!_commands.size())
			{
				_enterFrameDispatcher.addEventListener(Event.ENTER_FRAME, enterFrame);
			}
			
			var wrapper : Object =
			{
				command : cmd,
				oneOff : true
			};
			_commands.setObjectForKey(wrapper, getNextKey());
		}
		
		
		// defined by IFrameEventListener
		public function enterFrame(e:Event) : void
		{
			var commands : Object = _commands.toObject();
			var wrapper : Object;
			for (var key : String in commands)
			{
				wrapper = commands[key];
				wrapper.command.execute();
				if (wrapper.oneOff)
				{
					removeCommandWithName(key);
				}
			}
		}
		
			
		
		//----------------------         Private / Protected Methods        ----------------------//
		public function FrameCommandExecutor()
		{
			_commands = new HashMap();
			_nextKeyIndex = 0;
			_enterFrameDispatcher = new Shape();
		}
		
		protected function containsCommand(cmd : ICommand) : Boolean
		{
			return wrapperForCommand(cmd) != null;
		}
		
		protected function wrapperForCommand(cmd : ICommand) : Object
		{
			var commands : Object = _commands.toObject();
			var wrapper : Object;
			for (var key : String in commands)
			{
				wrapper = commands[key];
				if (wrapper.command == cmd)
				{
					return wrapper;
				}
			}
			return null;
		}
		
		protected function wrapperForName(name : String) : Object
		{
			return _commands.objectForKey(name);
		}
		
		protected function getNextKey() : String
		{
			return 'key' + _nextKeyIndex++;
		}
	}
}