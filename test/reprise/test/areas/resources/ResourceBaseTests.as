/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.test.areas.resources
{
	import flexunit.framework.Assert;

	import org.flexunit.asserts.assertNotNull;

	import org.flexunit.asserts.assertTrue;

	import org.hamcrest.assertThatBoolean;

	import reprise.resources.ResourceBase;
	import reprise.test.support.resources.ResourceBaseTestResource;

	public class ResourceBaseTests
	{
		//----------------------              Public Properties             ----------------------//


		//----------------------       Private / Protected Properties       ----------------------//
		private var _resourceBase : ResourceBase;
		private var _testResource : ResourceBaseTestResource;


		//----------------------               Public Methods               ----------------------//
		[Test(expects='Error')] public function invokingLoadOnResourceBaseThrows() : void
		{
			_resourceBase = new ResourceBase();
			_resourceBase.load();
		}

		[Test] public function resolveAttachSymbolWorksForDirectClasses() : void
		{
			_testResource = new ResourceBaseTestResource(
					'attach://reprise.test.support.resources.ResourceBaseTestResource');
			assertNotNull('resolveAttachSymbol returns class',
					_testResource.publicResolveAttachSymbol());
			assertTrue('resolveAttachSymbol returns correct class',
					_testResource.publicResolveAttachSymbol() == ResourceBaseTestResource);
		}

		[Test] public function resolveAttachSymbolWorksForPropertyOnClass() : void
		{
			_testResource = new ResourceBaseTestResource(
					'attach://reprise.test.support.resources.ResourceBaseTestResource/resource');
			assertNotNull('resolveAttachSymbol returns class',
					_testResource.publicResolveAttachSymbol());
			assertTrue('resolveAttachSymbol returns correct class',
					_testResource.publicResolveAttachSymbol() == ResourceBaseTestResource);
		}

		[Test] public function resolveAttachSymbolWorksForPropertyChainOnClass() : void
		{
			_testResource = new ResourceBaseTestResource('attach://reprise.test.support.' +
					'resources.ResourceBaseTestResource/resourceChain/resource');
			assertNotNull('resolveAttachSymbol returns class',
					_testResource.publicResolveAttachSymbol());
			assertTrue('resolveAttachSymbol returns correct class',
					_testResource.publicResolveAttachSymbol() == ResourceBaseTestResource);
		}

		//----------------------         Private / Protected Methods        ----------------------//
	}
}