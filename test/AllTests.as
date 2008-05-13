package {
	/**
	 * This file has been automatically created using
	 * #!/usr/bin/ruby script/generate suite
	 * If you modify it and run this script, your
	 * modifications will be lost!
	 */

	import asunit.framework.TestSuite;
	import prerequisites.BasicTest;
	import commands.ParallelCompositeTest;
	import commands.CancelledParallelCompositeTest;
	import external.ResourceLoaderTest;
	import external.CancelledResourceLoaderTest;

	public class AllTests extends TestSuite 
	{
		public function AllTests() 
		{
			addTest(new CancelledResourceLoaderTest());
			addTest(new ResourceLoaderTest());
			addTest(new CancelledParallelCompositeTest());
			addTest(new ParallelCompositeTest());
			addTest(new BasicTest());
		}
	}
}