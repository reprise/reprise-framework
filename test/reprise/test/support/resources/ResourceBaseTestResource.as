package reprise.test.support.resources
{
	import reprise.resources.ResourceBase;

	public class ResourceBaseTestResource extends ResourceBase
	{
		//----------------------              Public Properties             ----------------------//
		public static const resource : Class = ResourceBaseTestResource;
		public static const resourceChain : Object = {resource : ResourceBaseTestResource};


		//----------------------       Private / Protected Properties       ----------------------//


		//----------------------               Public Methods               ----------------------//
		public function ResourceBaseTestResource(url : String = null)
		{
			super(url);
		}

		public function publicResolveAttachSymbol() : Class
		{
			return super.resolveAttachSymbol();
		}

		public function publicCreateUnsupportedTypeMessage(type : Class) : String
		{
			return super.createUnsupportedTypeMessage(type);
		}

		//----------------------         Private / Protected Methods        ----------------------//
	}
}