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

package reprise.core { 
	import reprise.commands.ICommand;
	import reprise.events.EventBroadcaster;
	import reprise.ui.DocumentView;
	
	import flash.events.Event;
	
	
	public class FrontController
	{
	
	
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected	var m_commands : Object;
		protected var m_view : DocumentView;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function FrontController() 
		{
			m_commands = {};
		}
		
		public function executeCommand(event : Event) : void
		{
			var commandToInit:Class = getCommand(event.type);
			var commandToExec:ICommand = new commandToInit();
			commandToExec.execute(event);
		}	
		
		public function addGlobalCommand(name:String, command:Function) : void
		{
			if (m_commands[name] != null)
			{
				throw new Error("command already registered");
			}
			m_commands[name] = command;
			EventBroadcaster.instance().addEventListener(name, executeCommand);
		}
		
		public function removeGlobalCommand(name:String) : void
		{
			if (m_commands[name] == null)
			{
				throw new Error('command not registered');
			}
			EventBroadcaster.instance().removeEventListener(name, executeCommand);
			delete m_commands[name];
			m_commands[name] = null;
		}
		
		public function addCommand(name:String, command:Function) : void
		{
			if (m_commands[name] != null)
			{
				throw new Error("command already registered");
			}
			m_commands[name] = command;
			m_view.addEventListener(name, executeCommand);
		}
		
		public function removeCommand(name:String) : void
		{
			if (m_commands[name] == null)
			{
				throw new Error('command not registered');
			}
			m_view.removeEventListener(name, executeCommand);
			delete m_commands[name];
			m_commands[name] = null;		
		}
		
		public function view() : DocumentView
		{
			return m_view;
		}
	
		public function setView(val:DocumentView) : void
		{
			m_view = val;
			initCommands();
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function getCommand(name:String) : Class
		{
			var command : Class = m_commands[name];
			if (command == null)
			{
				throw new Error("command " + name + " not found");
			}
			return command;
		}
		
		protected function initCommands() : void
		{
			throw new Error('Cannot call initCommands of FrontController directly!');
		}
	}
}