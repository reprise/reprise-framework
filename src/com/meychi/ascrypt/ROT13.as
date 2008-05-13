package com.meychi.ascrypt { 
	/**
	* Encodes and decodes a ROT13 string.
	* @authors Mika Palmu
	* @version 2.0
	*/
	
	public class ROT13 {
	
		/**
		* Variables
		* @exclude
		*/
		protected static var chars:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMabcdefghijklmnopqrstuvwxyzabcdefghijklm";
	
		/**
		* Encodes or decodes a ROT13 string.
		*/
		public static function calculate(src:String):String {
			var calculated:String = new String("");
			for (var i:Number = 0; i<src.length; i++) {
				var character:String = src.charAt(i);
				var pos:Number = chars.indexOf(character);
				if (pos > -1) character = chars.charAt(pos+13);
				calculated += character;
			}
			return calculated;
		}
	
	}
}