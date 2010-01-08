package external
{
	
	import asunit.framework.AsynchronousTestCase;
	import reprise.events.CommandEvent;
	import flash.events.Event;
	import mock.MockResource;
	import reprise.external.ResourceLoader;
	
	
	public class CancelledResourceLoaderTest extends AsynchronousTestCase
	{
		
		private var m_loader:ResourceLoader;
		private var m_cancelError:Error;
		
		
		public function CancelledResourceLoaderTest(methodName:String=null)
		{
			super(methodName);
		}
		
		public override function run():void
		{
			m_loader = new ResourceLoader();
			m_loader.setMaxParallelExecutionCount(3);
			var i:Number = 100;
			var j:Number = 0;
			var durations:Array = [1, 5, 15, 25, 30];
			while (i--)
			{
				var duration:Number = durations[j++];
				if (j == durations.length)
				{
					j = 0;
				}
				var res:MockResource = new MockResource('fake_url', duration);
				if (i == 30)
				{
					res.addEventListener(Event.COMPLETE, cancelResource_complete);
				}
				m_loader.addResource(res);
			}
			trace('loading 70 MockResources. Please be patient ...');
			m_loader.execute();
		}
		
		public function testCancelSuccess():void
		{
			assertNull('no error should occur on cancel', m_cancelError);
		}
		
		protected function cancelResource_complete(e:CommandEvent):void
		{
			try
			{
				m_loader.cancel();
			}
			catch (err:Error)
			{
				m_cancelError = err;
				trace(m_cancelError);
			}
			finally
			{
				super.run();
			}
		}
	}
}