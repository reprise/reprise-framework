/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css
{
	import reprise.core.reprise;
	import reprise.utils.StringUtil;
	
	use namespace reprise;
	
	public class CSSPropertyParser
	{
		
		/**
		* fill these in subclasses
		**/
		public static var KNOWN_PROPERTIES : Array = null;
		public static var INHERITABLE_PROPERTIES : Object = null;
		
			
		
		
		public function CSSPropertyParser() {}
		
		
		
		
		/**
		* don't touch this. no need to call this directly
		**/
		protected static function strToProperty(val:String, selector:String, file:String) : Object
		{
			var prop : CSSProperty = new CSSProperty();
			var obj : Object = CSSParsingHelper.removeImportantFlagFromString(val);
			val = StringUtil.trim(obj.result);
			prop.setImportant(obj.important);
			prop.setCSSSelector(selector);
			prop.setCSSFile(file);

			if (CSSParsingHelper.valueShouldInherit(val))
			{
				prop.setInheritsValue(true);
			}
				
			return {property : prop, filteredString : val};
		}
		
		protected static function strToNumericProperty(
				val:String, selector:String, file:String) : Object
		{		
			var obj : Object = strToProperty(val, selector, file);
			var prop : CSSProperty = obj.property;
			val = obj.filteredString;
	
			if (prop.inheritsValue())
			{
				return obj;
			}
			
			if (val.indexOf('calc(') > -1)
			{
				prop.setIsCalculation(true);
			}
			else
			{
				prop.setUnit(CSSParsingHelper.extractUnitFromString(val));
			}
			
			return obj;
		}
		
		
		
		
		/**
		* convert string into properties, by declaring the type of the value
		**/
		protected static function strToFloatProperty(
				val:String, selector:String, file:String) : CSSProperty
		{		
			var obj : Object = strToNumericProperty(val, selector, file);
			var prop : CSSProperty = obj.property;
			val = obj.filteredString;
			
			if (prop.inheritsValue())
			{
				return prop;
			}
			
			if (val == 'auto' || prop.isCalculation())
			{
				prop.setSpecifiedValue(val);
				return prop;
			}
			prop.setSpecifiedValue(parseFloat(val));
			return prop;
		}
		
		protected static function strToIntProperty(
				val:String, selector:String, file:String) : CSSProperty
		{
			var obj : Object = strToNumericProperty(val, selector, file);
			var prop : CSSProperty = obj.property;
			val = obj.filteredString;
			
			if (prop.inheritsValue())
			{
				return prop;
			}
			
			if (val == 'auto' || prop.isCalculation())
			{
				prop.setSpecifiedValue(val);
				return prop;
			}
			prop.setSpecifiedValue(int(parseInt(val)));
			return prop;		
		}
		
		protected static function strToStringProperty(
				val:String, selector : String, file:String) : CSSProperty
		{
			var obj : Object = strToProperty(val, selector, file);
			var prop : CSSProperty = obj.property;
			val = obj.filteredString;
			
			if (prop.inheritsValue())
			{
				return prop;
			}
				
			prop.setSpecifiedValue(val);
			return prop;
		}
		
		protected static function strToColorProperty(
				val:String, selector:String, file:String) : CSSProperty
		{
			var obj : Object = strToProperty(val, selector, file);
			var prop : CSSProperty = obj.property;
			val = obj.filteredString;
			
			if (prop.inheritsValue())
			{
				return prop;
			}
				
			prop.setSpecifiedValue(CSSParsingHelper.parseColor(val));
			return prop;
		}
		
		protected static function strToURLProperty(
				val:String, selector:String, file:String) : CSSProperty
		{
			var obj : Object = strToProperty(val, selector, file);
			var prop : CSSProperty = obj.property;
			val = obj.filteredString;
			
			if (prop.inheritsValue())
			{
				return prop;
			}
				
			prop.setSpecifiedValue(CSSParsingHelper.parseURL(val, file));
			return prop;
		}
		
		protected static function strToBoolProperty(
				val:String, selector:String, file:String, trueFlags:Array = null) : CSSProperty
		{
			var obj : Object = strToProperty(val, selector, file);
			var prop : CSSProperty = obj.property;
			val = obj.filteredString;
			
			if (prop.inheritsValue())
			{
				return prop;
			}
			
			if (!trueFlags)
			{
				trueFlags = ['true', '1'];
			}
			
			var isTrue : Boolean = trueFlags.indexOf(val) > -1;
			prop.setSpecifiedValue(isTrue);
			return prop;		
		}
		
		protected static function strToRectParsingResult(val : String, selector:String,
			file : String, prefix : String, postfix : String, parser : Function) : CSSParsingResult
		{
			var obj : Object = strToProperty(val, selector, file);
			var prop : CSSProperty = obj.property;
			val = StringUtil.trim(obj.filteredString);
			
			var res : CSSParsingResult = new CSSParsingResult();
		
			if (prop.inheritsValue())
			{
				res.addPropertyForKey(prop, prefix + 'Top' + postfix);
				res.addPropertyForKey(prop, prefix + 'Right' + postfix);
				res.addPropertyForKey(prop, prefix + 'Bottom' + postfix);
				res.addPropertyForKey(prop, prefix + 'Left' + postfix);
			}
			
			if (val.length === 0)
			{
				return null;
			}
			
			var parts : Array = val.split(' ');
			var important : Boolean = prop.important();
					
			var rectTop : CSSProperty;
			var rectRight : CSSProperty;
			var rectBottom : CSSProperty;
			var rectLeft : CSSProperty;
	
			switch (parts.length)
			{
				case 1:
					rectTop = rectRight = rectBottom = 
						rectLeft = parser(parts[0], selector, file);
					break;
					
				case 2:
					rectTop = rectBottom = parser(parts[0], selector, file);
					rectRight = rectLeft = parser(parts[1], selector, file);
					break;
					
				case 3:
					rectTop = parser(parts[0], selector, file);
					rectRight = rectLeft = parser(parts[1], selector, file);
					rectBottom = parser(parts[2], selector, file);
					break;
					
				case 4:
					rectTop = parser(parts[0], selector, file);
					rectRight = parser(parts[1], selector, file);
					rectBottom = parser(parts[2], selector, file);
					rectLeft = parser(parts[3], selector, file);
					break;
					
				default:
					log('w Wrong number of parameters for CSSProperty rect with name"' +
							prefix + '"');
					return res;
			}
			rectTop.setImportant(important);
			rectRight.setImportant(important);
			rectBottom.setImportant(important);
			rectLeft.setImportant(important);
	
			res.addPropertyForKey(rectTop, prefix + 'Top' + postfix);
			res.addPropertyForKey(rectRight, prefix + 'Right' + postfix);
			res.addPropertyForKey(rectBottom, prefix + 'Bottom' + postfix);
			res.addPropertyForKey(rectLeft, prefix + 'Left' + postfix);		
			return res;
		}
		
		protected static function strToDurationProperty(
			str : String, selector:String, file : String) : CSSProperty
		{
			var obj : Object = strToProperty(str, selector, file);
			var prop : CSSProperty = obj.property;
			str = obj.filteredString;
			
			if (prop.inheritsValue())
			{
				return prop;
			}
			
			var unitOffset : int = str.length;
			while ('0123456789.'.indexOf(str.charAt(unitOffset - 1)) == -1)
			{
				unitOffset--;
			}
			var unit : String = 'ms';
			if (unitOffset < str.length)
			{
				unit = str.substr(unitOffset);
			}
			
			var value : Number = parseFloat(str);
			switch (unit)
			{
				case 's':
				{
					value *= 1000;
					break;
				}
				case 'ms' :
				default :
			}
			prop.setUnit('ms');
			prop.setSpecifiedValue(value);
			
			return prop;	
		}
		
		public static function extractBorderStyleFromString(
			input : String, selector:String, file : String) : Object
		{
			var regexp : RegExp = 
				/none|hidden|dotted|dashed|solid|double|groove|ridge|inset|outset/;
			var result : Object = {borderStyle : 'none'};
			var match : Array = input.match(regexp);
			if (match)
			{
				result.borderStyle = strToStringProperty(match[0], selector, file);
				result.filteredString = input.substr(
					0, match.index) + input.substr(match.index + match[0].length);
			}
			else
			{
				result.borderStyle = strToStringProperty('none', selector, file);
				result.filteredString = input;
			}
			return result;
		}
		
		public static function extractBorderWidthFromString(
			input : String, selector:String, file : String) : Object
		{
			var regexp : RegExp = /\d+px|d+%0/;
			var result : Object = {};
			var match : Array = input.match(regexp);
			if (match)
			{
				result.borderWidth = strToIntProperty(match[0], selector, file);
				result.filteredString = input.substr(
					0, match.index) + input.substr(match.index + match[0].length);
			}
			else
			{
				result.borderWidth = strToIntProperty('1px', selector, file);
				result.filteredString = input;
			}
			return result;
		}
		
		public static function extractDurationFromString(
			input : String, selector:String, file : String) : Object
		{
			var result : Object = {};
			var match : Array = input.match(CSSParsingHelper.durationExpression);
			if (match)
			{
				result.duration = strToDurationProperty(match[0], selector, file);
				result.filteredString = input.substr(
					0, match.index) + input.substr(match.index + match[0].length);
			}
			else
			{
				result.filteredString = input;
			}
			return result;
		}
		
		public static function extractPropertyNameFromString(input : String) : Object
		{
			var result : Object = {};
			var match : Array = input.match(CSSParsingHelper.propertyNameExpression);
			if (match)
			{
				var name : String = match[0];
				result.propertyName = CSSParsingHelper.camelCaseCSSValueName(name);
				result.filteredString = input.substr(
					0, match.index) + input.substr(match.index + match[0].length);
			}
			else
			{
				result.filteredString = input;
			}
			return result;
		}
		
		/**
		 * Extracts a function literal (e.g. 'color(0, 0, 0)') from a given input String.
		 * NOTE: Right now, the parser doesn't support string literals as parameters to 
		 * the function literal, because it just uses the next right parentheses as the 
		 * function literals end. A string literal might contain a right parentheses that 
		 * doesn't close the function literal.
		 */
		public static function extractFunctionLiteralFromString(
			input : String, name : String, keepFunctionName : Boolean = true) : Object
		{
			var result : Object = {};
			var match : int = input.indexOf(name + '(');
			if (match != -1)
			{
				var matchEnd : int = input.indexOf(')', match);
				if (keepFunctionName)
				{
					result.functionLiteral = input.substring(match, matchEnd + 1);
				}
				else
				{
					result.functionLiteral = 
						input.substring(match + name.length + 1, matchEnd);
				}
				result.filteredString = 
					input.substr(0, match) + input.substr(matchEnd + 1);
			}
			else
			{
				result.filteredString = input;
			}
			
			return result;
		}
	}
}