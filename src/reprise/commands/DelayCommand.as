/*
 * Copyright (c) 2006-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

/**
 * Waits for the specified duration before completing
 *
 * Can be used to stall <code>CompositeCommand</code>s for a certain duration
 */
package reprise.commands
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class DelayCommand extends AsyncCommandBase
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _timer : Timer;


		//----------------------               Public Methods               ----------------------//
		public function DelayCommand(duration : Number)
		{
			super();
			_timer = new Timer(duration, 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timer_complete);
		}

		public override function execute() : void
		{
			super.execute();
			_timer.start();
		}

		public override function cancel() : void
		{
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timer_complete);
			_timer.stop();
			super.cancel();
		}

		
		//----------------------         Private / Protected Methods        ----------------------//
		protected function timer_complete(e : TimerEvent) : void
		{
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timer_complete);
			notifyComplete(true);
		}
	}
}