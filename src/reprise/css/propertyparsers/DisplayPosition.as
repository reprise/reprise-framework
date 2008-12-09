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
	import reprise.utils.GeomUtil;	
	
	import flash.geom.Matrix;	
	
	import reprise.core.reprise;
	import reprise.css.CSSParsingResult;
	import reprise.css.CSSProperty;
	import reprise.css.CSSPropertyParser;
	import reprise.css.transitions.VisibilityTransitionVO;
	import reprise.utils.StringUtil;	
	
	use namespace reprise;
	
	public class DisplayPosition extends CSSPropertyParser
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const KNOWN_PROPERTIES : Object =
		{
			display : {parser : strToStringProperty, transition : VisibilityTransitionVO},
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
			frameRate : {parser : strToIntProperty},
			rotation : {parser : strToFloatProperty},
			transform : {parser : parseTransform},
			transformOrigin : {parser : parseTransformOrigin},
			transformOriginX : {parser : strToIntProperty},
			transformOriginY : {parser : strToIntProperty}
		};
		public static var TRANSITION_SHORTCUTS : Object	=
		{
			transformOrigin : 
			[
				'transformOriginX',
				'transformOriginY'
			]
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
		
		public static function parseTransform(val:String, file:String) : CSSProperty
		{
			var obj : Object = strToProperty(val, file);
			var prop : CSSProperty = obj.property;
			
			if (prop.inheritsValue())
			{
				return prop;
			}
			
			val = StringUtil.trim(obj.filteredString);
			var transforms : Array = [];
			var transformTypes : String = '';
			
			//extract all transforms in order
			var regexp : RegExp = /(\w+)\((.*?)\)/g;
			while (true)
			{
				var result : Array = regexp.exec(val);
				if (!result) break;
				
				var rawParams : Array = result[2].split(/\s*,\s*/);
				var parameters : Array = [];
				var type : String = result[1];
				var transform : Object = {type : type, parameters : parameters};
				var i : int;
				
				transformTypes += type + ',';
				
				switch (type)
				{
					case 'translate' : 
					{
						parameters[0] = strToFloatProperty(rawParams[0], file);
						if (rawParams.length == 1)
						{
							parameters[1] = parameters[0];
						}
						else
						{
							parameters[1] = strToFloatProperty(rawParams[1], file);
						}
						break;
					}
					case 'scale' : 
					{
						parameters[0] = parseFloat(rawParams[0]);
						if (rawParams.length == 1)
						{
							parameters[1] = parameters[0];
						}
						else
						{
							parameters[1] = parseFloat(rawParams[1]);
						}
						break;
					}
					case 'rotate' : 
					{
						parameters[0] = parseFloat(rawParams[0]) * Math.PI / 180;
						if (rawParams.length == 1)
						{
							parameters[1] = parameters[0];
						}
						else
						{
							parameters[1] = parseFloat(rawParams[1]) * Math.PI / 180;
						}
						break;
					}
					case 'skew' : 
					{
						parameters[0] = 
							Math.tan(parseFloat(rawParams[0]) * Math.PI / 180);
						if (rawParams.length == 1)
						{
							parameters[1] = 0;
						}
						else
						{
							parameters[1] = 
								Math.tan(parseFloat(rawParams[1]) * Math.PI / 180);
						}
						break;
					}
					case 'skewX' : 
					case 'skewY' : 
					{
						parameters[0] = 
							Math.tan(parseFloat(rawParams[0]) * Math.PI / 180);
						break;
					}
					case 'matrix' : 
					{
						parameters[0] = GeomUtil.CSSMatrixParametersToMatrix(rawParams);
						break;
					}
					default : 
					{
						for (i = rawParams.length; i--;)
						{
							parameters[i] = parseFloat(rawParams[i]);
						}
						break;
					}
				}
				transforms.push(transform);
			}
			transforms.transformTypes = transformTypes;
			
			prop.setSpecifiedValue(transforms);
			
			return prop;
		}
		
		public static function parseTransformOrigin(
			val:String, file:String) : CSSParsingResult
		{
			var values:Array = val.split(' ');
			var originX:CSSProperty = strToIntProperty(values[0], file);
			var originY:CSSProperty = values.length > 1 
				? strToIntProperty(values[1], file) 
				: originX;
			return CSSParsingResult.ResultWithPropertiesAndKeys(
				originX, 'transformOriginX', originY, 'transformOriginY');
		}
	}
}