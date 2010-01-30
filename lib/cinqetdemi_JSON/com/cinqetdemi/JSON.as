package com.cinqetdemi
{ 
	/*
	Copyright (c) 2005 JSON.org
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The Software shall be used for Good, not Evil.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
	*/
	
	/*
	ported to Actionscript May 2005 by Trannie Carter <tranniec@designvox.com>, wwww.designvox.com
	USAGE:
		import cinqetdemi.JSON;
		try {
			var o:Object = JSON.parse(jsonStr);
			var s:String = JSON.stringify(obj);
		} catch(e:Error) {
			trace(ex);
		}
	
	*/
	/**
	 * Modified by Patrick Mineault, www.5etdemi.com/blog
	 * Mods: Support for keys not surrounded by quotes
	 *       Support for strings surrounded by single quotes instead of double quotes
	 *       Support for trailing comma (,) as in Python
	 *       Compiles under MTASC
	 *       Support for hexadecimal numbers
	 *       More verbose error output, error is instance of Error
	 */
	
	public class JSON 
	{
	    public var at:Number = 0;
	    public var ch:String = ' ';
	    public var text:String;
		
		static public var inst:JSON;
	    
		static public function getInstance():JSON
		{
			if(inst == null)
			{
				inst = new JSON();
			}
			return inst;
		}
		
		/**
		 * Transform an actionscript object to a JSON string
		 * @param arg The object to jsonize
		 * @returns The JSON string
		 */
	    static public function stringify(arg:Object) : String
	    {
	        var c:String;
	        var cc:Number;
	        var i:Number;
	        var key:String;
	        var l:Number;
	        var s:String = '';
	        var v:Object;
	
	        switch (typeof arg)
	        {
	        case 'object':
	            if (arg) {
	                if (arg is Array) {
	                    for (i = 0; i < arg.length; ++i) {
	                        v = stringify(arg[i]);
	                        if (s) {
	                            s += ',';
	                        }
	                        s += v;
	                    }
	                    return '[' + s + ']';
	                } else if (typeof arg.toString != 'undefined') {
	                    for (key in arg) {
	                        v = arg[key];
	                        if (typeof v != 'undefined' && typeof v != 'function') {
	                            v = stringify(v);
	                            if (s) {
	                                s += ',';
	                            }
	                            s += stringify(key) + ':' + v;
	                        }
	                    }
	                    return '{' + s + '}';
	                }
	            }
	            return 'null';
	        case 'number':
	            return isFinite(arg as Number) ? String(arg) : 'null';
	        case 'string':
	            l = arg.length;
	            s = '"';
	            for (i = 0; i < l; i += 1)
	            {
	                c = arg.charAt(i);
	                if (c >= ' ') {
	                    if (c == '\\' || c == '"')
	                    {
	                        s += '\\';
	                    }
	                    s += c;
	                }
	                else
	                {
	                    switch (c) {
	                        case '\b':
	                            s += '\\b';
	                            break;
	                        case '\f':
	                            s += '\\f';
	                            break;
	                        case '\n':
	                            s += '\\n';
	                            break;
	                        case '\r':
	                            s += '\\r';
	                            break;
	                        case '\t':
	                            s += '\\t';
	                            break;
	                        default:
	                            cc = c.charCodeAt();
	                            s += '\\u00' + Math.floor(cc / 16).toString(16) +
	                                (cc % 16).toString(16);
	                    }
	                }
	            }
	            return s + '"';
	        case 'boolean':
	            return String(arg);
	        default:
	            return 'null';
	        }
	    }
	
		/**
		 * Parse a JSON string and return an ActionScript object
		 * @param text The string to parse
		 * @returns The outputted ActionScript object
		 */
	    public static function parse(text:String):Object
	    {
	
			var inst:JSON = getInstance();
			inst.at = 0;
			inst.ch = ' ';
			inst.text = text;
	
	        return inst.value();
	
	    }
	    
		protected function error(m:String) : void
		{
			var firstLine:String = "JSONError: " + m + " at " + (at - 1) + "\n";
			firstLine += text.substr(at - 10, 20) + "\n";
			firstLine += "        ^";
		    throw new Error(firstLine);
		}
		
		protected function next() : String
		{
		    ch = text.charAt(at);
		    at += 1;
		    return ch;
		}
		
		protected function white() : void
		{
		    while (ch) {
		        if (ch <= ' ') {
		            this.next();
		        } else if (ch == '/') {
		            switch (this.next()) {
		                case '/':
		                    while (this.next() && ch != '\n' && ch != '\r') {}
		                    break;
		                case '*':
		                    this.next();
		                    while(true) {
		                        if (ch) {
		                            if (ch == '*') {
		                                if (this.next() == '/') {
		                                    next();
		                                    break;
		                                }
		                            } else {
		                                this.next();
		                            }
		                        } else {
		                            error("Unterminated comment");
		                        }
		                    }
		                    break;
		                default:
		                    this.error("Syntax error");
		            }
		        } else {
		            break;
		        }
		    }
		}
		
		protected function str() : String
		{
		    var i:Number;
	        var s:String = '';
	        var t:Number;
	        var u:Number;
		    var outer:Boolean = false;
		
		    if (ch == '"' || ch == "'")
		    {
		    	var outerChar:String = ch;
		        while (this.next())
				{
		            if (ch == outerChar)
		            {
		                this.next();
		                return s;
		            }
		            else if (ch == '\\')
		            {
		                switch (this.next())
		                {
		                case 'b':
		                    s += '\b';
		                    break;
		                case 'f':
		                    s += '\f';
		                    break;
		                case 'n':
		                    s += '\n';
		                    break;
		                case 'r':
		                    s += '\r';
		                    break;
		                case 't':
		                    s += '\t';
		                    break;
		                case 'u':
		                    u = 0;
		                    for (i = 0; i < 4; i += 1)
		                    {
		                        t = parseInt(this.next(), 16);
		                        if (!isFinite(t))
		                        {
		                            outer = true;
		                            break;
		                        }
		                        u = u * 16 + t;
		                    }
		                    if(outer)
		                    {
		                        outer = false;
		                        break;
		                    }
		                    s += String.fromCharCode(u);
		                    break;
		                default:
		                    s += ch;
		                }
		            } else {
		                s += ch;
		            }
		        }
		    }
		    this.error("Bad string");
		    return null;
		}
		
		protected function key() : String
		{
		    var s:String = ch;
		    var outer:Boolean = false;
			
			var semiColon:Number = text.indexOf(':', at);
			
			//Use string handling
			var quoteIndex:Number = text.indexOf('"', at);
			var squoteIndex:Number = text.indexOf("'", at);
			if((quoteIndex <= semiColon && quoteIndex > -1) || (squoteIndex <= semiColon && squoteIndex > -1))
			{
				s = str();
				white();
				if(ch == ':')
				{
					return s;
				}
				else
				{
					this.error("Bad key");
				}
			}
		
			//Use key handling
	        while (this.next()) {
	            if (ch == ':') {
	                return s;
	            } 
	            if(ch <= ' ')
	            {
	            	
	            }
	            else
	            {
	            	s += ch;
	            }
		    }
		    this.error("Bad key");
		    return null;
		}
		
		protected function arr() : Array
		{
		    var a:Array = [];
		
		    if (ch == '[') {
		        this.next();
		        this.white();
		        if (ch == ']') {
		            this.next();
		            return a;
		        }
		        while (ch) {
		        	if(ch == ']')
		        	{
		                this.next();
		                return a;
		        	}
		            a.push(this.value());
		            this.white();
		            if (ch == ']') {
		                this.next();
		                return a;
		            } else if (ch != ',') {
		                break;
		            }
		            this.next();
		            this.white();
		        }
		    }
		    this.error("Bad array");
		    return null;
		}
		
		protected function obj() : Object
		{
		    var k:String, o:Object = {};
		
		    if (ch == '{') {
		        this.next();
		        this.white();
		        if (ch == '}') {
		            this.next();
		            return o;
		        }
		        while (ch) {
		        	if(ch == '}')
		        	{
		                this.next();
		                return o;
		        	}
		            k = this.key();
		            if (ch != ':') {
		                break;
		            }
		            this.next();
		            o[k] = this.value();
		            this.white();
		            if (ch == '}') {
		                this.next();
		                return o;
		            } else if (ch != ',') {
		                break;
		            }
		            this.next();
		            this.white();
		        }
		    }
		    this.error("Bad object");
		    return null;
		}
		
		protected function num() : Number
		{
		    var n:String = '', v:Number;
		
		    if (ch == '-') {
		        n = '-';
		        this.next();
		    }
		    while ((ch >= '0' && ch <= '9') || 
		    		ch == 'x' || 
		    		(ch >= 'a' && ch <= 'f') ||
		    		(ch >= 'A' && ch <= 'F')) {
		        n += ch;
		        this.next();
		    }
		    if (ch == '.') {
		        n += '.';
		        this.next();
		        while (ch >= '0' && ch <= '9') {
		            n += ch;
		            this.next();
		        }
		    }
		    if (ch == 'e' || ch == 'E') {
		        n += ch;
		        this.next();
		        if (ch == '-' || ch == '+') {
		            n += ch;
		            this.next();
		        }
		        while (ch >= '0' && ch <= '9') {
		            n += ch;
		            this.next();
		        }
		    }
		    v = Number(n);
		    if (!isFinite(v)) {
		        this.error("Bad number");
		    }
		    return v;
		}
		
		protected function word() : Boolean {
		    switch (ch) {
		        case 't':
		            if (this.next() == 'r' && this.next() == 'u' &&
		                    this.next() == 'e') {
		                this.next();
		                return true;
		            }
		            break;
		        case 'f':
		            if (this.next() == 'a' && this.next() == 'l' &&
		                    this.next() == 's' && this.next() == 'e') {
		                this.next();
		                return false;
		            }
		            break;
		        case 'n':
		            if (this.next() == 'u' && this.next() == 'l' &&
		                    this.next() == 'l') {
		                this.next();
		   				//TODO: check if an exception should be thrown
		                return false;
		            }
		            break;
		    }
		    this.error("Syntax error");
		    //TODO: check if an exception should be thrown
		    return false;
		}
		
		protected function value() : Object {
		    this.white();
		    switch (ch) {
		        case '{':
		            return this.obj();
		        case '[':
		            return this.arr();
		        case '"':
		        case "'":
		            return this.str();
		        case '-':
		            return this.num();
		        default:
		            return ch >= '0' && ch <= '9' ? this.num() : this.word();
		    }
		}
	
	}
}