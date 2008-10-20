package external
{
	
	import asunit.framework.AsynchronousTestCase;
	import reprise.events.CommandEvent;
	import flash.events.Event;
	import mock.MockResource;
	import reprise.external.ResourceLoader;
	
	
	public class ResourceLoaderTest extends AsynchronousTestCase
	{
		
		private var m_loader:ResourceLoader;
		private var m_loaderSuccess:Boolean;
		
		
		public function ResourceLoaderTest(methodName:String=null)
		{
			super(methodName);
		}
		
		public override function run():void
		{
			m_loader = new ResourceLoader();
			m_loader.addEventListener(Event.COMPLETE, loader_complete);
			m_loader.setMaxParallelExecutionCount(3);
			var i:Number = 1000;
			while (i--)
			{
				m_loader.addResource(new MockResource('hello world', 150));
			}
			trace('loading 1000 MockResources. Please be patient ...');
			m_loader.execute();
		}
		
		public function testSuccess():void
		{
			assertTrue('resourceloader was successful', m_loaderSuccess);
		}
		
		protected function loader_complete(e:CommandEvent):void
		{
			trace('done');
			m_loaderSuccess = e.success;
			super.run();
		}
	}
}