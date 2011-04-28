/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.core 
{
	import reprise.commands.ICommand;
	import reprise.events.EventBroadcaster;
	import reprise.ui.DocumentView;
	
	import flash.events.Event; 

	public class FrontController
	{//----------------------       Private / Protected Properties       ----------------------//
		protected var _commands : Object;
		protected var _view : DocumentView;
		
		
		//----------------------               Public Methods               ----------------------//
		public function FrontController() 
		{
			_commands = {};
		}
		
		public function executeCommand(event : Event) : void
		{
			var commandToInit:Class = getCommand(event.type);
			var commandToExec:ICommand = new commandToInit();
			commandToExec.execute(event);
		}	
		
		public function addGlobalCommand(name:String, command:Class) : void
		{
			if (_commands[name] != null)
			{
				throw new Error("command already registered");
			}
			_commands[name] = command;
			EventBroadcaster.instance().addEventListener(name, executeCommand);
		}
		
		public function removeGlobalCommand(name:String) : void
		{
			if (_commands[name] == null)
			{
				throw new Error('command not registered');
			}
			EventBroadcaster.instance().removeEventListener(name, executeCommand);
			delete _commands[name];
			_commands[name] = null;
		}
		
		public function addCommand(name:String, command:Class) : void
		{
			if (_commands[name] != null)
			{
				throw new Error("command already registered");
			}
			_commands[name] = command;
			_view.addEventListener(name, executeCommand);
		}
		
		public function removeCommand(name:String) : void
		{
			if (_commands[name] == null)
			{
				throw new Error('command not registered');
			}
			_view.removeEventListener(name, executeCommand);
			delete _commands[name];
			_commands[name] = null;
		}
		
		public function view() : DocumentView
		{
			return _view;
		}
	
		public function setView(val:DocumentView) : void
		{
			_view = val;
			initCommands();
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected function getCommand(name:String) : Class
		{
			var command : Class = _commands[name];
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