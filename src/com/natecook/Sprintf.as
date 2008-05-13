package com.natecook { 
	/*
		Sprintf, v2.0
		February 24, 2004
		(c) 2003 Nate Cook
	
		Get (sparse) documentation and version updates at:
		http://www.natecook.com/downloads/
	
		This is an Actionscript version of the sprintf function, as based
		mostly on documentation in the printf(3) man page on OS X - another
		version is found at:
		http://developer.apple.com/documentation/Darwin/Reference/ManPages/html/printf.3.html
		
		Support for all elements is not entirely in place, mostly because
		the translation from C to a scripting language like Actionscript
		loses some pieces by default, like pointer references and all the
		AltiVec stuff mentioned on the above page. If you think there's
		something that could be added that isn't supported, let me know.
	
		This file may be distributed and used in any projects (commercial or
		not) as long as it is unaltered and this notice is intact. I'd love
		to hear from you with feedback, about bugs, ideas for further
		features, etc. Thanks!	
		
		USAGE:
		Sprintf.format(format, [args...])
			implementation of c-style string formatting
		Sprintf.trace(format, [args...])
			shortcut to trace a formatted string
	
		ERRORS:
		By default all errors are silently ignored (since that's what makes sense to me).
		To see error messages in trace output, use this line:
			Sprintf.TRACE = true;
		To see error messages in the result output, use this line:
			Sprintf.DEBUG = true;
			
			
		VERSION HISTORY
		v2.0	Wrapped into an AS2.0 class by Patrick Mineault (thanks!)
				http://www.5etdemi.com/
				http://www.5etdemi.com/blog/
		v1.1	Changed file name, other changes for AS2.0 compatibility
		v1.0	Initial release.
	  
	*/
	
	public class Sprintf
	{
		// -=-=-=-=-=-=-=-=-=-=-=-=-=-
		// "constants"
		// -=-=-=-=-=-=-=-=-=-=-=-=-=-
		static public var kPAD_ZEROES:Number = 0x01;
		static public var kLEFT_ALIGN:Number = 0x02;
		static public var kSHOW_SIGN:Number = 0x04;
		static public var kPAD_POS:Number = 0x08;
		static public var kALT_FORM:Number = 0x10;
		static public var kLONG_VALUE:Number = 0x20;
		static public var kUSE_SEPARATOR:Number = 0x40;
		
		static public var DEBUG:Boolean	= false;
		static public var TRACE:Boolean	= false;
		
		static public function log(...args):void
		{
			trace(Sprintf.format.apply(null,args));
		}
		
		static public function format(format:String, ...args):String
		{
			if (format == null) return '';
		
			var destString:String = '';
			var argIndex:Number = 0;		// our place in arguments[] 
			var formatIndex:Number = 0;		// our place in the format string
			var percentIndex:Number;			// the location of the next '%' delimiter
			var ch:String;
			
			// -=-=-=-=-=-=-=-=-=-=-=-=-=- vars for dealing with each field
			var value:Object;
			var length:Number;
			var precision:Number;
			var properties:Number;				// options: left justified, zero padding, etc...
			var fieldCount:Number;				// tracks number of sections in field 
			var fieldOutcome:Object;			// when set to true, field parsed successfully
										// when set to a string, error resulted
			
			while (formatIndex < format.length) {
				percentIndex = format.indexOf('%',formatIndex);
				if (percentIndex == -1) {
					destString += format.substr(formatIndex);
					formatIndex = format.length;
				} else {
					destString += format.substring(formatIndex,percentIndex);
		
					fieldOutcome = '** sprintf: invalid format at ' + argIndex + ' **';
					length = properties = fieldCount = 0;
					precision = -1;
					formatIndex = percentIndex + 1;
					value = args[argIndex++];
					
					while (fieldOutcome != true && (formatIndex < format.length)) {
						ch = format.charAt(formatIndex++);
						
						switch (ch) {
						
							
							// -=-=-=-=-=-=-=-=-=-=-=-=-=-
							// pre-processing items
							// -=-=-=-=-=-=-=-=-=-=-=-=-=-
							case '#':
								if (fieldCount == 0) {
									properties |= kALT_FORM;
								} else {
									fieldOutcome = '** sprintf: "#" came too late **';
								}
								break;
							case '-': 
								if (fieldCount == 0) {
									properties |= kLEFT_ALIGN;
								} else {
									fieldOutcome = '** sprintf: "-" came too late **';
								}
								break;
							case '+': 
								if (fieldCount == 0) {
									properties |= kSHOW_SIGN;
								} else {
									fieldOutcome = '** sprintf: "+" came too late **';
								}
								break;
							case ' ': 
								if (fieldCount == 0) {
									properties |= kPAD_POS;
								} else {
									fieldOutcome = '** sprintf: " " came too late **';
								}
								break;
							case '.': 
								if (fieldCount < 2) {
									fieldCount = 2;
									precision = 0;
								} else {
									fieldOutcome = '** sprintf: "." came too late **';
								}
								break;
							/*
							case 'h': 
								if (fieldCount < 3) {
									fieldCount = 3;
								} else {
									fieldOutcome = '** sprintf: must have only one of h,l,L **';
								}
								break;
							case 'l':
							case 'L': 
								if (fieldCount < 3) {
									fieldCount = 3;
									properties |= kLONG_VALUE;
								} else {
									fieldOutcome = '** sprintf: must have only one of h,l,L **';
								}
								break;
							*/
							case '0':
								if (fieldCount == 0) {
									properties |= kPAD_ZEROES;
									break;
								}
							case '1':
							case '2':
							case '3':
							case '4': 
							case '5': 
							case '6': 
							case '7': 
							case '8': 
							case '9': 
								if (fieldCount == 3) {
									fieldOutcome = '** sprintf: shouldn\'t have a digit after h,l,L **';
								} else if (fieldCount < 2) {
									fieldCount = 1;
									length = (length * 10) + Number(ch);
								} else {
									precision = (precision * 10) + Number(ch);
								}
								break;
		
							// -=-=-=-=-=-=-=-=-=-=-=-=-=-
							// conversion specifiers
							// -=-=-=-=-=-=-=-=-=-=-=-=-=-
							case 'd':
							case 'i':
								fieldOutcome = true;
								destString += Sprintf.formatD(Number(value),properties,length,precision);
								break;						
							case 'o':
								fieldOutcome = true;
								destString += Sprintf.formatO(Number(value),properties,length,precision);
								break;						
							case 'x':
							case 'X':
								fieldOutcome = true;
								destString += Sprintf.formatX(Number(value),properties,length,precision,(ch == 'X'));
								break;						
							case 'e':
							case 'E':
								fieldOutcome = true;
								destString += Sprintf.formatE(Number(value),properties,length,precision,(ch == 'E'));
								break;						
							case 'f':
								fieldOutcome = true;
								destString += Sprintf.formatF(String(value),properties,length,precision);
								break;						
							case 'g':
							case 'G':
								fieldOutcome = true;
								destString += Sprintf.formatG(Number(value),properties,length,precision,(ch == 'G'));
								break;						
							case 'c':
							case 'C':
								precision = 1;
							case 's':
							case 'S':
								fieldOutcome = true;
								destString += Sprintf.formatS(String(value),properties,length,precision);
								break;					
							case '%':
								fieldOutcome = true;
								destString += '%';
								
								// we don't need a value for this, so back up
								argIndex--;
								break;
							default: 
								fieldOutcome = '** sprintf: ' + ch + ' not supported **';
								break;			
						}
					}
					
					if (fieldOutcome != true) {
						if (Sprintf.DEBUG) destString += fieldOutcome;
						if (Sprintf.TRACE) trace(fieldOutcome);
					}
				}
			}
			
			return destString;	
		}
	
		// -=-=-=-=-=-=-=-=-=-=-=-=-=-
		// formatting functions
		// -=-=-=-=-=-=-=-=-=-=-=-=-=-
		static public function finish(output : String, value : Object, 
			properties : Number, length : Number, precision : Number, 
			prefix : String = '') : String
		{
			if (prefix == null) prefix = '';
			
			// add sign to prefix
			if (value < 0) {
				prefix = '-' + prefix;
			} else if (properties & kSHOW_SIGN) {
				prefix = '+' + prefix;
			} else if (properties & kPAD_POS) {
				prefix = ' ' + prefix;
			}
			
			if ((length == 0) && (precision > -1)) {
				length = precision;
				properties |= kPAD_ZEROES;
			}
		
			// add padding
			while (output.length + prefix.length < length) {
				if (properties & kLEFT_ALIGN) {
					output = output + ' ';
				} else if (properties & kPAD_ZEROES) {
					output = '0' + output;
				} else {
					prefix = ' ' + prefix;
				}
			}
			
			return prefix + output;
		}
		
		// integer
		static public function formatD(value:Number,properties:Number,length:Number,precision:Number) : String
		{ 
			var output:String = '';
			value = Number(value);
			
			if ((precision != 0) || (value != 0)) {
				output = String(Math.floor(Math.abs(value)));
			}
			
			while (output.length < precision) 
			{
				output = '0' + output;
			}
			
			return Sprintf.finish(output,value,properties,length,precision);
		}
		
		// octal
		static public function formatO(value:Number,properties:Number,length:Number,precision:Number) : String
		{
			var output:String = '';
			var prefix:String = '';
			value = Number(value);
			
			if ((precision != 0) && (value != 0)) {
				output = value.toString(8);
			}
			
			if (properties & kALT_FORM) {
				prefix = '0';
			}
		
			while (output.length < precision) {
				output = '0' + output;
			}
			
			return Sprintf.finish(output,value,properties,length,precision,prefix);
		}
		
		// hexidecimal
		static public function formatX(value:Number,properties:Number,length:Number,precision:Number,upper:Boolean) : String
		{
			var output:String = '';
			var prefix:String = '';
			value = Number(value);
			
			if ((precision != 0) && (value != 0)) {
				output = value.toString(16);
			}
			
			if (properties & kALT_FORM) {
				prefix = '0x';
			}
			
			while (output.length < precision) {
				output = '0' + output;
			}
		
			if (upper) {
				prefix = prefix.toUpperCase();
				output = output.toUpperCase();
			} else {
				output = output.toLowerCase();	
				// Flash documentation isn't graphics.clear about what case the Number.toString() method uses
			}
			
			return Sprintf.finish(output,value,properties,length,precision,prefix);
		}
		
		// scientific notation
		static public function formatE(value:Number,properties:Number,length:Number,precision:Number,upper:Boolean) : String
		{
			var output:String = '';
			var expCount:Number = 0;
			var expCountStr:String;
			value = Number(value);
			
			if (Math.abs(value) > 1) {
				while (Math.abs(value) > 10) {
					value /= 10;
					expCount++;
				}
			} else {
				while (Math.abs(value) < 1) {
					value *= 10;
					expCount--;
				}
			}
			
			expCountStr = Sprintf.format('%c%+.2d',(upper ? 'E' : 'e'),expCount);
		
			if (properties & kLEFT_ALIGN) {
				// give small length
				output = Sprintf.formatF(String(value),properties,1,precision) + expCountStr;
				while (output.length < length) {
					output += ' ';
				}
			} else {
				output = Sprintf.formatF(String(value),properties,Math.max(length - expCountStr.length,0),precision) + expCountStr;
			}
			
			return output;
		}
		
		// float (or real)
		static public function formatF(value:String,properties:Number,length:Number,precision:Number) : String
		{
			var output:String = '';
			var intPortion:String = '';
			var decPortion:String = '';
		
			// unspecified precision defaults to 6
			if (precision == -1) {
				precision = 6;
			}
			
			value = new String(value);
			if (value.indexOf('.') == -1) {
				intPortion = (Math.abs(Number(value))).toString();
				decPortion = "0";
			} else {
				intPortion = (Math.abs(Number(value.substring(0,value.indexOf('.'))))).toString();
				decPortion = value.substr(value.indexOf('.') + 1);
			}
				
			// create decimal portion
			if (Number(decPortion) == 0) {
				decPortion = new String();
				while (decPortion.length < precision) decPortion += '0';
			} else {
			
				if (decPortion.length > precision) {
					var dec:Number = Math.round(Math.pow(10,precision) * Number('0.' + decPortion));
					if (((String(dec)).length > precision) && (dec != 0)) {
						decPortion = '0';
						intPortion = ((Math.abs(Number(intPortion)) + 1) * (Number(intPortion) >= 0 ? 1 : -1)).toString();
					} else {
						decPortion = dec.toString();
					}
				}
				
				if (decPortion.length < precision) {
					decPortion = new String(decPortion);
					while (decPortion.length < precision) decPortion += '0';
				}
			}
			
			// combine pieces
			if (precision == 0) {
				output = intPortion;
				if (properties & kALT_FORM) {
					output += '.';
				}
			} else {
				output = intPortion + '.' + decPortion;
			}
			
			return Sprintf.finish(output,value,properties,length,precision,'');	
		}
		
		// shorter of float or scientific
		static public function formatG(value:Number,properties:Number,length:Number,precision:Number,upper:Boolean) : String
		{
		
			// use 1 as the length for the test because the 
			// padded value will be the same -> not useful
			var out1:String = Sprintf.formatE(value,properties,1,precision,upper);
			var out2:String = Sprintf.formatF(String(value),properties,1,precision);
			
			if (out1.length < out2.length) {
				return Sprintf.formatE(value,properties,length,precision,upper);
			} else {
				return Sprintf.formatF(String(value),properties,length,precision);
			}	
		}
		
		// string
		static public function formatS(value:String,properties:Number,length:Number,precision:Number) : String
		{
			var output:String = new String(value);
		
			if ((precision > 0) && (precision < output.length)) {
				output = output.substring(0,precision);
			}
		
			// ignore unneeded flags
			properties &= ~(kPAD_ZEROES | kSHOW_SIGN | kPAD_POS | kALT_FORM);
			
			return Sprintf.finish(output,value,properties,length,precision,'');	
		}
	}
}