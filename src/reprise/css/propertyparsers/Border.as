/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css.propertyparsers
{
	import reprise.core.reprise;
	import reprise.css.CSSParsingHelper;
	import reprise.css.CSSParsingResult;
	import reprise.css.CSSProperty;
	import reprise.css.CSSPropertyParser;
	import reprise.css.transitions.ColorTransitionVO;
	import reprise.utils.StringUtil; 
	
	use namespace reprise;
	
	public class Border extends CSSPropertyParser
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const KNOWN_PROPERTIES : Object =
		{
			border : {parser : parseBorder},
			borderTop : {parser : parseBorderTop},
			borderRight : {parser : parseBorderRight},
			borderBottom : {parser : parseBorderBottom},
			borderLeft : {parser : parseBorderLeft},
			borderStyle : {parser : parseBorderStyle},
			borderColor : {parser : parseBorderColor},
			borderWidth : {parser : parseBorderWidth},
			borderTopWidth : {parser : strToIntProperty},
			borderRightWidth : {parser : strToIntProperty},
			borderBottomWidth : {parser : strToIntProperty},
			borderLeftWidth : {parser : strToIntProperty},
			borderTopStyle : {parser : strToStringProperty},
			borderRightStyle : {parser : strToStringProperty},
			borderBottomStyle : {parser : strToStringProperty},
			borderLeftStyle : {parser : strToStringProperty},
			borderTopColor : {parser : strToColorProperty, transition : ColorTransitionVO},
			borderRightColor : {parser : strToColorProperty, transition : ColorTransitionVO},
			borderBottomColor : {parser : strToColorProperty, transition : ColorTransitionVO},
			borderLeftColor : {parser : strToColorProperty, transition : ColorTransitionVO},
			borderRenderer : {parser : strToStringProperty},
			borderRadius : {parser : parseBorderRadius},
			borderTopLeftRadius : {parser : strToIntProperty},
			borderTopRightRadius : {parser : strToIntProperty},
			borderBottomRightRadius : {parser : strToIntProperty},
			borderBottomLeftRadius : {parser : strToIntProperty}
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
		
		
		public static const BORDER_STYLE_NONE 	: String = "none";	/* default */
		public static const BORDER_STYLE_SOLID 	: String = "solid";
		public static const BORDER_STYLE_DASHED 	: String = "dashed";
		public static const BORDER_STYLE_DOTTED 	: String = "dotted";	
		
		
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
			var borderColor : CSSProperty;
			
			if (parts.length)
			{
				borderColor = strToColorProperty(String(parts.shift()) + important, file);
				if (side == '')
				{
					res.addPropertyForKey(borderColor, 'borderTopColor');
					res.addPropertyForKey(borderColor, 'borderRightColor');
					res.addPropertyForKey(borderColor, 'borderBottomColor');
					res.addPropertyForKey(borderColor, 'borderLeftColor');
				}
				else
				{
					res.addPropertyForKey(borderColor, 'border' + side + 'Color');
				}
			}
			
			return res;
		}
		
	
		
		public static function parseBorderStyle(val:String, file:String) : CSSParsingResult
		{
			return strToRectParsingResult(val, file, 'border', 'Style', strToStringProperty);
		}
		
		
		public static function parseBorderColor(val:String, file:String) : CSSParsingResult
		{
			return strToRectParsingResult(val, file, 'border', 'Color', strToColorProperty);
		}
		
		
		public static function parseBorderWidth(val:String, file:String) : CSSParsingResult
		{
			return strToRectParsingResult(val, file, 'border', 'Width', strToIntProperty);
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
					log("w Border::parseBorderWidth: wrong number of " +
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
	}
}