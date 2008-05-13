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

package reprise.controls.csspropertyparsers
{ 
	import reprise.css.CSSProperty;
	import reprise.css.CSSPropertyParser;
	/**
	 * @author Till Schneidereit
	 */
	public class ScrollbarProperties extends CSSPropertyParser
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var KNOWN_PROPERTIES : Array = 
		[
			'autoHide',
			'scaleScrollThumb',
			'lineScrollSize',
			'pageScrollSize'
		];
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public static function parseAutoHide(
			val : String, file : String = null) : CSSProperty
		{
			return strToBoolProperty(val, null, file);
		}
		
		public static function parseScaleScrollThumb(
			val : String, file : String = null) : CSSProperty
		{
			return strToBoolProperty(val, null, file);
		}
		
		public static function parseLineScrollSize(
			val : String, file : String = null) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		public static function parsePageScrollSize(
			val : String, file : String = null) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
	}
}