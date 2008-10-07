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
	import reprise.css.CSSParsingResult;
	import reprise.css.CSSProperty;
	import reprise.css.CSSPropertyParser;
	import reprise.css.transitions.VisibilityTransitionVO; 
	
	use namespace reprise;
	
	public class DisplayPosition extends CSSPropertyParser
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const KNOWN_PROPERTIES : Object =
		{
			display : {parser : strToStringProperty},
			position : {parser : strToStringProperty},
			overflow : {parser : parseOverflow},
			overflowX : {parser : strToStringProperty},
			overflowY : {parser : strToStringProperty},
			left : {parser : strToIntProperty},
			right : {parser : strToIntProperty},
			top : {parser : strToIntProperty},
			bottom : {parser : strToIntProperty},
			zIndex : {parser : strToIntProperty},
			width : {parser : strToIntProperty},
			height : {parser : strToIntProperty},
			minWidth : {parser : strToIntProperty},
			maxWidth : {parser : strToIntProperty},
			minHeight : {parser : strToIntProperty},
			maxHeight : {parser : strToIntProperty},
			boxSizing : {parser : strToStringProperty},
			clear : {parser : strToStringProperty},
			float : {parser : strToStringProperty},
			visibility : {parser : strToStringProperty, transition : VisibilityTransitionVO},
			cursor : {parser : parseCursor, inheritable : true},
			tooltipDelay : {parser : strToIntProperty},
			tooltipRenderer : {parser : strToStringProperty},
			blendMode : {parser : strToStringProperty},
			opacity : {parser : strToFloatProperty},
			frameRate : {parser : strToIntProperty}
		};
		
		
		public static const DISPLAY_BLOCK 			: String 	= "block";
		public static const DISPLAY_NONE 				: String 	= "none";
		public static const POSITION_STATIC 			: String 	= "static";
		public static const POSITION_ABSOLUTE 		: String 	= "absolute";
		public static const POSITION_RELATIVE 		: String 	= "relative";
		public static const POSITION_FIXED	 		: String 	= "fixed";
			                                                 
		public static const OVERFLOW_VISIBLE 			: String 	= "visible";
		public static const OVERFLOW_HIDDEN 			: String 	= "hidden";
		
		public static const VISIBILITY_VISIBLE		: String	= 'visible';
		public static const VISIBILITY_HIDDEN			: String	= 'hidden';
		
		public static const CURSOR_AUTO				: String	= 'auto';
		public static const CURSOR_POINTER			: String	= 'pointer';
		
	
		
		public function DisplayPosition() {}
		
		public static function parseOverflow(val:String, file:String):CSSParsingResult
		{
			var values:Array = val.split(' ');
			var overflowX:CSSProperty = strToStringProperty(values[0] as String, file);
			var overflowY:CSSProperty = values.length > 1 
				? strToStringProperty(values[1] as String, file) 
				: strToStringProperty(values[0] as String, file);
			return CSSParsingResult.ResultWithPropertiesAndKeys(
				overflowX, 'overflowX', overflowY, 'overflowY');
		}
		
		public static function parseCursor(val:String, file:String):CSSProperty
		{
			if (val.indexOf('url') != -1)
				return strToURLProperty(val, file);
			else
				return strToStringProperty(val, file);
		}
	}
}