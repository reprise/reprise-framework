package commands
{
	
	import asunit.framework.AsynchronousTestCase;
	import reprise.commands.CompositeCommand;
	import reprise.commands.TimerCommand;
	import reprise.events.CommandEvent;
	import flash.events.Event;
	
	
	public class ParallelCompositeTest extends AsynchronousTestCase
	{
		
		private var m_composite:CompositeCommand;
		private var m_compositeSuccess:Boolean;
		
		
		public function ParallelCompositeTest(methodName:String=null)
		{
			super(methodName);
		}
		
		protected override function setUp():void
		{
			super.setUp();
		}
		
		protected override function tearDown():void
		{
			super.tearDown();
		}
		
		public override function run():void
		{
			m_composite = new CompositeCommand();
			m_composite.addEventListener(Event.COMPLETE, composite_complete);
			m_composite.setMaxParallelExecutionCount(3);
			var i:Number = 1000;
			while (i--)
			{
				m_composite.addCommand(new TimerCommand(10));
			}
			trace('executing 1000 TimerCommands. Please be patient ...');
			m_composite.execute();
		}
		
		protected function composite_complete(e:CommandEvent):void
		{
			trace('done');
			super.run();
			m_compositeSuccess = e.success;
		}
		
		protected function testSuccess():void
		{
			assertTrue('composite command was successful', m_compositeSuccess);
		}
	}
}