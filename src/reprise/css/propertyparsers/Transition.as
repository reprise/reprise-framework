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

package reprise.css.propertyparsers 
{
	import reprise.core.reprise;
	import reprise.css.CSSParsingHelper;
	import reprise.css.CSSParsingResult;
	import reprise.css.CSSProperty;
	import reprise.css.CSSPropertyParser;
	import reprise.utils.StringUtil;
	
	import com.robertpenner.easing.Back;
	import com.robertpenner.easing.Bounce;
	import com.robertpenner.easing.Circ;
	import com.robertpenner.easing.Cubic;
	import com.robertpenner.easing.Linear;
	import com.robertpenner.easing.Quad;
	import com.robertpenner.easing.Quart;
	import com.robertpenner.easing.Quint;
	import com.robertpenner.easing.Sine;	
	
	use namespace reprise;

	public class Transition extends CSSPropertyParser
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const KNOWN_PROPERTIES : Object =
		{
			RepriseTransition : {parser : parseRepriseTransition},
			RepriseTransitionProperty : {parser : parseRepriseTransitionPart},
			RepriseTransitionDuration : {parser : parseRepriseTransitionDuration},
			RepriseTransitionDelay : {parser : parseRepriseTransitionDelay},
			RepriseTransitionTimingFunction : {parser : parseRepriseTransitionTimingFunction},
			RepriseTransitionDefaultValue : {parser : parseRepriseTransitionDefaultValue}
		};
		public static const EASINGS : Object = 
		{
			linear : Linear.easeNone,
			Quad : Quad,
			Quint : Quint,
			Quart : Quart,
			Cubic : Cubic,
			Back : Back,
			Bounce : Bounce,
			Circ : Circ,
			Sine : Sine
		};
		
		public static function parseRepriseTransition(
			val:String, file:String) : CSSParsingResult
		{
			var obj : Object = CSSParsingHelper.removeImportantFlagFromString(val);
			var important : Boolean = obj.important;
			val = obj.result;
			
			var result : CSSParsingResult = new CSSParsingResult();
			
			var properties : Array = [];
			var durations : Array = [];
			var easings : Array = [];
			var delays : Array = [];
			var defaultValues : Array = [];
			
			var parts : Array = CSSParsingHelper.splitPropertyList(val);
			for each (var part : String in parts)
			{
				var partResult : Object = parseRepriseTransitionPart(part, file);
				if (partResult)
				{
					properties.push(partResult.property);
					durations.push(partResult.duration);
					easings.push(partResult.easing);
					delays.push(partResult.delay);
					defaultValues.push(partResult.defaultValue);
				}
			}
			
			var propertyProp : CSSProperty = new CSSProperty();
			propertyProp.setImportant(important);
			propertyProp.setSpecifiedValue(properties);
			result.addPropertyForKey(propertyProp, 'RepriseTransitionProperty');
			
			var durationProp : CSSProperty = new CSSProperty();
			durationProp.setImportant(important);
			durationProp.setSpecifiedValue(durations);
			result.addPropertyForKey(durationProp, 'RepriseTransitionDuration');
			
			var easingProp : CSSProperty = new CSSProperty();
			easingProp.setImportant(important);
			easingProp.setSpecifiedValue(easings);
			result.addPropertyForKey(easingProp, 'RepriseTransitionTimingFunction');
			
			var delayProp : CSSProperty = new CSSProperty();
			delayProp.setImportant(important);
			delayProp.setSpecifiedValue(delays);
			result.addPropertyForKey(delayProp, 'RepriseTransitionDelay');
			
			var defaultValueProp : CSSProperty = new CSSProperty();
			defaultValueProp.setImportant(important);
			defaultValueProp.setSpecifiedValue(defaultValues);
			result.addPropertyForKey(defaultValueProp, 'RepriseTransitionDefaultValue');
			
			return result;
		}
		public static function parseRepriseTransitionPart(
			str : String, file : String) : Object
		{
			var result : Object = {};
			
			//extract default value
			var extractionResult : Object = 
				extractFunctionLiteralFromString(str, 'default', false);
			result.defaultValue = extractionResult.functionLiteral;
			str = extractionResult.filteredString;
			
			//extract duration
			extractionResult = extractDurationFromString(str, file);
			result.duration = extractionResult.duration;
			str = extractionResult.filteredString;
			
			//extract delay
			extractionResult = extractDurationFromString(str, file);
			result.delay = extractionResult.duration;
			str = extractionResult.filteredString;
			
			//extract property name
			extractionResult = extractPropertyNameFromString(str);
			result.property = extractionResult.propertyName;
			str = extractionResult.filteredString;
			
			//extract easing
			result.easing = parseRepriseTransitionTimingFunctionPart(str, file);
			
			return result;
		}
		
		
		public static function parseRepriseTransitionProperty(
			val:String, file:String) : CSSProperty
		{
			var intermediateResult : Object = strToProperty(val, file);
			var property : CSSProperty = intermediateResult.property;
			if (property.inheritsValue())
			{
				return property;
			}
			var entries : Array = 
				(intermediateResult.filteredString as String).split(',');
			for (var i : int = entries.length; i--;)
			{
				entries[i] = CSSParsingHelper.camelCaseCSSValueName(entries[i]);
			}
			property.setSpecifiedValue(entries);
			return property;
		}
		
		public static function parseRepriseTransitionDuration(
			val:String, file:String) : CSSProperty
		{
			var intermediateResult : Object = strToProperty(val, file);
			var property : CSSProperty = intermediateResult.property;
			if (property.inheritsValue())
			{
				return property;
			}
			var entries : Array = [];
			
			for each (var entry : String in 
				(intermediateResult.filteredString as String).split(','))
			{
				entries.push(strToDurationProperty(entry, file));
			}
			property.setSpecifiedValue(entries);
			return property;
		}
		
		public static function parseRepriseTransitionDelay(
			val:String, file:String) : CSSProperty
		{
			//no need to duplicate the code as the properties 
			//duration and delay are identical in structure
			return parseRepriseTransitionDuration(val, file);
		}
		
		public static function parseRepriseTransitionTimingFunction(
			val:String, file:String) : CSSProperty
		{
			var intermediateResult : Object = strToProperty(val, file);
			var property : CSSProperty = intermediateResult.property;
			if (property.inheritsValue())
			{
				return property;
			}
			var entries : Array = [];
			
			for each (var entry : String in CSSParsingHelper.splitPropertyList(
				intermediateResult.filteredString as String))
			{
				entries.push(parseRepriseTransitionTimingFunctionPart(entry, file));
			}
			property.setSpecifiedValue(entries);
			return property;
		}
		public static function parseRepriseTransitionTimingFunctionPart(
			val:String, file : String) : Function
		{
			var easingName : String = CSSParsingHelper.camelCaseCSSValueName(val);
			var regExp : RegExp = /ease(InOut|In|Out)(\w+)/;
			var matchResult : Array = regExp.exec(easingName);
			if (!matchResult)
			{
				return EASINGS.linear;
			}
			var easingType : Class = EASINGS[matchResult[2]] || Linear;
			return easingType['ease' + matchResult[1]] || EASINGS.linear;
		}
		public static function parseRepriseTransitionDefaultValue(
			val:String, file : String) : CSSProperty
		{
			var intermediateResult : Object = strToProperty(val, file);
			var property : CSSProperty = intermediateResult.property;
			if (property.inheritsValue())
			{
				return property;
			}
			var entries : Array = [];
			
			for each (var entry : String in 
				(intermediateResult.filteredString as String).split(','))
			{
				entries.push(StringUtil.trim(entry));
			}
			property.setSpecifiedValue(entries);
			return property;
		}
	}
}