package prerequisites
{
	import asunit.framework.TestCase;
	
	public class BasicTest extends TestCase
	{
		
		public function BasicTest(methodName:String=null)
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
		
		public function testTrue():void
		{
			assertTrue('true is true', true);
		}
		
		public function testFalse():void
		{
			assertFalse('false is false', false);
		}
		
		public function testEqual():void
		{
			assertEquals('1 equals 1', 1, 1);
		}
		
		public function testNotNull():void
		{
			assertNotNull('1 is not null', 1);
		}
		
		public function testNull():void
		{
			assertNull('null is null', null);
		}
		
		public function testSame():void
		{
			var str:String = 'hello world';
			assertSame('string one is the same as string 2', str, str);
		}
		
		public function testNotSame():void
		{
			var arr1:Array = new Array();
			var arr2:Array = new Array();
			assertNotSame('array one is not the same as array 2', arr1, arr2);
		}
	}
}