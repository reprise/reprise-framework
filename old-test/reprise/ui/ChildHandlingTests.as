/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.ui
{
	import org.flexunit.Assert;

	import reprise.support.RepriseDocumentTestsBase;

	public class ChildHandlingTests extends RepriseDocumentTestsBase
	{
		[Test]
		public function addingChildElementsInvalidatesUIComponent() : void
		{
			var document : DocumentView = createDocumentAndAddToStage();
			var component : UIComponent = document.addElement();
			document.validateDocument();
			var child : UIComponent = component.addElement();
			Assert.assertFalse(document.isValid());
		}
	}
}