/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.data
{ 
	public class Range
	{
		
		public var location : int;
		public var length : int;
		
		
		public function Range(loc : int, len : int)
		{
			location = loc;
			length = len;
		}
		
		public function clone() : Range
		{
			return new Range(location, length);
		}
		
		public function containsLocation(loc : int) : Boolean
		{
			return loc >= location && loc < location + length;
		}
		
		public function toString():String
		{
			return '[Range] location: ' + location + ', length: ' + length;
		}
	}
}