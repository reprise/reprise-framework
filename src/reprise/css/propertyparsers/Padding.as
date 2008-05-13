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

package reprise.css.propertyparsers { 
	import reprise.css.CSSProperty;
	import reprise.css.CSSPropertyParser;
	import reprise.css.CSSParsingHelper;
	import reprise.css.CSSParsingResult;
	
	
	
	
	public class Padding extends CSSPropertyParser
	{
		
		public static var KNOWN_PROPERTIES	: Array 	= 
		[
			'padding',
			'paddingTop',
			'paddingRight',
			'paddingBottom',
			'paddingLeft'
		];
		
		public static function get defaultValues() : Object
		{
			return null;
		}
		
	
		public static function parsePadding(val:String, file:String) : CSSParsingResult
		{
			var obj : Object = CSSParsingHelper.removeImportantFlagFromString(val);
			var important : Boolean = obj.important;		
			val = obj.result;
			
			var parts : Array = val.split(' ');		
			
			var paddingTop : CSSProperty;
			var paddingRight : CSSProperty;
			var paddingBottom : CSSProperty;
			var paddingLeft : CSSProperty;
			
			switch (parts.length)
			{
				case 1:
					paddingTop = paddingRight = paddingBottom = paddingLeft =
						strToIntProperty(parts[0], file);
					break;
					
				case 2:
					paddingTop = paddingBottom = strToIntProperty(parts[0], file);
					paddingRight = paddingLeft = strToIntProperty(parts[1], file);
					break;
					
				case 3:
					paddingTop = strToIntProperty(parts[0], file);
					paddingRight = paddingLeft = strToIntProperty(parts[1], file);
					paddingBottom = strToIntProperty(parts[2], file);
					break;
					
				case 4:
					paddingTop = strToIntProperty(parts[0], file);
					paddingRight = strToIntProperty(parts[1], file);
					paddingBottom = strToIntProperty(parts[2], file);
					paddingLeft = strToIntProperty(parts[3], file);
					break;
					
				default:
					trace("Padding::parsePadding: wrong number of " +
						"parameters in: " + val);
					return null;
			}
			
			paddingTop.setImportant(important);
			paddingRight.setImportant(important);
			paddingBottom.setImportant(important);
			paddingLeft.setImportant(important);
					
			return CSSParsingResult.ResultWithPropertiesAndKeys(
				paddingTop, 'paddingTop', paddingRight, 'paddingRight',
				paddingBottom, 'paddingBottom', paddingLeft, 'paddingLeft');		
		}
	
	
		public static function parsePaddingTop(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parsePaddingRight(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parsePaddingBottom(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parsePaddingLeft(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
	}
}