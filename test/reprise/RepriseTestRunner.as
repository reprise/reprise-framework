package 
reprise{
	import flash.display.Sprite;

	import org.flexunit.internals.TraceListener;
	import org.flexunit.listeners.CIListener;
	import org.flexunit.runner.FlexUnitCore;

	import reprise.RepriseTestSuite;

	public class RepriseTestRunner extends Sprite
	{

		public function RepriseTestRunner()
		{
			var core:FlexUnitCore = new FlexUnitCore();
			core.addListener(new CIListener());
			core.addListener(new TraceListener());
			core.run(RepriseTestSuite);
		}
	}
}