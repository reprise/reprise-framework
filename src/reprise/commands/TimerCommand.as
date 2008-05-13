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
	
	import reprise.commands.AbstractAsynchronousCommand;
	import flash.utils.Timer;
	import flash.events.TimerEvent;


	public class TimerCommand extends AbstractAsynchronousCommand
	{
		
		private var m_timer:Timer;
		
		
		public function TimerCommand(delay:Number)
		{
			super();
			m_timer = new Timer(delay, 1);
			m_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timer_complete);
		}
		
		public override function execute(...args):void
		{
			super.execute();
			m_timer.start();
		}
		
		public override function cancel():void
		{
			m_timer.stop();
		}
		
		protected function timer_complete(e:TimerEvent):void
		{
			notifyComplete(true);
		}
	}
}