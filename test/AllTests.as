package {
	/**
	 * This file has been automatically created using
	 * #!/usr/bin/ruby script/generate suite
	 * If you modify it and run this script, your
	 * modifications will be lost!
	 */

	import asunit.framework.TestSuite;
	
	import commands.CancelledParallelCompositeTest;
	import commands.CompositeCommandSortByIdTest;
	import commands.CompositeCommandSortingTest;
	import commands.ParallelCompositeTest;
	
	import external.CancelledResourceLoaderTest;
	import external.ResourceLoaderTest;
	
	import prerequisites.BasicTest;

	public class AllTests extends TestSuite 
	{
		public function AllTests() 
		{
			addTest(new CancelledResourceLoaderTest());
			addTest(new ResourceLoaderTest());
			addTest(new CancelledParallelCompositeTest());
			addTest(new ParallelCompositeTest());
			addTest(new CompositeCommandSortingTest());
			addTest(new CompositeCommandSortByIdTest());
			addTest(new BasicTest());
		}
	}
}