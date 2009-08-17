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
	import reprise.css.CSSProperty;
	import reprise.css.CSSPropertyParser;
	import reprise.css.transitions.BooleanTransitionVO;
	import reprise.css.transitions.ColorTransitionVO;		
	
	use namespace reprise;
	
	public class Font extends CSSPropertyParser
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const KNOWN_PROPERTIES : Object =
		{
			color : {parser : strToColorProperty, inheritable : true, transition : ColorTransitionVO},
			fontSize : {parser : strToIntProperty, inheritable : true},
			fontFamily : {parser : strToStringProperty, inheritable : true},
			embedFonts : {parser : parseEmbedFonts, inheritable : true},
			cacheAsBitmap : {parser : parseCacheAsBitmap},
			rasterizeDeviceFonts : {parser : parseRasterizeDeviceFonts, inheritable : true},
			antiAliasType : {parser : strToStringProperty, inheritable : true},
			gridFitType : {parser : strToStringProperty, inheritable : true},
			sharpness : {parser : strToIntProperty, inheritable : true},
			thickness : {parser : strToIntProperty, inheritable : true},
			fontWeight : {parser : strToStringProperty, inheritable : true},
			fontStyle : {parser : strToStringProperty, inheritable : true},
			textAlign : {parser : strToStringProperty, inheritable : true},
			textTransform : {parser : strToStringProperty, inheritable : true},
			letterSpacing : {parser : strToFloatProperty, inheritable : true},
			leading : {parser : strToIntProperty, inheritable : true},
			multiline : {parser : parseMultiline, transition : BooleanTransitionVO},
			wordWrap : {parser : strToStringProperty},
			selectable : {parser : strToBoolProperty, transition : BooleanTransitionVO}, 
			fontVariant : {parser : strToStringProperty},
			fixLineEndings : {parser : parseFixLineEndings},
			lineHeight : {parser : strToIntProperty}
		};
		
		public function Font() {}
		
		/***************************************************************************
		*							private methods								   *
		***************************************************************************/
		private static function parseEmbedFonts(val:String, file:String) : CSSProperty
		{		
			return strToBoolProperty(val, file, ['embed']);
		}
		
		private static function parseCacheAsBitmap(val:String, file:String) : CSSProperty
		{
			return strToBoolProperty(val, file, ['cache']);
		}
		
		private static function parseFixLineEndings(val:String, file:String) : CSSProperty
		{
			return strToBoolProperty(val, file, ['fix']);
		}
		
		private static function parseMultiline(val:String, file:String) : CSSProperty
		{
			return strToBoolProperty(val, file, ['multiline']);
		}
		
		private static function parseRasterizeDeviceFonts(
			val:String, file:String) : CSSProperty
		{
			return strToBoolProperty(val, file, ['rasterize']);
		}
	}
}