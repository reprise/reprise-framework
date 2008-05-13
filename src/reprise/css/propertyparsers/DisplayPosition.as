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
	
	
	
	public class DisplayPosition extends CSSPropertyParser
	{
			
		public static var KNOWN_PROPERTIES			: Array	 	=
		[
			'display',
			'position',
			'overflow',
			'left',
			'right',
			'top',
			'bottom',
			'zIndex',
			'width',
			'outerWidth',
			'minWidth',
			'maxWidth',
			'height',
			'outerHeight',
			'minHeight',
			'maxHeight',
			'clear',
			'float',
			'visibility',
			'itemSpacing',
			'cursor',
			'tooltipDelay',
			'tooltipRenderer',
			'blendMode',
			'opacity',
			'frameRate'
			/* clip */
		];
		
		public static var INHERITABLE_PROPERTIES	: Object	=
		{
			cursor:true
		};
		
		
		public static var DISPLAY_BLOCK 			: String 	= "block";
		public static var DISPLAY_NONE 				: String 	= "none";
		public static var POSITION_STATIC 			: String 	= "static";
		public static var POSITION_ABSOLUTE 		: String 	= "absolute";
		public static var POSITION_RELATIVE 		: String 	= "relative";
			                                                 
		public static var OVERFLOW_VISIBLE 			: String 	= "visible";
		public static var OVERFLOW_HIDDEN 			: String 	= "hidden";
		
		public static var VISIBILITY_VISIBLE		: String	= 'visible';
		public static var VISIBILITY_HIDDEN			: String	= 'hidden';
		
		public static var CURSOR_AUTO				: String	= 'auto';
		public static var CURSOR_POINTER			: String	= 'pointer';
		
	
		
		public function DisplayPosition() {}
		
		
		
		public static function get defaultValues() : Object
		{
			var defaults:Object = {};
			var width:CSSProperty = defaults.width = new CSSProperty();
			width.setSpecifiedValue('auto');
			var height:CSSProperty = defaults.height = new CSSProperty();
			height.setSpecifiedValue('auto');
			return defaults;
		}
		
		
		
		public static function parseDisplay(val:String, file:String):CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parsePosition(val:String, file:String):CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseOverflow(val:String, file:String):CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseLeft(val:String, file:String):CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseRight(val:String, file:String):CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseTop(val:String, file:String):CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseBottom(val:String, file:String):CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseZIndex(val:String, file:String):CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseWidth(val:String, file:String):CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseOuterWidth(val:String, file:String):CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseMinWidth(val:String, file:String):CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseMaxWidth(val:String, file:String):CSSProperty
		{
			return strToIntProperty(val, file);
		}		
		
		public static function parseHeight(val:String, file:String):CSSProperty
		{
			return strToIntProperty(val, file);
		}		
		
		public static function parseOuterHeight(val:String, file:String):CSSProperty
		{
			return strToIntProperty(val, file);
		}	
		
		public static function parseMinHeight(val:String, file:String):CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseMaxHeight(val:String, file:String):CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseFloat(val:String, file:String):CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseClear(val:String, file:String):CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseVisibility(val:String, file:String):CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseItemSpacing(val:String, file:String):CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseCursor(val:String, file:String):CSSProperty
		{
			if (val.indexOf('url') != -1)
				return strToURLProperty(val, file);
			else
				return strToStringProperty(val, file);
		}
		
		public static function parseTooltipDelay(val:String, file:String):CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseTooltipRenderer(val:String, file:String):CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseBlendMode(val:String, file:String):CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseOpacity(val:String, file:String):CSSProperty
		{
			return strToFloatProperty(val, file);
		}
		
		public static function parseFrameRate(val:String, file:String):CSSProperty
		{
			return strToIntProperty(val, file);
		}
	}
}