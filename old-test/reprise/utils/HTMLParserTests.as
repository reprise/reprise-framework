/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.utils
{
	import flexunit.framework.Assert;

	public class HTMLParserTests
	{
		[Test]
		public function parserFixesUnclosedBRTagsTest() : void
		{
			var input : String = '<br>';
			var output : String = HTMLParser.HTMLtoXML(input);
			var expected : String = '<br/>';
			Assert.assertEquals('HTMLParser fixes unclosed BR tags', expected, output);
		}

		[Test]
		public function parserClosesUnclosedPTagsTest() : void
		{
			var input : String = '<p> unclosed paragraph';
			var output : String = HTMLParser.HTMLtoXML(input);
			var expected : String = '<p> unclosed paragraph</p>';
			Assert.assertEquals('HTMLParser fixes unclosed P tags', expected, output);
		}
	}
}