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

package reprise.commands { 
	import reprise.data.collection.HashMap;
	import reprise.utils.ProxyFunction;
	
	
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	public class TimeCommandExecutor
	{
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_instance:TimeCommandExecutor;
		protected	var m_commands:HashMap;
		protected var m_nextKeyIndex:Number;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/	
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
			if (m_commands.containsKey(key))
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
			m_commands.setObjectForKey(wrapper, key);
		}
		
		public function removeCommand(cmd:ICommand):void
		{
			var wrapper : Object = wrapperForCommand(cmd);
			if (!wrapper)
			{
				return;
			}
			clearInterval(wrapper.interval);
			m_commands.removeObject(wrapper);
		}
		
		public function removeCommandWithName(key:String):void
		{
			var wrapper:Object = wrapperForName(key);
			clearInterval(wrapper.interval);
			m_commands.removeObjectForKey(key);
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
			m_commands.setObjectForKey(wrapper, getNextKey());
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
		
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		public function TimeCommandExecutor()
		{
			m_commands = new HashMap();
			m_nextKeyIndex = 0;
		}
		
		protected function wrapperForCommand(cmd : ICommand) : Object
		{
			var commands : Object = m_commands.toObject();
			var key : String;
			var wrapper : Object;
			for (key in commands)
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
			return m_commands.objectForKey(name);
		}
		
		protected function getNextKey():String
		{
			return 'key' + m_nextKeyIndex++;
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