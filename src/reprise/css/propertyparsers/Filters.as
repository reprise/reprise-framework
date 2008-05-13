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
	import reprise.data.AdvancedColor;
	import reprise.geom.Vector;
	import reprise.utils.StringUtil;
	
	import flash.filters.DropShadowFilter;
	
	
	public class Filters extends CSSPropertyParser
	{
		
		public static var KNOWN_PROPERTIES	: Array =
		[
			'backgroundShadow',
			'backgroundShadowXOffset',
			'backgroundShadowYOffset',
			'backgroundShadowColor',
			'backgroundShadowXBlur',
			'backgroundShadowYBlur',
			'backgroundShadowStrength',
			'backgroundShadowInner',
			'backgroundShadowKnockout',
			'backgroundShadowHideObject',
			'textShadow',
			'textShadowXOffset',
			'textShadowYOffset',
			'textShadowColor',
			'textShadowXBlur',
			'textShadowYBlur',
			'textShadowStrength',
			'textShadowInner',
			'textShadowKnockout',
			'textShadowHideObject'		
		];
		
		
		public function Filters() {}
		
		public static function get defaultValues() : Object
		{
			return null;
		}
		
		// color x-offset y-offset blur	
		protected static function parseShadow(name:String, val:String, file:String) : CSSParsingResult
		{
			// evaluate important flag
			var obj : Object = CSSParsingHelper.removeImportantFlagFromString(val);
			var important : String = obj.important ? CSSProperty.IMPORTANT_FLAG : '';
			val = obj.result;
			
			var res : CSSParsingResult = new CSSParsingResult();
			
			var parts : Array = val.split(' ');
			var counter : Number = 0;
			var part : String = parts[counter++];
			var methName : String = StringUtil.ucFirst(name);
			
			if (CSSParsingHelper.valueIsColor(part))
			{
				res.addPropertyForKey(Filters['parse' + methName + 'ShadowColor'](part + important, file), 
					name + 'ShadowColor');
				part = parts[counter++];
			}
			if (parts.length == 4)
			{
				res.addPropertyForKey(Filters['parse' + methName + 'ShadowXOffset'](part + important, file), 
					name + 'ShadowXOffset');
				part = parts[counter++];					
				res.addPropertyForKey(Filters['parse' + methName + 'ShadowYOffset'](part + important, file), 
						name + 'ShadowYOffset');
			}
			else if (parts.length < 4)
			{
				res.addPropertyForKey(Filters['parse' + methName + 'ShadowXOffset'](part + important, file), 
					name + 'ShadowXOffset');
				res.addPropertyForKey(Filters['parse' + methName + 'ShadowYOffset'](part + important, file), 
				name + 'ShadowYOffset');
			}
			part = parts[counter++];
			res.addPropertyForKey(Filters['parse' + methName + 'ShadowXBlur'](part + important, file), 
				name + 'ShadowXBlur');
			res.addPropertyForKey(Filters['parse' + methName + 'ShadowYBlur'](part + important, file), 
			 	name + 'ShadowYBlur');
					
			return res;
		}
		
		public static function parseBackgroundShadow(val:String, file:String) : CSSParsingResult
		{
			return parseShadow('background', val, file);
		}
		
		public static function parseBackgroundShadowXOffset(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseBackgroundShadowYOffset(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseBackgroundShadowColor(val:String, file:String) : CSSProperty
		{
			return strToColorProperty(val, file);
		}
		
		public static function parseBackgroundShadowXBlur(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseBackgroundShadowYBlur(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseBackgroundShadowStrength(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseBackgroundShadowInner(val:String, file:String) : CSSProperty
		{
			return strToBoolProperty(val, null, file);
		}
		
		public static function parseBackgroundShadowKnockout(val:String, file:String) : CSSProperty
		{
			return strToBoolProperty(val, null, file);
		}
		
		public static function parseBackgroundHideObject(val:String, file:String) : CSSProperty
		{
			return strToBoolProperty(val, null, file);
		}
		
		public static function parseTextShadow(val:String, file:String) : CSSParsingResult
		{
			return parseShadow('text', val, file);
		}
		
		public static function parseTextShadowXOffset(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseTextShadowYOffset(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseTextShadowColor(val:String, file:String) : CSSProperty
		{
			return strToColorProperty(val, file);
		}
		
		public static function parseTextShadowXBlur(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseTextShadowYBlur(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseTextShadowStrength(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseTextShadowInner(val:String, file:String) : CSSProperty
		{
			return strToBoolProperty(val, null, file);
		}
		
		public static function parseTextShadowKnockout(val:String, file:String) : CSSProperty
		{
			return strToBoolProperty(val, null, file);
		}
		
		public static function parseTextHideObject(val:String, file:String) : CSSProperty
		{
			return strToBoolProperty(val, null, file);
		}
		
		
		
		public static function dropShadowFilterFromStyleObjectForName(
			styleObj:Object, name:String) : DropShadowFilter
		{
			var color : AdvancedColor = styleObj[name + 'ShadowColor'];
			var offset : Vector = new Vector(styleObj[name + 'ShadowXOffset'], 
				styleObj[name + 'ShadowYOffset']);
			var blurX : Number = styleObj[name + 'ShadowXBlur'];
			var blurY : Number = styleObj[name + 'ShadowYBlur'];
			var strength : Number = styleObj[name + 'ShadowStrength'];
			var quality : Number = styleObj[name + 'ShadowQuality'];
			var inner : Boolean = styleObj[name + 'ShadowInner'];
			var knockout : Boolean = styleObj[name + 'ShadowKnockout'];
			var hideObject : Boolean = styleObj[name + 'ShadowHideObject'];
			
			if (isNaN(blurX))
			{
				blurX = 0;
			}
			if (isNaN(blurY))
			{
				blurY = 0;
			}
			if (isNaN(strength))
			{
				strength = 1;
			}
			if (isNaN(quality))
			{
				quality = 3;
			}
					
			var filter : DropShadowFilter = new DropShadowFilter(
				offset.getLength(), offset.angle(), color.rgb(), color.opacity(), blurX, blurY, 
				strength, quality, inner, knockout, hideObject);				
			return filter;
		}	
	}
}