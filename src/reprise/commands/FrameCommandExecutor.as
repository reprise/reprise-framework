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

package reprise.commands
{
	import reprise.core.ApplicationRegistry;
	import reprise.data.collection.HashMap;
	
	import flash.events.Event;
	public class FrameCommandExecutor
	{
	
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_instance : FrameCommandExecutor;
		private	var m_commands : HashMap;
		protected var m_nextKeyIndex : Number;
		
	
	
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/	
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
			
			if (!m_commands.size())
			{
				ApplicationRegistry.instance().applicationForURL('').stage.
					addEventListener(Event.ENTER_FRAME, enterFrame);
			}
			
			var wrapper : Object =
			{
				command : cmd
			};
			m_commands.setObjectForKey(wrapper, key);
		}
		
		public function removeCommand(cmd : ICommand) : void
		{
			m_commands.removeObject(wrapperForCommand(cmd));
			if (!m_commands.size())
			{
				ApplicationRegistry.instance().applicationForURL('').stage.
					removeEventListener(Event.ENTER_FRAME, enterFrame);
			}
		}
		
		public function removeCommandWithName(key : String) : void
		{
			m_commands.removeObject(wrapperForName(key));
			if (!m_commands.size())
			{
				ApplicationRegistry.instance().applicationForURL('').stage.
					removeEventListener(Event.ENTER_FRAME, enterFrame);
			}
		}
		
		public function delayCommand(cmd : ICommand) : void
		{
			if (containsCommand(cmd))
			{
				return;
			}
			
			if (!m_commands.size())
			{
				ApplicationRegistry.instance().applicationForURL('').stage.
					addEventListener(Event.ENTER_FRAME, enterFrame);
			}
			
			var wrapper : Object =
			{
				command : cmd,
				oneOff : true
			};
			m_commands.setObjectForKey(wrapper, getNextKey());
		}
		
		
		// defined by IFrameEventListener
		public function enterFrame() : void
		{
			var commands : Object = m_commands.toObject();
			var key : String;
			var wrapper : Object;
			for (key in commands)
			{
				wrapper = commands[key];
				wrapper.command.execute();
				if (wrapper.oneOff)
				{
					removeCommandWithName(key);
				}
			}
		}
		
			
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		public function FrameCommandExecutor()
		{
			m_commands = new HashMap();
			m_nextKeyIndex = 0;
		}
		
		protected function containsCommand(cmd : ICommand) : Boolean
		{
			return wrapperForCommand(cmd) != null;
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
		
		protected function getNextKey() : String
		{
			return 'key' + m_nextKeyIndex++;
		}
	}
}