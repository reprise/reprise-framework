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
	
	
	
	
	public class Margin extends CSSPropertyParser
	{
		
		public static var KNOWN_PROPERTIES	: Array 	= 
		[
			'margin',
			'marginTop',
			'marginRight',
			'marginBottom',
			'marginLeft'
		];
		
		public static function get defaultValues() : Object
		{
			return null;
		}
		
		
		public static function parseMargin(val:String, file:String) : CSSParsingResult
		{
			var obj : Object = CSSParsingHelper.removeImportantFlagFromString(val);
			var important : Boolean = obj.important;		
			val = obj.result;
			
			var parts : Array = val.split(' ');		
			
			var marginTop : CSSProperty;
			var marginRight : CSSProperty;
			var marginBottom : CSSProperty;
			var marginLeft : CSSProperty;
			
			switch (parts.length)
			{
				case 1:
					marginTop = marginRight = marginBottom = marginLeft =
						strToIntProperty(parts[0], file);
					break;
					
				case 2:
					marginTop = marginBottom = strToIntProperty(parts[0], file);
					marginRight = marginLeft = strToIntProperty(parts[1], file);
					break;
					
				case 3:
					marginTop = strToIntProperty(parts[0], file);
					marginRight = marginLeft = strToIntProperty(parts[1], file);
					marginBottom = strToIntProperty(parts[2], file);
					break;
					
				case 4:
					marginTop = strToIntProperty(parts[0], file);
					marginRight = strToIntProperty(parts[1], file);
					marginBottom = strToIntProperty(parts[2], file);
					marginLeft = strToIntProperty(parts[3], file);
					break;
					
				default:
					trace("Margin::setMargin: wrong number of " +
						"parameters in: " + val);
					return null;
			}
			
			marginTop.setImportant(important);
			marginRight.setImportant(important);
			marginBottom.setImportant(important);
			marginLeft.setImportant(important);
			
			return CSSParsingResult.ResultWithPropertiesAndKeys(
				marginTop, 'marginTop', marginRight, 'marginRight',
				marginBottom, 'marginBottom', marginLeft, 'marginLeft');		
		}
	
	
		public static function parseMarginTop(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseMarginRight(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseMarginBottom(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseMarginLeft(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
	}
}