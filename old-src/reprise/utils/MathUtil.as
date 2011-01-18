/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.utils { 
	/**
	 * Mathematical utility functions
	 *
	 * @author	Dominik Schmid
	 * @version	$Revision: 131 $ | $Id: MathUtil.as 131 2006-01-10 13:49:53Z nick $
	 */
	public class MathUtil
	{
	
		/**
		 * Constructor. Private to prevent instantiation from outside
		 */
		public function MathUtil()
		{
		}
	
		/**
		 * Returns a number between a minimum and maximum value
		 *
		 * @param	value	input value
		 * @param	min		minimum value
		 * @param	max		maximum value
		 *
		 * @return	Number	number between the minimum and maximum value
		 */
		public static function clip(value:Number, min:Number, max:Number) : Number
		{
			return Math.max(min, Math.min(max, value));
		}
	
		/**
		 * Generates a random number between two passed values
		 *
		 * @param	min		minimum value to generate
		 * @param	max		maximun value to generate
		 *
		 * @return	Number	random number between the values min and max
		 */
		public static function randomBetween(min:Number, max:Number) : Number
		{
			return Math.ceil(Math.random() * (max - min + 1)) + (min - 1);
		}
		
		/**
		 * Generates a random float number between two passed values
		 *
		 * @param	min			minimum value to generate
		 * @param	max			maximun value to generate
		 * @param	figures		optional, number of figures (default = 1)
		 *
		 * @return	Number	random number between the values min and max
		 */
		public static function randomFloatBetween(
			min:Number, max:Number, digits:Number = 1) : Number
		{
			digits = 1;
			var factor:Number = Math.pow(10, digits);
			
			return MathUtil.randomBetween(factor * min, factor * max) / factor;
		}	
	
		/**
		 * Generates a random sign, so either -1 or 1
		 *
		 * @return	Number	random sign, either -1 or 1
		 */
		public static function randomSign() : Number
		{
			return Math.round(Math.random ()) < 1 ? -1 : 1;
		}
		
		/**
		 * compares two values and returns true if 
		 * the difference between them is < epsilon
		 */
		public static function floatsEqual(
			float1:Number, float2:Number, epsilon:Number = 0.000001) : Boolean
		{
			return Math.abs(float1 - float2) < epsilon;
		}
		
		public static function degreesToRadians(angle : Number) : Number
		{
			return angle * (Math.PI / 180);
		}
		
		public static function radiansToDegrees(angle : Number) : Number
		{
			return angle * (180 / Math.PI);
		}
	
		public static function sin(angle : Number) : Number
		{
			return Math.sin(angle * (Math.PI / 180));
		}	
		
		public static function asin(ratio : Number) : Number
		{
			return Math.asin(ratio) * (180 / Math.PI);
		}	
		
		public static function cos(angle : Number) : Number
		{
			return Math.cos(angle * (Math.PI / 180));
		}	
		
		public static function acos(ratio : Number) : Number
		{
			return Math.acos(ratio) * (180 / Math.PI);
		}	
		
		public static function tan(angle : Number) : Number
		{
			return Math.tan(angle * (Math.PI / 180));
		}
		
		public static function atan(x : Number, y : Number) : Number
		{
			return Math.atan2(y, x) * (180 / Math.PI);
		}
		
		public static function round(value:Number, precision:uint = 0):Number
		{
			var pow:uint = Math.pow(10, precision);
			return Math.round(value * pow) / pow;
		}
	}
}