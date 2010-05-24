package reprise.commands
{
	import commands.*;
	import asunit.framework.TestSuite;

	/**
	 * @author tschneidereit
	 */
	public class CommandTests extends TestSuite
	{
		public function CommandTests()
		{
			addTest(new CancelledParallelCompositeTest());
			addTest(new ParallelCompositeTest());
			addTest(new CompositeCommandSortingTest());
			addTest(new CompositeCommandSortByIdTest());
		}
	}
}
