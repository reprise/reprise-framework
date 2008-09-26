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
	import reprise.data.AdvancedColor;
	import reprise.geom.Vector;
	
	import flash.filters.DropShadowFilter;
	
	use namespace reprise;
	
	public class Filters extends CSSPropertyParser
	{
		
		public static var KNOWN_PROPERTIES : Object =
		{
			backgroundShadow : {parser : parseBackgroundShadow},
			backgroundShadowXOffset : {parser : strToIntProperty},
			backgroundShadowYOffset : {parser : strToIntProperty},
			backgroundShadowColor : {parser : strToColorProperty},
			backgroundShadowXBlur : {parser : strToIntProperty},
			backgroundShadowYBlur : {parser : strToIntProperty},
			backgroundShadowStrength : {parser : strToIntProperty},
			backgroundShadowInner : {parser : strToBoolProperty},
			backgroundShadowKnockout : {parser : strToBoolProperty},
			backgroundShadowHideObject : {parser : strToBoolProperty},
			textShadow : {parser : parseTextShadow},
			textShadowXOffset : {parser : strToIntProperty},
			textShadowYOffset : {parser : strToIntProperty},
			textShadowColor : {parser : strToColorProperty},
			textShadowXBlur : {parser : strToIntProperty},
			textShadowYBlur : {parser : strToIntProperty},
			textShadowStrength : {parser : strToIntProperty},
			textShadowInner : {parser : strToBoolProperty},
			textShadowKnockout : {parser : strToBoolProperty},
			textShadowHideObject : {parser : strToBoolProperty}
		};
		
		
		public function Filters() {}
		
		public static function parseBackgroundShadow(val:String, file:String) : CSSParsingResult
		{
			return parseShadow('background', val, file);
		}
		
		public static function parseTextShadow(val:String, file:String) : CSSParsingResult
		{
			return parseShadow('text', val, file);
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
			
			if (CSSParsingHelper.valueIsColor(part))
			{
				res.addPropertyForKey(strToColorProperty(part + important, file), 
					name + 'ShadowColor');
				part = parts[counter++];
			}
			if (parts.length == 4)
			{
				res.addPropertyForKey(strToIntProperty(part + important, file), 
					name + 'ShadowXOffset');
				part = parts[counter++];					
				res.addPropertyForKey(strToIntProperty(part + important, file), 
						name + 'ShadowYOffset');
			}
			else if (parts.length < 4)
			{
				res.addPropertyForKey(strToIntProperty(part + important, file), 
					name + 'ShadowXOffset');
				res.addPropertyForKey(strToIntProperty(part + important, file), 
				name + 'ShadowYOffset');
			}
			part = parts[counter++];
			res.addPropertyForKey(strToIntProperty(part + important, file), 
				name + 'ShadowXBlur');
			res.addPropertyForKey(strToIntProperty(part + important, file), 
			 	name + 'ShadowYBlur');
					
			return res;
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