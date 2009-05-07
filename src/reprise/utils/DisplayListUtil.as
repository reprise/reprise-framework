////////////////////////////////////////////////////////////////////////////////
//
//  Fork unstable media GmbH
//  Copyright 2006-2008 Fork unstable media GmbH
//  All Rights Reserved.
//
//  NOTICE: Fork unstable media permits you to use, modify, and distribute this
//  file in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package reprise.utils
{
	import reprise.ui.UIObject;

	import flash.display.DisplayObject;

	public final class DisplayListUtil
	{
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public static function locateElementContainingDisplayObject(
			displayObject : DisplayObject, keyViewsOnly : Boolean = false) : UIObject
		{
			var element : DisplayObject = DisplayObject(displayObject);
			while (element && !(element is UIObject))
			{
				element = element.parent;
			}
			if (!element || !keyViewsOnly)
			{
				return element as UIObject;
			}
			var uiElement : UIObject = UIObject(element);
			while (uiElement && !uiElement.canBecomeKeyView())
			{
				uiElement = uiElement.parentElement();
			}
			return uiElement;
		}
	}
}
