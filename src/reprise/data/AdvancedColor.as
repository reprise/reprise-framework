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

package reprise.data
{
	import flash.filters.ColorMatrixFilter;
	
	import reprise.core.Cloneable;
	 
	public class AdvancedColor implements Cloneable
	{
		
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var g_htmlColors : Object =
		{
			black: 0x0,
			silver: 0xc0c0c0,
			grey: 0x808080,
			white: 0xFFFFFF,
			maroon: 0x800000,
			red: 0xff0000,
			purple: 0x800080,
			fuchsia: 0xff00ff,
			green: 0x008000,
			lime: 0x00ff00,
			olive: 0x808000,
			yellow: 0xffff00,
			navy: 0x000080,
			blue: 0x0000ff,
			teal: 0x008080,
			aqua: 0x00ffff,
			magenta: 0xff00ff
		};	
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_value : int;
		protected var m_opacity : Number;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function AdvancedColor(rgb : int = 0, opacity : Number = 1)
		{
			setRGB(rgb);
			m_opacity = opacity;
		}
		
		
		public function setRGB(rgb : int) : void
		{
			m_value = rgb;
			m_opacity = 1;
		}
		
		public function rgb() : int
		{
			return m_value;
		}
		
		public function setRGBA(rgba : uint) : void
		{
	 		m_opacity = (rgba & 0xFF) / 0xFF;
			m_value = rgba >>> 8;
		}
		
		public function rgba() : uint
		{
			return uint(m_value << 8) | uint(m_opacity * 0xFF);
		}
		
		public function setARGB(argb : uint) : void
		{
			m_opacity = (argb >> 24 & 0xFF) / 0xFF;
			m_value = argb & 0xFFFFFF;
		}
		
		public function argb() : uint
		{
			return uint(m_opacity * 0xFF << 24 | m_value);
		}
		
		public function setRGBComponents(r : int, g : int, b : int) : void
		{
			m_value = (r << 16) | (g << 8) | b;
			m_opacity = 1;
		}
		
		public function rgbComponents() : Object
		{
			var rgb : Object = 
			{
				r : m_value >> 16 & 0xFF,
				g : m_value >> 8 & 0xFF,
				b : m_value & 0xFF
			};
			return rgb;
		}
		
		public function setRGBAComponents(r : int, g : int, b : int, a : Number) : void
		{
			setRGBComponents(r, g, b);
			m_opacity = a;
		}
		
		public function rgbaComponents() : void
		{
			var rgba : Object = rgbComponents();
			rgba.a = m_opacity;
		}
		
		public function setColorString(colorString : String) : void
		{
			if (colorString.charAt(0) == '#')
			{
				var r : int;
				var g : int;
				var b : int;
				var a : Number;
				var char : String;
				switch (colorString.length)
				{
					// #RGB
					case 4:
					{
						colorString += "FF";
					}
					// #RGBA
					case 5:
					{
						char = colorString.charAt(1);
						r = parseInt(char + char, 16);
						char = colorString.charAt(2);
						g = parseInt(char + char, 16);
						char = colorString.charAt(3);
						b = parseInt(char + char, 16);
						char = colorString.charAt(4);
						a = parseInt(char + char, 16) / 0xFF;
						break;
					}
					// #RRGGBB
					case 7:
					{
						colorString += 'FF';
					}
					// #RRGGBBAA
					default:
					{
						r = parseInt(colorString.substr(1, 2), 16);
						g = parseInt(colorString.substr(3, 2), 16);
						b = parseInt(colorString.substr(5, 2), 16);
						a = parseInt(colorString.substr(7, 2), 16) / 0xFF;
					}
				}
				setRGBAComponents(r, g, b, a);
				return;			
			}
			
			colorString = colorString.toLowerCase();		
			if (colorString == 'transparent')
			{
				m_value = 0;
				m_opacity = 0;
				return;
			}
			
			// can be either rgb or rgba
			if (colorString.indexOf('rgb') == 0)
			{
				var lBracketIdx:uint = colorString.indexOf( '(' );
				var rBracketIdx:uint = colorString.indexOf( ')' );
				var components:Array = colorString.substring(lBracketIdx + 1, rBracketIdx).split('  ').
					join('').split(' ').join('').split(',');
				if (components.length == 3)
				{
					components.push("1");
				}
				setRGBAComponents(parseInt(components[0]), parseInt(components[1]), 
					parseInt(components[2]), parseFloat(components[3]));
				return;
			}
			
	
		
			m_opacity = 1;
			m_value = g_htmlColors[colorString];
			if (isNaN(m_value))
			{
				m_value = 0x0;
			}
		}
		
		public function setHSB(h:Number, s:Number, br:Number) : void
		{
			var r : Number;
			var g : Number;
			var b : Number;
		
			if (!isNaN(s)) 
			{
				s = (100 - s) / 100;
				br = (100 - br) / 100;
			}
		
			if ((h  > 300 && h <= 360) || (h >= 0 && h <= 60)) 
			{
				r = 255;
				g = (h / 60) * 255;
				b = ((360 - h) / 60) * 255;
			} 
			else if (h > 60 && h <= 180) 
			{
				r = ((120 - h) / 60) * 255;
				g = 255;
				b = ((h - 120) / 60) * 255;
			} 
			else 
			{
				r = ((h - 240) / 60) * 255;
				g = ((240 - h) / 60) * 255;
				b = 255;
			}
			
			if (r > 255 || r < 0) r = 0;
			if (g > 255 || g < 0) g = 0;
			if (b > 255 || b < 0) b = 0;
			
			if (!isNaN(s)) 
			{	
				r += (255 - r) * s;
				g += (255 - g) * s;
				b += (255 - b) * s;
				r -= r * br;
				g -= g * br;
				b -= b * br;
				r = Math.round(r);
				g = Math.round(g);
				b = Math.round(b);
			}
			
			m_value = b | (g << 8) | (r << 16);
			m_opacity = 1;
		}
		
		public function hsb() : Object
		{
			var r : uint = m_value >> 16 & 0xFF;
			var g : uint = m_value >> 8 & 0xFF;
			var b : uint = m_value & 0xFF;
			
			var hsb : Object = {};
			hsb.b = Math.max(Math.max(r, g), b);
			var min:uint = Math.min(r, Math.min(g, b));
			hsb.s = (hsb.b <= 0) ? 0 : Math.round(100 * (hsb.b - min) / hsb.b);
			hsb.b = Math.round((hsb.b / 255) * 100);
			hsb.h = 0;
	                
			if ((r == g) && (g == b))
				hsb.h = 0;
			else if (r >= g && g >= b)
				hsb.h = 60 * (g - b) / (r - b);
			else if (g >= r && r >= b)
				hsb.h = 60 + 60 * (g - r) / (g - b);
			else if (g >= b && b >= r)
				hsb.h = 120 + 60 * (b - r) / (g - r);
			else if (b >= g && g >= r)
				hsb.h = 180 + 60 * (b - g) / (b - r);
			else if (b >= r && r >=  g)
				hsb.h = 240 + 60 * (r - g) / (b - g);
			else if (r >= b && b >= g)
				hsb.h = 300 + 60 * (r - b) / (r - g);
			else
				hsb.h = 0;
	
			hsb.h = Math.round(hsb.h);
			return hsb;		
		}
		
		public function setAlpha(alpha : Number) : void
		{
			alpha = Math.max(0, alpha);
			alpha = Math.min(100, alpha);
			m_opacity = alpha / 100;
		}
		
		public function alpha() : Number
		{
			return m_opacity * 100;
		}
		
		public function setOpacity(opacity : Number) : void
		{
			m_opacity = opacity;
		}
		
		public function opacity() : Number
		{
			return m_opacity;
		}
		
		public function tintFilter():ColorMatrixFilter
		{
			var rgb:Object = rgbComponents();
			var matrix:Array = [];
			matrix = matrix.concat([1, 0, 0, 0, rgb.r * m_opacity]);
			matrix = matrix.concat([0, 1, 0, 0, rgb.g * m_opacity]);
			matrix = matrix.concat([0, 0, 1, 0, rgb.b * m_opacity]);
			matrix = matrix.concat([0, 0, 0, 1, 0]);
			return new ColorMatrixFilter(matrix);
		}
		
	
		public function equals(color : AdvancedColor) : Boolean
		{
			return color.rgba() == rgba();
		}
		
		public function valueOf() : Object
		{
			return m_value;
		}
		
		public function clone(deep : Boolean = false) : Cloneable
		{
			var clone : AdvancedColor = new AdvancedColor(m_value);
			clone.m_opacity = m_opacity;
			return clone;
		}
		
		public function toString() : String
		{
			var colorString : String = rgba().toString(16);
			while(colorString.length < 8)
			{
				colorString = '0' + colorString;
			}
			return '#' + colorString;
		}
	}
}