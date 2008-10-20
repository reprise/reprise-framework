package external
{

	import asunit.framework.TestCase;
	
	import reprise.external.IResource;
	import reprise.external.ImageResource;
	import reprise.external.ResourceLoader;
	
	public class ResourceLoaderMethodsTest extends TestCase
	{
		
		/***************************************************************************
		*                           Protected properties                           *
		***************************************************************************/
		protected var m_resourceLoader:ResourceLoader;
		protected var m_resource1:ImageResource;
		protected var m_resource2:ImageResource;
		
		
		public function ResourceLoaderMethodsTest(methodName:String=null)
		{
			super(methodName);
		}

		public function testResourceWithURL():void
		{
			var foundResource:IResource = m_resourceLoader.resourceWithURL(
				'http://www.foo.com/example.jpg');
			assertTrue('Found resource does not match searched resource', 
				foundResource == m_resource1);
		}
		
		public function testResourceWithURLFail():void
		{
			var foundResource:IResource = m_resourceLoader.resourceWithURL(
				'http://www.example.com/example.jpg');
			assertTrue('Found resource should be null', 
				foundResource == null);
		}
		
		protected override function setUp():void
		{
			super.setUp();
			
			m_resource1 = new ImageResource('http://www.foo.com/example.jpg');
			m_resource2 = new ImageResource('../example.jpg');
			
			m_resourceLoader = new ResourceLoader();
			m_resourceLoader.addResource(m_resource1);
			m_resourceLoader.addResource(m_resource2);
		}
	}
}