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
	import reprise.css.CSSParsingHelper;
	import reprise.css.CSSParsingResult;
	import reprise.css.CSSProperty;
	import reprise.css.CSSPropertyParser;
	import reprise.css.transitions.ColorListTransitionVO;
	import reprise.css.transitions.ColorTransitionVO;
	import reprise.css.transitions.NumericListTransitionVO;
	import reprise.utils.StringUtil;
	
	
	public class Background extends CSSPropertyParser
	{
			
		public static var KNOWN_PROPERTIES	: Array		=
		[
			'background',
			'backgroundImage',
			'backgroundColor',
			'backgroundRepeat',
			'backgroundPosition',
			'backgroundAttachment',
			'backgroundRenderer',
			'backgroundBlendMode',
			'backgroundGradient',
			'backgroundGradientColors',
			'backgroundGradientType',
			'backgroundGradientRatios',
			'backgroundGradientRotation',
			'backgroundScale9',
			'backgroundScale9Type',
			'backgroundScale9Rect',
			'backgroundScale9RectTop',
			'backgroundScale9RectRight',
			'backgroundScale9RectBottom',
			'backgroundScale9RectLeft',
			'backgroundImageType',
			'backgroundImagePreload',
			'backgroundImageAliasing'
		];
		
		public static var PROPERTY_TRANSITIONS	: Object	=
		{
			backgroundColor : ColorTransitionVO,
			backgroundGradientRatios : NumericListTransitionVO,
			backgroundGradientColors : ColorListTransitionVO
		};
		
		public static var TRANSITION_SHORTCUTS : Object	=
		{
			backgroundScale9Rect :
			[
				'backgroundScale9RectTop',
				'backgroundScale9RectRight',
				'backgroundScale9RectBottom',
				'backgroundScale9RectLeft'
			],
			backgroundGradient : 
			[
				'backgroundGradientColors',
				'backgroundGradientRatios',
				'backgroundGradientRotation'
			]
		};
		
		public static var REPEAT_REPEAT_XY	: String	= 'repeat';	/* default */
		public static var REPEAT_REPEAT_X	: String	= 'repeat-x';
		public static var REPEAT_REPEAT_Y	: String	= 'repeat-y';
		public static var REPEAT_NO_REPEAT	: String	= 'no-repeat';
		
		public static var ATTACHMENT_SCROLL	: String	= 'scrollV';	/* default */
		public static var ATTACHMENT_FIXED	: String	= 'fixed';
		
		public static var POSITION_TOP		: String	= 'top';
		public static var POSITION_BOTTOM	: String	= 'bottom';
		public static var POSITION_LEFT		: String	= 'left';
		public static var POSITION_RIGHT	: String	= 'right';
		public static var POSITION_CENTER	: String	= 'center';
		
		public static var GRADIENT_TYPE_LINEAR : String	= 'linear';
		public static var GRADIENT_TYPE_RADIAL : String = 'radial';
		
		public static var SCALE9_TYPE_STRETCH : String 	= 'stretch';
		public static var SCALE9_TYPE_REPEAT : String	= 'repeat';
		public static var SCALE9_TYPE_NONE : String	= 'none';
		
		public static var IMAGE_TYPE_IMAGE : String = 'image';
		public static var IMAGE_TYPE_ANIMATION : String = 'animation';
		public static var IMAGE_NONE : String = 'none';
		
		public static var IMAGE_ALIASING_ALIAS : String = 'alias';
		public static var IMAGE_ALIASING_ANTIALIAS : String = 'anti-alias';
		
		
		protected static var g_backgroundExpression : RegExp;
		
		
		
				
		public function Background() {}
		
		public static function get defaultValues() : Object
		{
			return null;
		}
		
		
		public static function parseBackground(val:String, file:String) : CSSParsingResult
		{
			// evaluate important flag
			var obj : Object = CSSParsingHelper.removeImportantFlagFromString(val);
			var important : String = obj.important ? CSSProperty.IMPORTANT_FLAG : '';
			val = obj.result;
			
			var res : CSSParsingResult = new CSSParsingResult();
			
			var result : Array;
			
			//get image value
			//(has to be done first because the url can contain pretty much everything else
			result = val.match(CSSParsingHelper.URIExpression);
			if (result)
			{
				res.addPropertyForKey(
					strToURLProperty(result[0] + important, file), 'backgroundImage');
				val = val.split(result[0]).join('');
			}
			
			//get color value
			result = val.match(CSSParsingHelper.colorExpression);
			if (result)
			{
				res.addPropertyForKey(
					strToColorProperty(result[0] + important, file), 'backgroundColor');
				val = val.split(result[0]).join('');
			}
			
			//get repeat value
			result = val.match(CSSParsingHelper.repeatExpression);
			if (result)
			{
				res.addPropertyForKey(
					strToStringProperty(result[0] + important, file), 'backgroundRepeat');
				val = val.split(result[0]).join('');
			}
			
			//get attachment value
			result = val.match(CSSParsingHelper.attachmentExpression);
			if (result)
			{
				res.addPropertyForKey(strToStringProperty(
					result[0] + important, file), 'backgroundAttachment');
				val = val.split(result[0]).join('');
			}
			
			//get position value
			result = val.match(CSSParsingHelper.positionExpression);
			if (result && result[0])
			{
				res.addEntriesFromResult(
					parseBackgroundPosition(result[0] + important, file));
			}
			
			//get preload value
			result = val.match(CSSParsingHelper.preloadExpression);
			if (result)
			{
				res.addPropertyForKey(parseBackgroundImagePreload(
					result[0] + important, file), 'backgroundImagePreload');
			}
			return res;
		}
		
		public static function parseBackgroundGradient(val:String, file:String) : CSSParsingResult
		{
			// evaluate important flag
			var obj : Object = CSSParsingHelper.removeImportantFlagFromString(val);
			var important : String = obj.important ? CSSProperty.IMPORTANT_FLAG : '';
			val = obj.result;
			
			var res : CSSParsingResult = new CSSParsingResult();
		
			// extract ratios
			var sliceResult : Object = 
				StringUtil.sliceStringBetweenMarkers(val, 'ratios(', ')', true, true);
			val = sliceResult.result;
			var ratiosPart : String = sliceResult.slice;
			
			// extract colors
			sliceResult = StringUtil.sliceStringBetweenMarkers(val, 'colors(', ')', true, true);
			val = sliceResult.result;
			var colorsPart : String = sliceResult.slice;
			
			var counter : Number = 0;
			var parts : Array = val.split(' ');
			var part : String;
			var lcPart : String;
			
			var gradientTypeLookup : Array = [];
			gradientTypeLookup[GRADIENT_TYPE_LINEAR] = true;
			gradientTypeLookup[GRADIENT_TYPE_RADIAL] = true;
			
			// type
			part = parts[counter];
			lcPart = part.toLowerCase();
			if (gradientTypeLookup[lcPart])
			{
				res.addPropertyForKey(strToStringProperty(lcPart + important, file),
					'backgroundGradientType');
				part = parts[++counter];
			}
			
			// rotation
			if (part != null && !isNaN(parseInt(part)))
			{
				res.addPropertyForKey(strToIntProperty(part, file), 'backgroundGradientRotation');
				part = parts[++counter];
			}
			
			if (colorsPart != null)
			{
				res.addPropertyForKey(
					parseBackgroundGradientColors(
						colorsPart + important, file), 
					'backgroundGradientColors');
			}
			
			if (ratiosPart != null)
			{
				res.addPropertyForKey(
					parseBackgroundGradientRatios(
						ratiosPart + important, file),
					'backgroundGradientRatios');
			}
			
			return res;
		}
		
		public static function parseBackgroundImage(val:String, file:String) : CSSProperty
		{
			return strToURLProperty(val, file);
		}
		
		public static function parseBackgroundColor(val:String, file:String) : CSSProperty
		{
			return strToColorProperty(val, file);
		}
		
		public static function parseBackgroundRepeat(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseBackgroundPosition(val:String, file:String) : CSSParsingResult
		{		
			// evaluate important flag
			var obj : Object = CSSParsingHelper.removeImportantFlagFromString(val);
			var important : String = obj.important ? CSSProperty.IMPORTANT_FLAG : '';
			val = obj.result;
			
			val = val.split(POSITION_TOP).join('0%').split(POSITION_RIGHT).join('100%').
				split(POSITION_BOTTOM).join('100%').split(POSITION_LEFT).join('0%');
			var parts : Array = val.split(" ");
			
			return CSSParsingResult.ResultWithPropertiesAndKeys(
				strToIntProperty(parts[0] + important, file), 'backgroundPositionX',
				strToIntProperty(parts[1] + important, file), 'backgroundPositionY');
		}
		
		public static function parseBackgroundAttachment(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseBackgroundRenderer(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseBackgroundBlendMode(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseBackgroundGradientType(val:String, file:String) : CSSProperty
		{
			var prop : CSSProperty = strToStringProperty(val, file);
			if (prop.specifiedValue() == GRADIENT_TYPE_RADIAL ||
				prop.specifiedValue() == GRADIENT_TYPE_LINEAR)
			{
				return prop;
			}
			return null;
		}
		
		public static function parseBackgroundGradientRotation(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseBackgroundGradientColors(val:String, file:String) : CSSProperty
		{
			var obj : Object = CSSParsingHelper.removeImportantFlagFromString(val);
			var important : String = obj.important ? CSSProperty.IMPORTANT_FLAG : '';
			val = obj.result;
			
			var prop : CSSProperty = new CSSProperty();
			prop.setImportant(obj.important);
			prop.setCSSFile(file);
			
			if (CSSParsingHelper.valueShouldInherit(val))
			{
				prop.setInheritsValue(true);
				return prop;
			}		
			
			var parts : Array = val.split(' ');
			var colors : Array = [];
			var i : Number;
			
			for (i = 0; i < parts.length; i++)
			{
				colors.push(CSSParsingHelper.parseColor(parts[i]));
			}
			
			prop.setSpecifiedValue(colors);
			return prop;
		}
		
		public static function parseBackgroundGradientRatios(val:String, file:String) : CSSProperty
		{
			var obj : Object = CSSParsingHelper.removeImportantFlagFromString(val);
			var important : String = obj.important ? CSSProperty.IMPORTANT_FLAG : '';
			val = obj.result;
			
			var prop : CSSProperty = new CSSProperty();
			prop.setImportant(obj.important);
			prop.setCSSFile(file);
			
			if (CSSParsingHelper.valueShouldInherit(val))
			{
				prop.setInheritsValue(true);
				return prop;
			}		
			
			var parts : Array = val.split(' ');
			var ratios : Array = [];
			var i : Number;
			
			for (i = 0; i < parts.length; i++)
			{
				ratios.push(parseInt(parts[i]));
			}
			
			prop.setSpecifiedValue(ratios);
			return prop;
		}
		
		
		public static function parseBackgroundScale9(val:String, file:String) : CSSParsingResult
		{
			// evaluate important flag
			var obj : Object = CSSParsingHelper.removeImportantFlagFromString(val);
			var important : String = obj.important ? CSSProperty.IMPORTANT_FLAG : '';
			val = obj.result;
			
			var res : CSSParsingResult = new CSSParsingResult();		
			
			var typeMap : Array = [];
			typeMap[SCALE9_TYPE_REPEAT] = true;
			typeMap[SCALE9_TYPE_STRETCH] = true;
			typeMap[SCALE9_TYPE_NONE] = true;
			var parts : Array = val.split(' ');
			if (typeMap[parts[0]])
			{
				res.addPropertyForKey(
					parseBackgroundScale9Type(String(parts.shift()) + important, file),
					'backgroundScale9Type');
			}
			val = parts.join(' ');
			res.addEntriesFromResult(parseBackgroundScale9Rect(val, file));
			return res;
		}
		
		public static function parseBackgroundScale9Type(val:String, file:String) : CSSProperty
		{
			if (val == SCALE9_TYPE_REPEAT)
				return strToStringProperty(SCALE9_TYPE_REPEAT, file);
			else if (val == SCALE9_TYPE_STRETCH)
				return strToStringProperty(SCALE9_TYPE_STRETCH, file);
			else
				return strToStringProperty(SCALE9_TYPE_NONE, file);
		}
		
		public static function parseBackgroundScale9Rect(val:String, file:String) : CSSParsingResult
		{
			return strToRectParsingResult(val, file, 'backgroundScale9Rect');
		}
		
		public static function parseBackgroundScale9RectTop(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseBackgroundScale9RectRight(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseBackgroundScale9RectBottom(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseBackgroundScale9RectLeft(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseBackgroundImageType(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val.toLowerCase(), file);
		}
		
		public static function parseBackgroundImagePreload(val:String, file:String) : CSSProperty
		{		
			return strToBoolProperty(val, ['preload'], file);
		}
		
		public static function parseBackgroundImageAliasing(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val.toLowerCase(), file);
		}
	}
}