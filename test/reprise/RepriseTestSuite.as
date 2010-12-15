/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise
{
	import reprise.layout.CSS2BoxModelLayoutTestSuite;
	import reprise.utils.UtilsTestSuite;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class RepriseTestSuite
	{
//		public var cssTests : CSSTestSuite;
		public var layoutTests : CSS2BoxModelLayoutTestSuite;
//		public var domTests : HTMLDOMTestSuite;
		public var utilsTests : UtilsTestSuite;
	}
}