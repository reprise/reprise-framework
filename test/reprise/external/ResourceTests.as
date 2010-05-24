package reprise.external
{

	import asunit.framework.TestSuite;
	/**
	 * @author tschneidereit
	 */
	public class ResourceTests extends TestSuite
	{
		public function ResourceTests()
		{
			addTest(new CancelledResourceLoaderTest());
			addTest(new ResourceLoaderTest());
		}
	}
}
