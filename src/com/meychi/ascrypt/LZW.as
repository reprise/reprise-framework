package com.meychi.ascrypt { 
	/**
	* Compresses and decompresses text with the LZW algorithm.
	* @authors Mika Palmu
	* @version 1.1
	*
	* Original Flash port by:
	* Ash & Lalek & Shoebox and others.
	* See: http://www.razorberry.com/blog/archives/2004/08/22/lzw-compression-methods-in-as2/
	* See: http://www.lalex.com/blog/comments/200405/164-compression-lzw-actionscript-2.html
	*/
	
	public class LZW {
	
		/**
		* Compresses the specified text.
		*/
		public static function compress(src:String):String {
			var chars:Number = 256;
			var original:String = src;
			var dict:Array = new Array();
			for (var i:Number = 0; i<chars; i++) dict[String(i)] = i;
			var result:String = new String("");
			var splitted:Array = original.split("");
			var buffer:Array = new Array();
			for (var i:Number = 0; i<=splitted.length; i++) {
				var current:String = splitted[i];
				if (buffer.length == 0) var xstr:String = String(current.charCodeAt(0));
				else var xstr:String = buffer.join("-")+"-"+String(current.charCodeAt(0));
				if (dict[xstr] !== undefined){
					buffer.push(current.charCodeAt(0));
				} else {
					result += String.fromCharCode(dict[buffer.join("-")]);
					dict[xstr] = chars;
					chars++;
					delete buffer;
					buffer = new Array();
					buffer.push(current.charCodeAt(0));
				}
			}
			return result;
		}
	
		/**
		* Decompresses the specified text.
		*/
		public static function decompress(src:String):String {
			var chars:Number = 256;
			var dict:Array = new Array();
			for (var i:Number = 0; i<chars; i++) {
				var c:String = String.fromCharCode(i);
				dict[i] = c;
			}
			var original:String = src;
			var splitted:Array = original.split("");
			var buffer:String = new String("");
			var chain:String = new String("");
			var result:String = new String("");
			for (var i:Number = 0; i<splitted.length; i++) {
				var code:Number = original.charCodeAt(i);
				var current:String = dict[code];
				if (buffer == "") {
					buffer = current;
					result += current;
				} else {
					if (code<=255) {
						result += current;
						chain = buffer+current;
						dict[chars] = chain;
						chars++;
						buffer = current;
					} else {
						chain = dict[code];
						if (chain == undefined) chain = buffer+buffer.slice(0,1);
						result += chain;
						dict[chars] = buffer+chain.slice(0,1);
						chars++;
						buffer = chain;
					}
				}
			}
			return result;
		}
	
	}
}