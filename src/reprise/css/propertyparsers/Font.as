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
	import reprise.css.transitions.ColorTransitionVO;
	
	
	
	public class Font extends CSSPropertyParser
	{
		
		public static var KNOWN_PROPERTIES			: Array		=
		[
			/*'font', soon! */
			'color',
			'fontSize',
			'fontFamily',
			'embedFonts',
			'cacheAsBitmap',
			'rasterizeDeviceFonts',
			'antiAliasType',
			'gridFitType',
			'sharpness',
			'thickness',
			'fontWeight',
			'fontStyle',
			'textAlign',
			'textTransform',
			'letterSpacing',
			'leading',
			'multiline',
			'wordWrap',
			'selectable',
			'fontVariant',
			'fixLineEndings',
			'lineHeight'
		];
		
		public static var INHERITABLE_PROPERTIES	: Object	=
		{
			color : true,
			fontSize : true,
			fontFamily : true,
			embedFonts : true,
			antiAliasType : true,
			gridFitType : true,
			sharpness : true,
			thickness : true,
			fontWeight : true,
			fontStyle : true,
			textAlign : true,
			textTransform : true,
			letterSpacing : true,
			leading : true,
			rasterizeDeviceFonts : true
		};
		
		public static var PROPERTY_TRANSITIONS	: Object	=
		{
			color : ColorTransitionVO
		};
		
		
		
		public function Font() {}
		
		public static function get defaultValues() : Object
		{
			return null;
		}
		
		
		
		public static function setFont(val:String, file:String) : void
		{
			/*
			// evaluate important flag
			var obj : Object = CSSParsingHelper.removeImportantFlagFromString(val);
			var important : String = obj.important ? CSSProperty.IMPORTANT_FLAG : '';
			val = obj.result;
			
			font-style, 
			font-variant, 
			font-weight, 
			font-size, 
			line-height
			font-family
			z.B. font:italic bold 13px Times;
			*/
		}
		
		public static function parseColor(val:String, file:String) : CSSProperty
		{
			return strToColorProperty(val, file);
		}
		
		public static function parseFontSize(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseFontFamily(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseEmbedFonts(val:String, file:String) : CSSProperty
		{		
			return strToBoolProperty(val, ['embed'], file);
		}
		
		public static function parseCacheAsBitmap(val:String, file:String) : CSSProperty
		{
			return strToBoolProperty(val, ['cache'], file);
		}
		
		public static function parseAntiAliasType(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseGridFitType(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseSharpness(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseThickness(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseFontWeight(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}
	
		public static function parseFontStyle(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseTextAlign(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseTextTransform(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseLetterSpacing(val:String, file:String) : CSSProperty
		{
			return strToFloatProperty(val, file);
		}
		
		public static function parseLeading(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseWordWrap(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseMultiline(val:String, file:String) : CSSProperty
		{
			return strToBoolProperty(val, null, file);
		}
		
		public static function parseSelectable(val:String, file:String) : CSSProperty
		{
			return strToBoolProperty(val, null, file);
		}
		
		public static function parseFontVariant(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseLineHeight(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseFixLineEndings(val:String, file:String) : CSSProperty
		{
			return strToBoolProperty(val, null, file);
		}
		
		public static function parseRasterizeDeviceFonts(val:String, file:String) : CSSProperty
		{
			return strToBoolProperty(val, ['rasterize', 'true'], file);
		}
	}
}