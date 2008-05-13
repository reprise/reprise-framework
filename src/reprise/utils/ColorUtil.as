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

package reprise.utils
 {
	 /**
	 * Color related utility functions
	 *
	 * @author	Christian Roeingh, Dominik Schmid
	 * @version	$Revision: 237 $ | $Id: ColorUtil.as 237 2006-01-19 14:13:40Z flo $
	 */
	public class ColorUtil
	{
	
		/**
		 * Constructor. Private to prevent instantiation from outside
		 */
		public function ColorUtil()
		{
		}
	
		/**
		 * Converts a hexadecimal color string to a Number value
		 *
		 * @param	hex		color as hexadecimal string
		 *
		 * @return	Number	rgb color value
		 */	
		public static function hex2rgb(hex : String) : Number
		{
			if (hex.charAt(0) == "#")
			{
				return parseInt(hex.substr(1), 16);
			}
			else {
				return parseInt(hex, 16);
			}
		}
	
		
		/**
		 * Converts an rgb color number to an rgb Array
		 * 
		 * @param	rgbInt	Number	The rgm color number to convert.
		 * @usage	number2rgbArray(0xFFFFFF); //returns [255,255,255]
		 */
		public static function number2rgbArray(rgbInt : Number) : Array
		{
			var r:Number = rgbInt >> 16;
			var g:Number = (rgbInt ^ (r << 16)) >> 8;
			var b:Number = (rgbInt ^ (r << 16)) ^ (g << 8);
			
			return new Array(r, g, b);
		}
		
		public static function number2rgbObject(rgbInt : Number) : Object
		{
			var obj : Object = {};
			obj.r = rgbInt >> 16;
			obj.g = (rgbInt ^ (obj.r << 16)) >> 8;
			obj.b = (rgbInt ^ (obj.r << 16)) ^ (obj.g << 8);
			
			return obj;
		}
		
		public static function rgbObject2Number(rgb:Object) : Number
		{
			return (rgb.r << 16) | (rgb.g << 8) | rgb.b;
		}
		
		
		public static function randomColor() : Number
		{
			return (Math.random() * 255) << 16 | (Math.random() * 255) << 8 | (Math.random() * 255);
		}
		
		
		/**
		* returns either black or white depending on which contrast is greater to a given color
		**/
		public static function contrastColorAgainstColor(hexColor : Number) : Number
		{
			var hsb : Object = hexToHsb(hexColor);
			if (hsb.b <= 50)
				return 0xffffff;
			else
				return 0x000000;
		}
		
		
		public static function hsbToHex(
			h : Number = 0, s : Number = 0, br : Number = 0) : Number
		{
			var r : Number;
			var g : Number;
			var b : Number;
			var rgb : Number;
		
			s = (100 - s) / 100;
			br = (100 - br) / 100;
		
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
			
			r += (255 - r) * s;
			g += (255 - g) * s;
			b += (255 - b) * s;
			r -= r * br;
			g -= g * br;
			b -= b * br;
			r = Math.round(r);
			g = Math.round(g);
			b = Math.round(b);
			
			rgb = b + (g * 256) + (r * 65536);
			return rgb;
		}
			
		
		public static function hexToHsb(hex : Number) : Object 
		{
			var rgb : Object = number2rgbObject(hex);
			var r : Number = rgb.r;
			var g : Number = rgb.g;
			var b : Number = rgb.b;
			
			var hsb : Object = {};
			hsb.b = Math.max(Math.max(r, g), b);
			var min:Number = Math.min(r, Math.min(g, b));
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
	}
}