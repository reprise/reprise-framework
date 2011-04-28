/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.commands { 
	import reprise.data.collection.HashMap;
	import reprise.utils.ProxyFunction;
	
	
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	public class TimeCommandExecutor
	{
		//----------------------       Private / Protected Properties       ----------------------//
		protected static var g_instance:TimeCommandExecutor;
		protected	var _commands:HashMap;
		protected var _nextKeyIndex:Number;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public static function instance():TimeCommandExecutor
		{
			if (!g_instance)
			{
				g_instance = new TimeCommandExecutor();
			}
			return g_instance;
		}
		
		public function addCommand(cmd:ICommand, time:Number):void
		{
			addCommandWithName(cmd, getNextKey(), time);
		}
		
		public function addCommandWithName(cmd:ICommand, key:String, time:Number = 0):void
		{
			if (containsCommand(cmd))
			{
				return;
			}
			if (_commands.containsKey(key))
			{
				removeCommandWithName(key);
			}
	
			if (time <= 0 || isNaN(time))
			{
				cmd.execute();
				return;
			}
			
			// I wish we had structs, but I resist writing a new class for that one
			var wrapper : Object = {};
			wrapper.command = cmd;
			wrapper.interval = setInterval(
				ProxyFunction.create(this, executeWrappedCommand, wrapper), time);
			_commands.setObjectForKey(wrapper, key);
		}
		
		public function removeCommand(cmd:ICommand):void
		{
			var wrapper : Object = wrapperForCommand(cmd);
			if (!wrapper)
			{
				return;
			}
			clearInterval(wrapper.interval);
			_commands.removeObject(wrapper);
		}
		
		public function removeCommandWithName(key:String):void
		{
			var wrapper:Object = wrapperForName(key);
			clearInterval(wrapper.interval);
			_commands.removeObjectForKey(key);
		}	
		
		public function delayCommand(cmd:ICommand, time:Number = 0):void
		{
			if (containsCommand(cmd))
			{
				return;
			}
	
			if (time <= 0 || isNaN(time))
			{
				cmd.execute();
				return;
			}
			
			var wrapper : Object = {};
			wrapper.command = cmd;
			wrapper.oneOff = true;
			wrapper.interval = setInterval(
				ProxyFunction.create(this, executeWrappedCommand, wrapper), time);
			_commands.setObjectForKey(wrapper, getNextKey());
		}
		
		public function resetCommandBySettingNewTime(cmd:ICommand, time:Number = 0):void
		{
			var wrapper : Object = wrapperForCommand(cmd);
			if (wrapper == null || isNaN(time) || time < 1)
			{
				return;
			}
			clearInterval(wrapper.interval);
			wrapper.interval = setInterval(
				ProxyFunction.create(this, executeWrappedCommand, wrapper), time);
		}
		
		public function containsCommand(cmd : ICommand) : Boolean
		{
			return wrapperForCommand(cmd) != null;
		}	
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		public function TimeCommandExecutor()
		{
			_commands = new HashMap();
			_nextKeyIndex = 0;
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
		
		protected function getNextKey():String
		{
			return 'key' + _nextKeyIndex++;
		}
		
		protected function executeWrappedCommand(wrapper : Object) : void
		{
			wrapper.command.execute();
			if (wrapper.oneOff)
			{
				removeCommand(wrapper.command);
			}
		}
	}
}