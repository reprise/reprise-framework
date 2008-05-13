package com.meychi.ascrypt { 
	/**
	* Calculates the SHA1 checksum.
	* @authors Mika Palmu
	* @version 2.0
	*
	* Original Javascript implementation:
	* Secure Hash Algorithm, SHA-1, as defined in FIPS PUB 180-1
	* Version 2.1 Copyright Paul Johnston 2000 - 2002
	* Other contributors: Greg Holt, Andrew Kepert, Ydnar, Lostinet
	* See http://pajhome.org.uk/crypt/md5 for more info.
	*/
	
	public class SHA1 {
	
		/**
		* Calculates the SHA1 checksum.
		*/
		public static function calculate(src:String):String {
			return hex_sha1(src);
		}
	
		/**
		* Private methods.
		*/
		protected static function hex_sha1(src:String):String {
			return binb2hex(core_sha1(str2binb(src), src.length*8));
		}
		protected static function core_sha1(x:Array, len:Number):Array {
			x[len >> 5] |= 0x80 << (24-len%32);
			x[((len+64 >> 9) << 4)+15] = len;
			var w:Array = new Array(80), a:Number = 1732584193;
			var b:Number = -271733879, c:Number = -1732584194;
			var d:Number = 271733878, e:Number = -1009589776;
			for (var i:Number = 0; i<x.length; i += 16) {
				var olda:Number = a, oldb:Number = b;
				var oldc:Number = c, oldd:Number = d, olde:Number = e;
				for (var j:Number = 0; j<80; j++) {
					if (j<16) w[j] = x[i+j];
					else w[j] = rol(w[j-3] ^ w[j-8] ^ w[j-14] ^ w[j-16], 1);
					var t:Number = safe_add(safe_add(rol(a, 5), sha1_ft(j, b, c, d)), safe_add(safe_add(e, w[j]), sha1_kt(j)));
					e = d; d = c;
					c = rol(b, 30);
					b = a; a = t;
				}
				a = safe_add(a, olda);
				b = safe_add(b, oldb);
				c = safe_add(c, oldc);
				d = safe_add(d, oldd);
				e = safe_add(e, olde);
			}
			return new Array(a, b, c, d, e);
		}
		protected static function sha1_ft(t:Number, b:Number, c:Number, d:Number):Number {
			if (t<20) return (b & c) | ((~b) & d);
			if (t<40) return b ^ c ^ d;
			if (t<60) return (b & c) | (b & d) | (c & d);
			return b ^ c ^ d;
		}
		protected static function sha1_kt(t:Number):Number {
			return (t<20) ? 1518500249 : (t<40) ? 1859775393 : (t<60) ? -1894007588 : -899497514;
		}
		protected static function safe_add(x:Number, y:Number):Number {
			var lsw:Number = (x & 0xFFFF)+(y & 0xFFFF);
			var msw:Number = (x >> 16)+(y >> 16)+(lsw >> 16);
			return (msw << 16) | (lsw & 0xFFFF);
		}
		protected static function rol(num:Number, cnt:Number):Number {
			return (num << cnt) | (num >>> (32-cnt));
		}
		protected static function str2binb(str:String):Array {
			var bin:Array = new Array();
			var mask:Number = (1 << 8)-1;
			for (var i:Number = 0; i<str.length*8; i += 8) {
				bin[i >> 5] |= (str.charCodeAt(i/8) & mask) << (24-i%32);
			}
			return bin;
		}
		protected static function binb2hex(binarray:Array):String {
			var str:String = new String("");
			var tab:String = new String("0123456789abcdef");
			for (var i:Number = 0; i<binarray.length*4; i++) {
				str += tab.charAt((binarray[i >> 2] >> ((3-i%4)*8+4)) & 0xF) + tab.charAt((binarray[i >> 2] >> ((3-i%4)*8)) & 0xF);
			}
			return str;
		}
	
	}
}