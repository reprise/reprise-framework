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
		*                           Protected properties                           *
		***************************************************************************/
		protected var m_didSucceed : Boolean;
		protected var m_id:Number;
		protected var m_priority:Number;
		
		
		/***************************************************************************
		*                              Public methods                              *
		***************************************************************************/
		public function AbstractCommand() {}
		
		
		public function execute(...rest) : void
		{
			
		}
		
		public function get priority():Number
		{
			return m_priority;
		}
		
		public function set priority(value:Number):void
		{
			m_priority = value;
		}
		
		public function get id():Number
		{
			return m_id;
		}
		
		public function set id(value:Number):void
		{
			m_id = value;
		}
		
		public function didSucceed() : Boolean
		{
			return m_didSucceed;
		}
	}
}