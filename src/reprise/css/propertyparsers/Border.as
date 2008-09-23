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
	import reprise.css.transitions.ColorTransitionVO;
	import reprise.utils.StringUtil;
	
	
	
	
	public class Border extends CSSPropertyParser
	{
			
		public static var KNOWN_PROPERTIES	: Array 	= 
		[
			'border',
			'borderTop',
			'borderRight',
			'borderBottom',
			'borderLeft',
			'borderStyle',
			'borderColor',
			'borderWidth',
			'borderTopWidth',
			'borderRightWidth',
			'borderBottomWidth',
			'borderLeftWidth',
			'borderTopStyle',
			'borderRightStyle',
			'borderBottomStyle',
			'borderLeftStyle',
			'borderTopColor',
			'borderRightColor',
			'borderBottomColor',
			'borderLeftColor',
			'borderRenderer',
			'borderRadius',
			'borderTopLeftRadius',
			'borderTopRightRadius',
			'borderBottomRightRadius',
			'borderBottomLeftRadius'
		];
		
		public static var PROPERTY_TRANSITIONS : Object	=
		{
			borderTopColor : ColorTransitionVO,
			borderRightColor : ColorTransitionVO,
			borderBottomColor : ColorTransitionVO,
			borderLeftColor : ColorTransitionVO
		};
		
		public static var TRANSITION_SHORTCUTS : Object	=
		{
			border : 
			[
				'borderTopWidth',
				'borderRightWidth',
				'borderBottomWidth',
				'borderLeftWidth',
				'borderTopColor',
				'borderRightColor',
				'borderBottomColor',
				'borderLeftColor'
			],
			borderWidth : 
			[
				'borderTopWidth',
				'borderRightWidth',
				'borderBottomWidth',
				'borderLeftWidth'
			],
			borderColor : 
			[
				'borderTopColor',
				'borderRightColor',
				'borderBottomColor',
				'borderLeftColor'
			],
			borderTop : 
			[
				'borderTopWidth',
				'borderTopColor'
			],
			borderRight : 
			[
				'borderRightWidth',
				'borderRightColor'
			],
			borderBottom : 
			[
				'borderBottomWidth',
				'borderBottomColor'
			],
			borderLeft : 
			[
				'borderLeftWidth',
				'borderLeftColor'
			],
			borderRadius : 
			[
				'borderTopLeftRadius',
				'borderTopRightRadius',
				'borderBottomRightRadius',
				'borderBottomLeftRadius'
			]
		};
		
		
		public static var BORDER_STYLE_NONE 	: String = "none";	/* default */
		public static var BORDER_STYLE_SOLID 	: String = "solid";
		public static var BORDER_STYLE_DASHED 	: String = "dashed";
		public static var BORDER_STYLE_DOTTED 	: String = "dotted";	
		
		
		
		public static function get defaultValues() : Object
		{
			return null;
		}
		
		/**
		* Shortcuts
		**/
		public static function parseBorder(val:String, file:String) : CSSParsingResult
		{
			return parseBorderForSide(val, '', file);
		}
		
		public static function parseBorderTop(val:String, file:String) : CSSParsingResult
		{
			return parseBorderForSide(val, "Top", file);
		}
		
		public static function parseBorderRight(val:String, file:String) : CSSParsingResult
		{
			return parseBorderForSide(val, "Right", file);
		}
		
		public static function parseBorderBottom(val:String, file:String) : CSSParsingResult
		{
			return parseBorderForSide(val, "Bottom", file);
		}
		
		public static function parseBorderLeft(val:String, file:String) : CSSParsingResult
		{
			return parseBorderForSide(val, "Left", file);
		}
		
		
		protected static function parseBorderForSide(val:String, side:String, file:String) : CSSParsingResult
		{
			var res : CSSParsingResult = new CSSParsingResult();
			
			// evaluate important flag
			var obj : Object = CSSParsingHelper.removeImportantFlagFromString(val);
			var important : String = obj.important ? CSSProperty.IMPORTANT_FLAG : '';
			val = obj.result;
			
			//extract border style value
			var extractionResult : Object = extractBorderStyleFromString(val, file);
			var borderStyle : CSSProperty = extractionResult.borderStyle;
			val = extractionResult.filteredString;
			if (side == '')
			{
				res.addPropertyForKey(borderStyle, 'borderTopStyle');
				res.addPropertyForKey(borderStyle, 'borderRightStyle');
				res.addPropertyForKey(borderStyle, 'borderBottomStyle');
				res.addPropertyForKey(borderStyle, 'borderLeftStyle');
			}
			else
			{
				res.addPropertyForKey(borderStyle, 'border' + side + 'Style');
			}
			//extract border width value
			extractionResult = extractBorderWidthFromString(val, file);
			var borderWidth : CSSProperty = extractionResult.borderWidth;
			val = StringUtil.lTrim(extractionResult.filteredString);
			if (side == '')
			{
				res.addPropertyForKey(borderWidth, 'borderTopWidth');
				res.addPropertyForKey(borderWidth, 'borderRightWidth');
				res.addPropertyForKey(borderWidth, 'borderBottomWidth');
				res.addPropertyForKey(borderWidth, 'borderLeftWidth');
			}
			else
			{
				res.addPropertyForKey(borderWidth, 'border' + side + 'Width');
			}
			
			var parts : Array = val.split(" ");
			var returnValue : Object;
			
			if (parts.length)
			{
				returnValue = Border["parseBorder" + side + "Color"](String(parts.shift()) + important, file);
				if (side == '')
					res.addEntriesFromResult(CSSParsingResult(returnValue));
				else
					res.addPropertyForKey(CSSProperty(returnValue), 'border' + side + 'Color');
			}
			
			return res;
		}
		
	
		
		public static function parseBorderStyle(val:String, file:String) : CSSParsingResult
		{
			// evaluate important flag
			var obj : Object = CSSParsingHelper.removeImportantFlagFromString(val);
			var important : Boolean = obj.important;
			val = obj.result;	
			
			var parts : Array = val.split(" ");
			
			var borderTopStyle : CSSProperty;
			var borderRightStyle : CSSProperty;
			var borderBottomStyle : CSSProperty;
			var borderLeftStyle : CSSProperty;
			
			switch (parts.length)
			{
				case 1:
					borderTopStyle = borderRightStyle = borderBottomStyle = 
						borderLeftStyle = strToStringProperty(parts[0], file);
					break;
					
				case 2:
					borderTopStyle = borderBottomStyle = strToStringProperty(parts[0], file);
					borderRightStyle = borderLeftStyle = strToStringProperty(parts[1], file);								
					break;
					
				case 3:
					borderTopStyle = strToStringProperty(parts[0], file);
					borderRightStyle = borderLeftStyle = strToStringProperty(parts[1], file);
					borderBottomStyle = strToStringProperty(parts[2], file);
					break;
					
				case 4:
					borderTopStyle = strToStringProperty(parts[0], file);
					borderRightStyle = strToStringProperty(parts[1], file);
					borderBottomStyle = strToStringProperty(parts[2], file);
					borderLeftStyle = strToStringProperty(parts[3], file);
					break;
					
				default:
					trace("Border::parseBorderStyle: wrong number of " +
						"parameters in: " + val);
					return null;
			}
			
			borderTopStyle.setImportant(important);
			borderRightStyle.setImportant(important);
			borderBottomStyle.setImportant(important);
			borderLeftStyle.setImportant(important);		
			
			return CSSParsingResult.ResultWithPropertiesAndKeys(
				borderTopStyle, 'borderTopStyle', borderRightStyle, 'borderRightStyle',
				borderBottomStyle, 'borderBottomStyle', borderLeftStyle, 'borderLeftStyle');
		}
		
		
		public static function parseBorderColor(val:String, file:String) : CSSParsingResult
		{
			// evaluate important flag
			var obj : Object = CSSParsingHelper.removeImportantFlagFromString(val);
			var important : Boolean = obj.important;
			val = obj.result;
					
			var parts : Array = val.split(" ");
			
			var borderTopColor : CSSProperty;
			var borderRightColor : CSSProperty;
			var borderBottomColor : CSSProperty;
			var borderLeftColor : CSSProperty;		
			
			switch (parts.length)
			{
				case 1:
					borderTopColor = borderRightColor = borderBottomColor = 
						borderLeftColor = strToColorProperty(parts[0], file);
					break;
					
				case 2:
					borderTopColor = borderBottomColor = strToColorProperty(parts[0], file);
					borderRightColor = borderLeftColor = strToColorProperty(parts[1], file);
					break;
					
				case 3:
					borderTopColor = strToColorProperty(parts[0], file);
					borderRightColor = borderLeftColor = strToColorProperty(parts[1], file);
					borderBottomColor = strToColorProperty(parts[2], file);
					break;
					
				case 4:
					borderTopColor = strToColorProperty(parts[0], file);
					borderRightColor = strToColorProperty(parts[1], file);
					borderBottomColor = strToColorProperty(parts[2], file);
					borderLeftColor = strToColorProperty(parts[3], file);
					break;
					
				default:
					trace("Border::parseBorderColor: wrong number of " +
						"parameters in: " + val);
					return null;
			}
			
			borderTopColor.setImportant(important);
			borderRightColor.setImportant(important);
			borderBottomColor.setImportant(important);
			borderLeftColor.setImportant(important);		
			
			return CSSParsingResult.ResultWithPropertiesAndKeys(
				borderTopColor, 'borderTopColor', borderRightColor, 'borderRightColor',
				borderBottomColor, 'borderBottomColor', borderLeftColor, 'borderLeftColor');		
		}
		
		
		public static function parseBorderWidth(val:String, file:String) : CSSParsingResult
		{		
			// evaluate important flag
			var obj : Object = CSSParsingHelper.removeImportantFlagFromString(val);
			var important : Boolean = obj.important;
			val = obj.result;
			
			var parts : Array = val.split(" ");
			
			var borderTopWidth : CSSProperty;
			var borderRightWidth : CSSProperty;
			var borderBottomWidth : CSSProperty;
			var borderLeftWidth : CSSProperty;		
			
			switch (parts.length)
			{
				case 1:
					borderTopWidth = borderRightWidth = borderBottomWidth = 
						borderLeftWidth = strToIntProperty(parts[0], file);
					break;
					
				case 2:
					borderTopWidth = borderBottomWidth = strToIntProperty(parts[0], file);
					borderRightWidth = borderLeftWidth = strToIntProperty(parts[1], file);
					break;
					
				case 3:
					borderTopWidth = strToIntProperty(parts[0], file);
					borderRightWidth = borderLeftWidth = strToIntProperty(parts[1], file);
					borderBottomWidth = strToIntProperty(parts[2], file);
					break;
					
				case 4:
					borderTopWidth = strToIntProperty(parts[0], file);
					borderRightWidth = strToIntProperty(parts[1], file);
					borderBottomWidth = strToIntProperty(parts[2], file);
					borderLeftWidth = strToIntProperty(parts[3], file);
					break;
					
				default:
					trace("Border::parseBorderWidth: wrong number of " +
						"parameters in: " + val);
					return null;
			}
			
			borderTopWidth.setImportant(important);
			borderRightWidth.setImportant(important);
			borderBottomWidth.setImportant(important);
			borderLeftWidth.setImportant(important);
			
			return CSSParsingResult.ResultWithPropertiesAndKeys(
				borderTopWidth, 'borderTopWidth', borderRightWidth, 'borderRightWidth',
				borderBottomWidth, 'borderBottomWidth', borderLeftWidth, 'borderLeftWidth');				
		}	
		
		
		
		
		/**
		* Border width
		**/	
		public static function parseBorderTopWidth(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseBorderRightWidth(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseBorderBottomWidth(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		public static function parseBorderLeftWidth(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		
		
		
		/**
		* Border style
		**/	
		public static function parseBorderTopStyle(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseBorderRightStyle(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseBorderBottomStyle(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		public static function parseBorderLeftStyle(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		
		
		/**
		* Color style
		**/	
		public static function parseBorderTopColor(val:String, file:String) : CSSProperty
		{
			return strToColorProperty(val, file);
		}
		
		public static function parseBorderRightColor(val:String, file:String) : CSSProperty
		{
			return strToColorProperty(val, file);
		}
		
		public static function parseBorderBottomColor(val:String, file:String) : CSSProperty
		{
			return strToColorProperty(val, file);
		}
		
		public static function parseBorderLeftColor(val:String, file:String) : CSSProperty
		{
			return strToColorProperty(val, file);
		}
		
		
		/**
		* Border renderer
		**/
		public static function parseBorderRenderer(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}
		
		
		/**
		* Border radius
		**/
		public static function parseBorderRadius(val:String, file:String) : CSSParsingResult
		{
			// evaluate important flag
			var obj : Object = CSSParsingHelper.removeImportantFlagFromString(val);
			var important : Boolean = obj.important;		
			val = obj.result;		
			
			var parts : Array = val.split(" ");
			
			var borderTopLeftRadius : CSSProperty;
			var borderTopRightRadius : CSSProperty;
			var borderBottomRightRadius : CSSProperty;
			var borderBottomLeftRadius : CSSProperty;		
			
			switch (parts.length)
			{
				case 1:
					borderTopLeftRadius = borderTopRightRadius = borderBottomRightRadius = 
						borderBottomLeftRadius = strToIntProperty(parts[0], file);
					break;
					
				case 2:
					borderTopLeftRadius = borderBottomRightRadius = strToIntProperty(parts[0], file);
					borderTopRightRadius = borderBottomLeftRadius = strToIntProperty(parts[1], file);
					break;
					
				case 3:
					borderTopLeftRadius = strToIntProperty(parts[0], file);
					borderTopRightRadius = borderBottomLeftRadius = strToIntProperty(parts[1], file);
					borderBottomRightRadius = strToIntProperty(parts[2], file);
					break;
					
				case 4:
					borderTopLeftRadius = strToIntProperty(parts[0], file);
					borderTopRightRadius = strToIntProperty(parts[1], file);
					borderBottomRightRadius = strToIntProperty(parts[2], file);
					borderBottomLeftRadius = strToIntProperty(parts[3], file);
					break;
					
				default:
					trace("Border::parseBorderWidth: wrong number of " +
						"parameters in: " + val);
					return null;
			}
			
			borderTopLeftRadius.setImportant(important);
			borderTopRightRadius.setImportant(important);
			borderBottomRightRadius.setImportant(important);
			borderBottomLeftRadius.setImportant(important);
			
			return CSSParsingResult.ResultWithPropertiesAndKeys(
				borderTopLeftRadius, 'borderTopLeftRadius', borderTopRightRadius, 'borderTopRightRadius',
				borderBottomRightRadius, 'borderBottomRightRadius', borderBottomLeftRadius, 'borderBottomLeftRadius');
		}
		
		public static function parseBorderTopLeftRadius(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);		
		}
		
		public static function parseBorderTopRightRadius(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);		
		}
		
		public static function parseBorderBottomRightRadius(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);		
		}
		
		public static function parseBorderBottomLeftRadius(val:String, file:String) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
	}
}