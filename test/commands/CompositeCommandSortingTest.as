//
//  CompositeCommandSortingTest.as
//
//  Created by Marc Bauer on 2008-10-09.
//  Copyright (c) 2008 Fork Unstable Media GmbH. All rights reserved.
//

package commands
{
	
	import asunit.framework.AsynchronousTestCase;
	
	import flash.events.Event;
	
	import reprise.commands.CompositeCommand;
	import reprise.commands.TimerCommand;
	import reprise.utils.Delegate;
	
	
	public class CompositeCommandSortingTest extends AsynchronousTestCase
	{
		
		private var m_compositeCommand:CompositeCommand;
		
		private var m_delegate1:Delegate;
		private var m_delegate2:Delegate;
		private var m_delegate3:Delegate;
		
		private var m_delegate1Complete:Boolean = false;
		private var m_delegate2Complete:Boolean = false;
		private var m_delegate3Complete:Boolean = false;
		
		private var m_success:Boolean = false;
		
		
		/***************************************************************************
		*                              Public methods                              *
		***************************************************************************/
		public function CompositeCommandSortingTest(methodName:String=null)
		{
			super(methodName);
		}
		
		
		public override function run():void
		{
			m_delegate1 = new Delegate(this, delegate1_complete);
			m_delegate1.addEventListener(Event.COMPLETE, delegate1_complete);
			m_delegate2 = new Delegate(this, delegate2_complete);
			m_delegate1.addEventListener(Event.COMPLETE, delegate2_complete);
			m_delegate3 = new Delegate(this, delegate3_complete);
			m_delegate1.addEventListener(Event.COMPLETE, delegate3_complete);
			
			m_compositeCommand = new CompositeCommand();
			m_compositeCommand.addEventListener(Event.COMPLETE, compositeCommand_complete);

			m_compositeCommand.addCommand(m_delegate1);			
			m_compositeCommand.addCommand(new TimerCommand(250));
			m_compositeCommand.addCommand(m_delegate3);
			m_compositeCommand.addCommand(m_delegate2);
			m_compositeCommand.execute();
		}
		
		public function testSuccess():void
		{
			assertTrue('sorting of composite command was not successful', m_success);
		}
		
		
		/***************************************************************************
		*                             Protected methods                            *
		***************************************************************************/
		protected function delegate1_complete(e:Event, d:Delegate):void
		{
			if (m_delegate2Complete || m_delegate3Complete)
			{
				fail();
				return;
			}
			m_delegate1Complete = true;
			m_delegate2.priority = 2;
			m_delegate3.priority = 1;
		}
		
		protected function delegate2_complete(e:Event, d:Delegate):void
		{
			if (!m_delegate1Complete || m_delegate3Complete)
			{
				fail();
				return;
			}
			m_delegate2Complete = true;
		}
		
		protected function delegate3_complete(e:Event, d:Delegate):void
		{
			if (!m_delegate1Complete || !m_delegate2Complete)
			{
				fail();
				return;
			}
			m_delegate3Complete = true;
			m_success = true;
		}
		
		protected function compositeCommand_complete(e:Event):void
		{
			super.run();
		}
		
		protected function fail():void
		{
			m_success = false;
			m_compositeCommand.cancel();
			super.run();
		}
	}
}