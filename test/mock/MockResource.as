package mock
{
	
	import reprise.external.AbstractResource;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	
	public class MockResource extends AbstractResource
	{
		
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		protected var m_timer:Timer;

		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function MockResource(url:String = null, delay:Number=1000)
		{
			super(url);
			m_timer = new Timer(delay, 1);
			m_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timer_complete);
		}
		
		public override function content():*
		{
			return null;
		}
		
		public override function bytesLoaded():Number
		{
			return 0;
		}
		
		public override function bytesTotal():Number
		{
			return 0;
		}
		
		
		
		/***************************************************************************
		*							protected methods							   *
		***************************************************************************/
		protected override function doLoad():void
		{
			m_timer.start();
		}
		
		protected override function doCancel():void
		{
			m_timer.stop();
			m_timer.reset();
		}
		
		// LoadVars event	
		protected function timer_complete(event:TimerEvent):void
		{
			onData(true);
		}
	}
}