/*
 * Copyright (c) 2010-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.test
{
	import reprise.test.suites.CommandTests;
	import reprise.test.suites.ResourceTests;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class RepriseTestSuite
	{
		public var commandTests : CommandTests;
		public var resourceTests : ResourceTests;
	}
}