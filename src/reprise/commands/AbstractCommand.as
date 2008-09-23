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

	import reprise.commands.ICommand;
	import flash.events.EventDispatcher;
	
	public class AbstractCommand extends EventDispatcher 
		implements ICommand
	{
		
		/***************************************************************************
		*                             Public properties                            *
		***************************************************************************/
		public var m_id : Number;
		public var m_priority : Number = 0;
		
		
		
		/***************************************************************************
		*                           Protected properties                           *
		***************************************************************************/
		protected var m_didSucceed : Boolean;
		
		
		
		/***************************************************************************
		*                              Public methods                              *
		***************************************************************************/
		public function AbstractCommand() {}
		
		
		public function execute(...rest) : void
		{
			
		}
		
		public function setPriority(value : Number) : void
		{
			m_priority = value;
		}
		
		public function priority() : Number
		{
			return m_priority;
		}
		
		public function setId(value : Number) : void
		{
			m_id = value;
		}
		
		public function id() : Number
		{
			return m_id;
		}
		
		public function didSucceed() : Boolean
		{
			return m_didSucceed;
		}
	}
}