/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.test.suites
{
	import reprise.test.areas.commands.AsyncCommandBaseTests;
	import reprise.test.areas.commands.CommandBaseTests;
	import reprise.test.areas.commands.CompositeCommandTests;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class CommandTests
	{
		public var commandBaseTests : CommandBaseTests;
		public var asyncCommandBaseTests : AsyncCommandBaseTests;
		public var compositeCommandTests : CompositeCommandTests;
	}
}