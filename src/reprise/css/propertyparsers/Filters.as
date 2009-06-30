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
	import reprise.css.transitions.BooleanTransitionVO;	
	import reprise.core.reprise;
	import reprise.css.CSSParsingHelper;
	import reprise.css.CSSParsingResult;
	import reprise.css.CSSProperty;
	import reprise.css.CSSPropertyParser;
	import reprise.css.transitions.ColorTransitionVO;
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
			backgroundShadowColor : {parser : strToColorProperty, transition : ColorTransitionVO},
			backgroundShadowXBlur : {parser : strToIntProperty},
			backgroundShadowYBlur : {parser : strToIntProperty},
			backgroundShadowStrength : {parser : strToIntProperty},
			backgroundShadowInner : {parser : strToBoolProperty},
			backgroundShadowKnockout : {parser : strToBoolProperty, transition : BooleanTransitionVO}, 
			backgroundShadowHideObject : {parser : strToBoolProperty, transition : BooleanTransitionVO},
			textShadow : {parser : parseTextShadow},
			textShadowXOffset : {parser : strToIntProperty},
			textShadowYOffset : {parser : strToIntProperty},
			textShadowColor : {parser : strToColorProperty, transition : ColorTransitionVO},
			textShadowXBlur : {parser : strToIntProperty},
			textShadowYBlur : {parser : strToIntProperty},
			textShadowStrength : {parser : strToIntProperty},
			textShadowInner : {parser : strToBoolProperty, transition : BooleanTransitionVO},
			textShadowKnockout : {parser : strToBoolProperty, transition : BooleanTransitionVO},
			textShadowHideObject : {parser : strToBoolProperty, transition : BooleanTransitionVO}
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
			
			if (parts.length == 1 && parts[0] == 'none')
			{
				var prop : CSSProperty = new CSSProperty();
				prop.setSpecifiedValue(null);
				prop.setImportant(obj.important);
				prop.setCSSFile(file);
				res.addPropertyForKey(prop, name + 'ShadowColor');
				return res;
			}
			
			var counter : int = 0;
			var part : String = parts[counter++];
			if (CSSParsingHelper.valueIsColor(part))
			{
				res.addPropertyForKey(strToColorProperty(part + important, file), 
					name + 'ShadowColor');
			}

			if (parts.length < 3)
			{
				part = parts[counter++];
				res.addPropertyForKey(strToIntProperty(part + important, file), 
					name + 'ShadowXOffset');
				res.addPropertyForKey(strToIntProperty(part + important, file), 
					name + 'ShadowYOffset');
				return res;
			}
			
			part = parts[counter++];
			res.addPropertyForKey(strToIntProperty(part + important, file), 
				name + 'ShadowXOffset');
			part = parts[counter++];
			res.addPropertyForKey(strToIntProperty(part + important, file), 
					name + 'ShadowYOffset');
			
			if (counter == parts.length)
			{
				return res;
			}
			
			part = parts[counter++];
			res.addPropertyForKey(strToIntProperty(part + important, file), 
				name + 'ShadowXBlur');
			if (counter <= parts.length)
			{
				part = parts[counter++];				
			}
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