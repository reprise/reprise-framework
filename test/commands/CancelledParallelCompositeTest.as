package commands
{
	
	import asunit.framework.AsynchronousTestCase;
	import reprise.commands.CompositeCommand;
	import reprise.commands.TimerCommand;
	import reprise.events.CommandEvent;
	import flash.events.Event;
	
	
	public class CancelledParallelCompositeTest extends AsynchronousTestCase
	{
		
		private var m_composite:CompositeCommand;
		private var m_cancelError:Error;
		
		
		public function CancelledParallelCompositeTest(methodName:String=null)
		{
			super(methodName);
		}
		
		public function testCancelSuccess():void
		{
			assertNull('no error should occur on cancel', m_cancelError);
		}
		
		public override function run():void
		{
			m_composite = new CompositeCommand();
			m_composite.setMaxParallelExecutionCount(3);
			var i:Number = 1000;
			while (i--)
			{
				if (i == 700)
				{
					var cmd:TimerCommand = new TimerCommand(10);
					cmd.addEventListener(Event.COMPLETE, cancelCommand_complete);
					m_composite.addCommand(cmd);
					continue;
				}
				m_composite.addCommand(new TimerCommand(10));
			}
			trace('executing 700 TimerCommands. Please be patient ...');
			m_composite.execute();
		}
		
		protected function cancelCommand_complete(e:CommandEvent):void
		{
			trace('cancelCommand_complete');
			try
			{
				m_composite.cancel();
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