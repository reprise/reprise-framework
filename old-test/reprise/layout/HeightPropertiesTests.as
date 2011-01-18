/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.layout
{
	import flexunit.framework.Assert;

	import reprise.support.RepriseDocumentTestsBase;
	import reprise.ui.DocumentView;
	import reprise.ui.UIComponent;

	public class HeightPropertiesTests extends RepriseDocumentTestsBase
	{
		[Test]
		public function testBasicHeightSetting() : void
		{
			var document : DocumentView = createDocumentAndAddToStage();
			var element : UIComponent = document.addElement();
			element.setStyle('height', '100px');
			document.validateDocument();
			Assert.assertEquals('element height is 100px', 100, element.height);
		}
	}
}