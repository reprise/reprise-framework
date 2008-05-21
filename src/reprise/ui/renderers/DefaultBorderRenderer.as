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

package reprise.ui.renderers { 
	import reprise.css.propertyparsers.Border;
	import reprise.data.AdvancedColor;
	import reprise.utils.GfxUtil;
	
	import flash.geom.Point;
	
	
	public class DefaultBorderRenderer extends AbstractCSSRenderer
	{
	
	
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var SIDE_TOP : Number = 1;
		protected static var SIDE_RIGHT : Number = 2;
		protected static var SIDE_BOTTOM : Number = 3;
		protected static var SIDE_LEFT : Number = 4;
	
	
	
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function DefaultBorderRenderer() {}
		
		
		
		public override function draw() : void
		{
			m_display.graphics.clear();
	
			var borderWidth : Object = 
			{
				top : m_styles.borderTopWidth | 0,
				right : m_styles.borderRightWidth | 0,
				bottom : m_styles.borderBottomWidth | 0,
				left : m_styles.borderLeftWidth | 0
			};
			
			var borderStyle : Object =
			{
				top : m_styles.borderTopStyle,
				right : m_styles.borderRightStyle,
				bottom : m_styles.borderBottomStyle,
				left : m_styles.borderLeftStyle
			};
			
			var borderColor : Object =
			{
				top : m_styles.borderTopColor,
				right : m_styles.borderRightColor,
				bottom : m_styles.borderBottomColor,
				left : m_styles.borderLeftColor
			};
			
			var radii : Array = [];
			var hasRoundBorder : Boolean = false;
			var order : Array = ['borderTopLeftRadius', 'borderTopRightRadius', 
				'borderBottomRightRadius', 'borderBottomLeftRadius'];
	
			var i : Number;
			var radiusItem : Number;
			for (i = 0; i < order.length; i++)
			{
				radiusItem = m_styles[order[i]];
				if (m_styles[order[i]] is Number)
				{
					radiusItem = m_styles[order[i]];
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
				m_display.graphics.lineStyle(width, color.rgb(), color.opacity(), 
					true, 'normal', 'square', 'miter', 2);
				GfxUtil.drawRoundRect(m_display, width / 2, width / 2, 
					m_width - width, m_height - width, radii);
				return;
			}
			
			if (borderWidth.top > 0 && borderStyle.top != 'none')
			{
				drawBorderInRect(borderColor.top, borderStyle.top, borderWidth.top, 
					new Point(0, 0), 
					new Point(m_width, 0), 
					new Point(m_width - borderWidth.right, borderWidth.top), 
					new Point(borderWidth.left, borderWidth.top),
					SIDE_TOP);
			}
			
			if (borderWidth.right > 0 && borderStyle.right != 'none')
			{
				drawBorderInRect(borderColor.right, borderStyle.right, borderWidth.right, 
					new Point(m_width, 0),
					new Point(m_width, m_height),
					new Point(m_width - borderWidth.right, m_height - borderWidth.bottom),
					new Point(m_width - borderWidth.right, borderWidth.top),
					SIDE_RIGHT);
			}
	
			if (borderWidth.bottom > 0 && borderStyle.bottom != 'none')
			{
				drawBorderInRect(borderColor.bottom, borderStyle.bottom, borderWidth.bottom, 
					new Point(0, m_height),
					new Point(m_width, m_height),
					new Point(m_width - borderWidth.right, m_height - borderWidth.bottom),
					new Point(borderWidth.left, m_height - borderWidth.bottom),
					SIDE_BOTTOM);
			}
			
			if (borderWidth.left > 0 && borderStyle.left != 'none')
			{
				drawBorderInRect(borderColor.left, borderStyle.left, borderWidth.left, 
					new Point(0, 0),
					new Point(0, m_height),
					new Point(borderWidth.left, m_height - borderWidth.bottom),
					new Point(borderWidth.left, borderWidth.top),
					SIDE_LEFT);
			}
		}
		
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function drawBorderInRect(color : AdvancedColor, style : String, 
			width : Number, pt1 : Point, pt2 : Point, pt3 : Point, pt4 : Point, 
			side : Number) : void
		{
			var colorValue : int = 0;
			var opacityValue : int = 1;
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
					m_display.graphics.lineStyle(width, colorValue, opacityValue, 
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
					
					GfxUtil.drawDashedLine(m_display, pt1.x, pt1.y, pt2.x, pt2.y, dashLength, dashLength);
					break;
				}
				case Border.BORDER_STYLE_SOLID :
				{
					m_display.graphics.lineStyle();
					m_display.graphics.beginFill(colorValue, opacityValue);
					m_display.graphics.moveTo(pt1.x, pt1.y);
					m_display.graphics.lineTo(pt2.x, pt2.y);
					m_display.graphics.lineTo(pt3.x, pt3.y);
					m_display.graphics.lineTo(pt4.x, pt4.y);
					m_display.graphics.moveTo(pt1.x, pt1.y);
					m_display.graphics.endFill();
					break;
				}
				default:
			}
		}	
	}
}