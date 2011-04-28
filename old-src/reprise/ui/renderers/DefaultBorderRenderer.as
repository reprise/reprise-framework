/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.ui.renderers
{ 
	import flash.geom.Point;
	
	import reprise.css.propertyparsers.Border;
	import reprise.data.AdvancedColor;
	import reprise.utils.GfxUtil;
	
	
	public class DefaultBorderRenderer extends AbstractCSSRenderer
	{
	
	//----------------------       Private / Protected Properties       ----------------------//
		protected static var SIDE_TOP : int = 1;
		protected static var SIDE_RIGHT : int = 2;
		protected static var SIDE_BOTTOM : int = 3;
		protected static var SIDE_LEFT : int = 4;
	
	
	
		//----------------------               Public Methods               ----------------------//
		public function DefaultBorderRenderer() {}
		
		
		
		public override function draw() : void
		{
			_display.graphics.clear();
	
			var borderWidth : Object = 
			{
				top : _styles.borderTopWidth,
				right : _styles.borderRightWidth,
				bottom : _styles.borderBottomWidth,
				left : _styles.borderLeftWidth
			};
			
			var borderStyle : Object =
			{
				top : _styles.borderTopStyle,
				right : _styles.borderRightStyle,
				bottom : _styles.borderBottomStyle,
				left : _styles.borderLeftStyle
			};
			
			var borderColor : Object =
			{
				top : _styles.borderTopColor,
				right : _styles.borderRightColor,
				bottom : _styles.borderBottomColor,
				left : _styles.borderLeftColor
			};
			
			var radii : Array = [];
			var hasRoundBorder : Boolean = false;
			var order : Array = ['borderTopLeftRadius', 'borderTopRightRadius', 
				'borderBottomRightRadius', 'borderBottomLeftRadius'];
	
			var i : int;
			var radiusItem : Number;
			for (i = 0; i < order.length; i++)
			{
				radiusItem = _styles[order[i]];
				if (_styles[order[i]] is Number)
				{
					radiusItem = _styles[order[i]];
				}
				else
				{
					radiusItem = 0;
				}
				if (radiusItem != 0)
				{
					hasRoundBorder = true;
				}
				radii.push(radiusItem);
			}
	
			if (hasRoundBorder && borderWidth.top && borderStyle.top == 'solid')
			{
				var color : AdvancedColor = borderColor.top || new AdvancedColor(0);
				var width : Number = borderWidth.top;
				_display.graphics.lineStyle(width, color.rgb(), color.opacity(),
					true, 'normal', 'square', 'miter', 2);
				GfxUtil.drawRoundRect(_display, width / 2, width / 2,
					_width - width, _height - width, radii);
				return;
			}
			
			var topLeft : Point = new Point();
			var topRight : Point = new Point();
			var bottomRight : Point = new Point();
			var bottomLeft : Point = new Point();
			if (borderWidth.top > 0 && borderStyle.top != 'none' && borderColor.top)
			{
				topLeft.x = 0;
				topLeft.y = 0;
				topRight.x = _width;
				topRight.y = 0;
				bottomRight.x = _width - borderWidth.right;
				bottomRight.y = borderWidth.top;
				bottomLeft.x = borderWidth.left;
				bottomLeft.y = borderWidth.top;
				drawBorderInRect(borderColor.top, borderStyle.top, borderWidth.top, 
					topLeft, topRight, bottomRight, bottomLeft, SIDE_TOP);
			}
			
			if (borderWidth.right > 0 && borderStyle.right != 'none' && borderColor.right)
			{
				topLeft.x = _width;
				topLeft.y = 0;
				topRight.x = _width;
				topRight.y = _height;
				bottomRight.x = _width - borderWidth.right;
				bottomRight.y = _height - borderWidth.bottom;
				bottomLeft.x = _width - borderWidth.right;
				bottomLeft.y = borderWidth.top;
				drawBorderInRect(borderColor.right, borderStyle.right, borderWidth.right, 
					topLeft, topRight, bottomRight, bottomLeft, SIDE_RIGHT);
			}
	
			if (borderWidth.bottom > 0 && borderStyle.bottom != 'none' && borderColor.bottom)
			{
				topLeft.x = 0;
				topLeft.y = _height;
				topRight.x = _width;
				topRight.y = _height;
				bottomRight.x = _width - borderWidth.right;
				bottomRight.y =  _height - borderWidth.bottom;
				bottomLeft.x = borderWidth.left;
				bottomLeft.y = _height - borderWidth.bottom;
				drawBorderInRect(borderColor.bottom, borderStyle.bottom, borderWidth.bottom, 
					topLeft, topRight, bottomRight, bottomLeft, SIDE_BOTTOM);
			}
			
			if (borderWidth.left > 0 && borderStyle.left != 'none' && borderColor.left)
			{
				topLeft.x = 0;
				topLeft.y = 0;
				topRight.x = 0;
				topRight.y = _height;
				bottomRight.x = borderWidth.left;
				bottomRight.y = _height - borderWidth.bottom;
				bottomLeft.x = borderWidth.left;
				bottomLeft.y = borderWidth.top;
				drawBorderInRect(borderColor.left, borderStyle.left, borderWidth.left, 
					topLeft, topRight, bottomRight, bottomLeft, SIDE_LEFT);
			}
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected function drawBorderInRect(color : AdvancedColor, style : String, 
			width : Number, pt1 : Point, pt2 : Point, pt3 : Point, pt4 : Point, 
			side : int) : void
		{
			var colorValue : int = 0;
			var opacityValue : Number = 1;
			if (color)
			{
				colorValue = color.rgb();
				opacityValue = color.opacity();
			}
			switch (style)
			{
				case Border.BORDER_STYLE_DOTTED :
				case Border.BORDER_STYLE_DASHED :
				{
					var dashLength : Number = width;
					if (style == Border.BORDER_STYLE_DASHED)
					{
						dashLength *= 3;
					}
					_display.graphics.lineStyle(width, colorValue, opacityValue,
						false, "normal", "none");
					
					switch (side)
					{
						case SIDE_TOP:
						{
							pt1.y += width / 2;
							pt2.y += width / 2;
							break;
						}
						case SIDE_RIGHT:
						{
							pt1.x -= width / 2;
							pt2.x -= width / 2;
							break;
						}
						case SIDE_BOTTOM:
						{
							pt1.y -= width / 2;
							pt2.y -= width / 2;
							break;
						}
						case SIDE_LEFT:
						{
							pt1.x += width / 2;
							pt2.x += width / 2;
							break;
						}
					}
					
					GfxUtil.drawDashedLine(_display,
						pt1.x, pt1.y, pt2.x, pt2.y, dashLength, dashLength);
					break;
				}
				case Border.BORDER_STYLE_SOLID :
				{
					_display.graphics.lineStyle();
					_display.graphics.beginFill(colorValue, opacityValue);
					_display.graphics.moveTo(pt1.x, pt1.y);
					_display.graphics.lineTo(pt2.x, pt2.y);
					_display.graphics.lineTo(pt3.x, pt3.y);
					_display.graphics.lineTo(pt4.x, pt4.y);
					_display.graphics.moveTo(pt1.x, pt1.y);
					_display.graphics.endFill();
					break;
				}
				default:
			}
		}	
	}
}