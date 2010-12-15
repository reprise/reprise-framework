/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.support
{
	import org.fluint.uiImpersonation.UIImpersonator;

	import reprise.ui.DocumentView;

	public class RepriseDocumentTestsBase
	{
		/*******************************************************************************************
		 *								public properties										   *
		 *******************************************************************************************/


		/*******************************************************************************************
		 *								protected/ private properties							   *
		 *******************************************************************************************/


		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function RepriseDocumentTestsBase()
		{
		}

		/*******************************************************************************************
		 *								protected/ private methods								 *
		 *******************************************************************************************/
		protected function createDocumentAndAddToStage() : DocumentView
		{
			var testView : TestView = new TestView();
			UIImpersonator.addChild(testView);
			var document : DocumentView = new DocumentView();
			testView.addChild(document);
			document.setParent(document);
			return document;
		}
	}
}