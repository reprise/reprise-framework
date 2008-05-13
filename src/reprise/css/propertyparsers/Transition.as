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
	import com.robertpenner.easing.Back;
	import com.robertpenner.easing.Bounce;
	import com.robertpenner.easing.Circ;
	import com.robertpenner.easing.Cubic;
	import com.robertpenner.easing.Linear;
	import com.robertpenner.easing.Quad;
	import com.robertpenner.easing.Quart;
	import com.robertpenner.easing.Quint;
	import com.robertpenner.easing.Sine;
	
	import reprise.css.CSSParsingHelper;
	import reprise.css.CSSParsingResult;
	import reprise.css.CSSProperty;
	import reprise.css.CSSPropertyParser; 

	public class Transition extends CSSPropertyParser
	{
		public static var KNOWN_PROPERTIES : Array = 
		[
			'RepriseTransition',
			'RepriseTransitionProperty',
			'RepriseTransitionDuration',
			'RepriseTransitionTimingFunction',
			'RepriseTransitionDelay'
		];
		public static var EASINGS : Object = 
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
		
		public static function get defaultValues() : Object
		{
			return null;
		}
		
		
		public static function parseRepriseTransition(
			val:String, file:String) : CSSParsingResult
		{
			var obj : Object = CSSParsingHelper.removeImportantFlagFromString(val);
			var important : Boolean = obj.important;
			val = obj.result;
			
			var result : CSSParsingResult = new CSSParsingResult();
			
			var counter : Number = 0;
			
			var properties : Array = [];
			var durations : Array = [];
			var easings : Array = [];
			var delays : Array = [];
			
			for each (var part : String in val.split(','))
			{
				var partResult : Object = parseRepriseTransitionPart(part, file);
				if (partResult)
				{
					properties.push(
						CSSParsingHelper.camelCaseCSSValueName(partResult.property));
					durations.push(partResult.duration || null);
					easings.push(partResult.easing || null);
					delays.push(partResult.delay || null);
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
			
			return result;
		}
		public static function parseRepriseTransitionPart(
			str : String, file : String) : Object
		{
			var result : Object = {};
			
			var parts : Array = str.split(' ');
			
			var currentPart : String = parts.shift();
			
			//the first part has to be a property name
			if ('0123456789.'.indexOf(currentPart.charAt(0)) != -1)
			{
				return null;
			}
			//is property
			result.property = currentPart;
			if (!parts.length)
			{
				return result;
			}
			currentPart = parts.shift();
			//the second part has to be a duration
			if ('0123456789.'.indexOf(currentPart.charAt(0)) == -1)
			{
				return null;
			}
			result.duration = strToDurationProperty(currentPart, file);
			if (!parts.length)
			{
				return result;
			}
			currentPart = parts.shift();
			//the third part can be either an easing function name or a duration
			if ('0123456789.'.indexOf(currentPart.charAt(0)) == -1)
			{
				result.easing = 
					parseRepriseTransitionTimingFunctionPart(currentPart, file);
				currentPart = parts.shift();
			}
			else
			{
				//delay is the last part
				result.delay = strToDurationProperty(currentPart, file);
				if (parts.length)
				{
					//there shouldn't be any parts left
					return null;
				}
				return result;
			}
			if (!parts.length)
			{
				return result;
			}
			//the fourth part has to be a delay
			if ('0123456789.'.indexOf(currentPart.charAt(0)) == -1)
			{
				//anything but a duration is invalid here, return nothing
				return null;
			}
			result.delay = strToDurationProperty(currentPart, file);
			
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
			property.setSpecifiedValue(
				(intermediateResult.filteredString as String).split(',').
				map(CSSParsingHelper.camelCaseCSSValueName));
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
			
			for each (var entry : String in 
				(intermediateResult.filteredString as String).split(','))
			{
				entries.push(parseRepriseTransitionTimingFunctionPart(entry, file));
			}
			property.setSpecifiedValue(entries);
			return property;
		}
		public static function parseRepriseTransitionTimingFunctionPart(
			val:String, file : String) : CSSProperty
		{
			var intermediateResult : Object = strToProperty(val, file);
			var property : CSSProperty = intermediateResult.property;
			var easingName : String = 
				CSSParsingHelper.camelCaseCSSValueName(intermediateResult.filteredString);
			var regExp : RegExp = /ease(InOut|In|Out)(\w+)/;
			var matchResult : Array = regExp.exec(easingName);
			var easing : Function = EASINGS.linear;
			if (matchResult)
			{
				easing = EASINGS[matchResult[2]]['ease' + matchResult[1]];
			}
			property.setSpecifiedValue(easing);
			return property;
		}
	}
}