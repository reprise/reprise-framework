package com.meychi.ascrypt { 
	/**
	* Encrypts and decrypts text with the Rijndael algorithm.
	* @authors Mika Palmu
	* @version 2.0
	*
	* Original Javascript implementation:
	* Fritz Schneider, University of California
	* Algorithm: Joan Daemen and Vincent Rijmen
	* See http://www.cs.ucsd.edu/~fritz/rijndael.html
	*/
	
	public class Rijndael {
	
		/**
		* Variables
		* @exclude
		*/
		protected var roundsArray:Array;
		protected var shiftOffsets:Array;
		protected var Nr:Number, Nk:Number, Nb:Number;
		protected var Rcon:Array = [0x01, 0x02, 0x04, 0x08, 0x10, 0x20,0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8,0xab, 0x4d, 0x9a, 0x2f, 0x5e, 0xbc,0x63, 0xc6, 0x97, 0x35, 0x6a, 0xd4,0xb3, 0x7d, 0xfa, 0xef, 0xc5, 0x91 ];
		protected var SBox:Array = [ 99, 124, 119, 123, 242, 107, 111, 197, 48, 1, 103, 43, 254, 215, 171, 118, 202, 130, 201, 125, 250, 89, 71, 240, 173, 212, 162, 175, 156, 164, 114, 192, 183, 253, 147, 38, 54, 63, 247, 204, 52, 165, 229, 241, 113, 216, 49, 21, 4, 199, 35, 195, 24, 150, 5, 154, 7, 18, 128, 226, 235, 39, 178, 117, 9, 131, 44, 26, 27, 110, 90, 160, 82, 59, 214, 179, 41, 227, 47, 132,  83, 209, 0, 237, 32, 252, 177, 91, 106, 203, 190, 57, 74, 76, 88, 207, 208, 239, 170, 251, 67, 77, 51, 133, 69, 249, 2, 127, 80, 60, 159, 168, 81, 163, 64, 143, 146, 157, 56, 245, 188, 182, 218, 33, 16, 255, 243, 210, 205, 12, 19, 236, 95, 151, 68, 23, 196, 167, 126, 61, 100, 93, 25, 115, 96, 129, 79, 220, 34, 42, 144, 136, 70, 238, 184, 20, 222, 94, 11, 219, 224, 50, 58, 10, 73, 6, 36, 92, 194, 211, 172, 98, 145, 149, 228, 121, 231, 200, 55, 109, 141, 213, 78, 169, 108, 86, 244, 234, 101, 122, 174, 8, 186, 120, 37, 46, 28, 166, 180, 198, 232, 221, 116, 31, 75, 189, 139, 138, 112, 62, 181, 102, 72, 3, 246, 14, 97, 53, 87, 185, 134, 193, 29, 158, 225, 248, 152, 17, 105, 217, 142, 148, 155, 30, 135, 233, 206, 85, 40, 223, 140, 161, 137, 13, 191, 230, 66, 104, 65, 153, 45, 15, 176, 84, 187, 22];
		protected var SBoxInverse:Array = [ 82, 9, 106, 213, 48, 54, 165, 56, 191, 64, 163, 158, 129, 243, 215, 251, 124, 227, 57, 130, 155, 47, 255, 135, 52, 142, 67, 68, 196, 222, 233, 203, 84, 123, 148, 50, 166, 194, 35, 61, 238, 76, 149, 11, 66, 250, 195, 78, 8, 46, 161, 102, 40, 217, 36, 178, 118, 91, 162, 73, 109, 139, 209, 37, 114, 248, 246, 100, 134, 104, 152, 22, 212, 164, 92, 204, 93, 101, 182, 146, 108, 112, 72, 80, 253, 237, 185, 218, 94, 21, 70, 87, 167, 141, 157, 132, 144, 216, 171, 0, 140, 188, 211, 10, 247, 228, 88, 5, 184, 179, 69, 6, 208, 44, 30, 143, 202, 63, 15, 2, 193, 175, 189, 3, 1, 19, 138, 107, 58, 145, 17, 65, 79, 103,220, 234, 151, 242, 207, 206, 240, 180, 230, 115, 150, 172, 116, 34, 231, 173, 53, 133, 226, 249, 55, 232, 28, 117, 223, 110, 71, 241, 26, 113, 29, 41, 197, 137, 111, 183, 98, 14, 170, 24, 190, 27, 252, 86, 62, 75, 198, 210, 121, 32, 154, 219, 192, 254, 120, 205, 90, 244, 31, 221, 168, 51, 136, 7, 199, 49, 177, 18, 16, 89, 39, 128, 236, 95, 96, 81, 127, 169, 25, 181, 74, 13, 45, 229, 122, 159, 147, 201, 156, 239, 160, 224, 59, 77, 174, 42, 245, 176, 200, 235, 187, 60, 131, 83, 153, 97, 23, 43, 4, 126, 186, 119, 214, 38, 225, 105, 20, 99, 85, 33, 12, 125];
		public var blockSize:Number = 128;
		public var keySize:Number = 128;
	
		/**
		* Constructor
		* @exclude
		*/
		public function Rijndael(keySize:Number, blockSize:Number){
			if (keySize != null) this.keySize = keySize;
			if (blockSize != null) this.blockSize = blockSize;
			this.roundsArray = [0,0,0,0,[0,0,0,0,10,0,12,0,14],0,[0,0,0,0,12,0,12,0,14],0,[0,0,0,0,14,0,14,0,14]];
			this.shiftOffsets = [0,0,0,0,[0,1,2,3],0,[0,1,2,3],0,[0,1,3,4]];
			this.Nb = blockSize / 32; this.Nk = keySize / 32;
			this.Nr = this.roundsArray[this.Nk][this.Nb];
		}
	
		/**
		* Encrypts a string with the specified key and mode.
		*/
		public function encrypt(src:String, key:String, mode:String):String {
			var ct:Array = new Array();
			var aBlock:Array = new Array();
			var bpb:Number = this.blockSize / 8;
			if (mode == "CBC") ct = this.getRandomBytes(bpb);
			var chars:Array = this.formatPlaintext(strToChars(src));
			var expandedKey:Array = this.keyExpansion(strToChars(key));
			for (var block:Number = 0; block<chars.length / bpb; block++) {
				aBlock = chars.slice(block*bpb, (block+1)*bpb);
				if (mode == "CBC") {
					for (var i:Number = 0; i<bpb; i++) {
						aBlock[i] ^= ct[block*bpb + i];
					}
				}
				ct = ct.concat(this.encryption(aBlock, expandedKey));
			}
			return charsToHex(ct);
		}
	
		/**
		* Decrypts a string with the specified key and mode.
		*/
		public function decrypt(src:String, key:String, mode:String):String {
			var pt:Array = new Array();
			var aBlock:Array = new Array();
			var chars:Array = hexToChars(src);
			var bpb:Number = this.blockSize / 8;
			var expandedKey:Array = this.keyExpansion(strToChars(key));
			for (var block:Number = (chars.length/bpb)-1; block>0; block--) {
				aBlock = decryption(chars.slice(block*bpb, (block+1)*bpb), expandedKey);
				if(mode == "CBC") {
					for (var i:Number = 0; i<bpb; i++) {
						pt[(block-1)*bpb+i] = aBlock[i] ^ chars[(block-1)*bpb+i];
					}
				}
				else pt = aBlock.concat(pt);
			}
			if (mode == "ECB") {
				pt = this.decryption(chars.slice(0,bpb), expandedKey).concat(pt);
			}
			return charsToStr(pt);
		}
	
		/**
		* Private methods.
		*/
		protected function cyclicShiftLeft(src:Array, pos:Number):Array {
			var temp:Array = src.slice(0, pos);
			src = src.slice(pos).concat(temp);
			return src;
		}
		protected function xtime(poly:Number):Number {
			poly <<= 1;
			return ((poly & 0x100) ? (poly ^ 0x11B) : (poly));
		}
		protected function mult_GF256(x:Number, y:Number):Number {
			var result:Number = 0;
			for (var bit:Number = 1; bit<256; bit *= 2, y = xtime(y)) {
				if(x & bit) result ^= y;
			}
			return result;
		}
		protected function byteSub(state:Array, dir:String):void {
			if(dir == "encrypt") var S:Array = this.SBox;
			else var S:Array = this.SBoxInverse;
			for (var i:Number = 0; i<4; i++) {
				for (var j:Number = 0; j<this.Nb; j++) state[i][j] = S[state[i][j]];
			}
		}
		protected function shiftRow(state:Array, dir:String):void {
			for (var i:Number = 1; i<4; i++) {
				if (dir == "encrypt") state[i] = this.cyclicShiftLeft(state[i], this.shiftOffsets[Nb][i]);
				else state[i] = this.cyclicShiftLeft(state[i], this.Nb-this.shiftOffsets[Nb][i]);
			}
		}
		protected function mixColumn(state:Array, dir:String):void {
			var b:Array = new Array();
			for (var j:Number = 0; j<this.Nb; j++) {
				for(var i:Number = 0; i<4; i++) {
					if (dir == "encrypt") b[i] = this.mult_GF256(state[i][j], 2) ^ this.mult_GF256(state[(i+1)%4][j], 3) ^ state[(i+2)%4][j] ^ state[(i+3)%4][j];
					else b[i] = this.mult_GF256(state[i][j], 0xE) ^ this.mult_GF256(state[(i+1)%4][j], 0xB) ^ this.mult_GF256(state[(i+2)%4][j], 0xD) ^ this.mult_GF256(state[(i+3)%4][j], 9);
				}
				for (var i:Number = 0; i<4; i++) {
					state[i][j] = b[i];
				}
			}
		}
		protected function addRoundKey(state:Array, roundKey:Array):void {
			for (var j:Number = 0; j<this.Nb; j++) {
				state[0][j] ^= (roundKey[j] & 0xFF);
				state[1][j] ^= ((roundKey[j]>>8) &0xFF);
				state[2][j] ^= ((roundKey[j]>>16) &0xFF);
				state[3][j] ^= ((roundKey[j]>>24) &0xFF);
			}
		}
		protected function keyExpansion(key:Array):Array {
			var temp:Number = 0;
			this.Nk = this.keySize/32;
			this.Nb = this.blockSize/32;
			var expandedKey:Array = new Array();
			this.Nr = this.roundsArray[this.Nk][this.Nb];
			for (var j:Number = 0; j<this.Nk; j++) expandedKey[j] = (key[4*j]) | (key[4*j+1]<<8) | (key[4*j+2]<<16) | (key[4*j+3]<<24);
			for (var j:Number = this.Nk; j<this.Nb*(this.Nr+1); j++) {
				temp = expandedKey[j-1];
				if (j % this.Nk == 0) temp = ( (this.SBox[(temp>>8) & 0xFF]) | (this.SBox[(temp>>16) & 0xFF]<<8) | (this.SBox[(temp>>24) & 0xFF]<<16) | (this.SBox[temp & 0xFF]<<24) ) ^ this.Rcon[Math.floor(j / this.Nk) - 1];
				else if (this.Nk > 6 && j % this.Nk == 4) temp = (this.SBox[(temp>>24) & 0xFF]<<24) | (this.SBox[(temp>>16) & 0xFF]<<16) | (this.SBox[(temp>>8) & 0xFF]<<8) | (this.SBox[temp & 0xFF]);
				expandedKey[j] = expandedKey[j-this.Nk] ^ temp;
			}
			return expandedKey;
		}
		protected function Round(state:Array, roundKey:Array):void {
			this.byteSub(state, "encrypt");
			this.shiftRow(state, "encrypt");
			this.mixColumn(state, "encrypt");
			this.addRoundKey(state, roundKey);
		}
		protected function InverseRound(state:Array, roundKey:Array):void {
			this.addRoundKey(state, roundKey);
			this.mixColumn(state, "decrypt");
			this.shiftRow(state, "decrypt");
			this.byteSub(state, "decrypt");
		}
		protected function FinalRound(state:Array, roundKey:Array):void {
			this.byteSub(state, "encrypt");
			this.shiftRow(state, "encrypt");
			this.addRoundKey(state, roundKey);
		}
		protected function InverseFinalRound(state:Array, roundKey:Array):void {
			this.addRoundKey(state, roundKey);
			this.shiftRow(state, "decrypt");
			this.byteSub(state, "decrypt");
		}
		protected function encryption(block:Array, expandedKey:Array):Array {
			block = this.packBytes(block);
			this.addRoundKey(block, expandedKey);
			for (var i:Number = 1; i<Nr; i++) {
				this.Round(block, expandedKey.slice(this.Nb*i, this.Nb*(i+1)));
			}
			this.FinalRound(block, expandedKey.slice(this.Nb*this.Nr));
			return this.unpackBytes(block);
		}
		protected function decryption(block:Array, expandedKey:Array):Array {
			block = this.packBytes(block);
			this.InverseFinalRound(block, expandedKey.slice(this.Nb*this.Nr));
			for (var i:Number = Nr-1; i>0; i--) {
				this.InverseRound(block, expandedKey.slice(this.Nb*i, this.Nb*(i+1)));
			}
			this.addRoundKey(block, expandedKey);
			return this.unpackBytes(block);
		}
		protected function packBytes(octets:Array):Array {
			var state:Array = new Array();
			state[0] = new Array(); state[1] = new Array();
			state[2] = new Array(); state[3] = new Array();
			for (var j:Number = 0; j<octets.length; j+= 4) {
				state[0][j/4] = octets[j];
				state[1][j/4] = octets[j+1];
				state[2][j/4] = octets[j+2];
				state[3][j/4] = octets[j+3];
			}
			return state;
		}
		protected function unpackBytes(packed:Array):Array {
			var result:Array = new Array();
			for (var j:Number = 0; j<packed[0].length; j++) {
				result[result.length] = packed[0][j];
				result[result.length] = packed[1][j];
				result[result.length] = packed[2][j];
				result[result.length] = packed[3][j];
			}
			return result;
		}
		protected function formatPlaintext(plaintext:Array):Array {
			var bpb:Number = blockSize / 8;
			for (var i:Number = bpb-(plaintext.length % bpb); i>0 && i<bpb; i--) {
				plaintext[plaintext.length] = 0;
			}
			return plaintext;
		}
		protected function getRandomBytes(howMany:Number):Array {
			var bytes:Array = new Array();
			for (var i:Number = 0; i<howMany; i++) {
				bytes[i] = Math.round(Math.random()*255);
			}
			return bytes;
		}
		protected function hexToChars(hex:String):Array {
			var codes:Array = new Array();
			for (var i:Number = (hex.substr(0, 2) == "0x") ? 2 : 0; i<hex.length; i+=2) {
				codes.push(parseInt(hex.substr(i, 2), 16));
			}
			return codes;
		}
		protected function charsToHex(chars:Array):String {
			var result:String = new String("");
			var hexes:Array = new Array("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f");
			for (var i:Number = 0; i<chars.length; i++) {
				result += hexes[chars[i] >> 4] + hexes[chars[i] & 0xf];
			}
			return result;
		}
		protected function charsToStr(chars:Array):String {
			var result:String = new String("");
			for (var i:Number = 0; i<chars.length; i++) {
				result += String.fromCharCode(chars[i]);
			}
			return result;
		}
		protected function strToChars(str:String):Array {
			var codes:Array = new Array();
			for (var i:Number = 0; i<str.length; i++) {
				codes.push(str.charCodeAt(i));
			}
			return codes;
		}
	
	}
}