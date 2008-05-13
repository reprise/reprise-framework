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
	}
}