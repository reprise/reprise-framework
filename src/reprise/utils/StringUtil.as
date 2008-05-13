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
	import reprise.data.Range;

	public class StringUtil
	{
		public static const CASEINSENSITIVE_SEARCH : int = 1;
		public static const BACKWARDS_SEARCH : int = 2;
		
		public static const CHAR_WHITESPACE : Array = [" ", "\t", "\n", "\r"];
		
		
		public function StringUtil() {}
		
		
		/**
		* lTrim removes whitespace from the beginning of a given string
		**/
		public static function lTrim(val : String) : String
		{
			var i : int;
			for (i = 0; i < val.length; i++)
			{
				if (!isWhitespace(val.charAt(i)))
				{
					break;
				}
			}
			return val.substr(i);
		}	
		
		/**
		* rTrim removes whitespace from the end of a given string
		**/
		public static function rTrim(val : String) : String
		{
			var i : int;
			for (i = val.length - 1; i >= 0; i--)
			{
				if (!isWhitespace(val.charAt(i)))
				{
					break;
				}
			}
			return val.substring(0, i + 1);
		}
		
		/**
		* trim removes surrounding whitespace from a given string
		**/
		public static function trim(val : String) : String
		{
			return lTrim(rTrim(val));
		}
		
		/**
		* kind of a convenience function which checks if a string 
		* consists of whitespace characters
		**/
		public static function isWhitespace(val : String) : Boolean
		{
			for (var i : int = val.length; i--;)
			{
				if (" \t\n\r".indexOf(val.charAt(i)) == -1)
				{
					return false;
				}
			}
			return true;
		}	
		
		/**
		* transforms the first character of a string to uppercase
		**/
		public static function ucFirst(input : String) : String
		{
			return input.charAt(0).toUpperCase() + input.substr(1);
		}
		
		public static function stringByDeletingCharactersInRange(
			input : String, range : Range) : String
		{
			var leftPart:String = input.substring(0, range.location);
			var rightPart:String = input.substring(range.location + range.length);
			return leftPart + rightPart;
		}
		
		public static function indexOfStringInRange(
			input : String, search : String, range:Range = null, options : int = 0) : int
		{
			if (options & CASEINSENSITIVE_SEARCH)
			{
				input = input.toLowerCase();
				search = search.toLowerCase();
			}
			
			var stringRange : String = input.substr(range.location, range.length);
			var index : int = options & BACKWARDS_SEARCH ? 
				stringRange.lastIndexOf(search) : stringRange.indexOf(search);
				
			if (index == -1)
			{
				return -1;
			}
			return range.location + index;
		}
		
		
		
		public static function stringBetweenMarkers(
			input:String, leftMarker:String, rightMarker:String, greedy:Boolean) : String
		{
			var leftIndex : int = input.indexOf(leftMarker);
			var rightIndex : int = greedy ? 
				input.lastIndexOf(rightMarker) : input.indexOf(rightMarker);
			
			if (leftIndex != -1 && rightIndex != -1)
			{
				return input.substring(leftIndex + 1, rightIndex);
			}
			return null;
		}
		
		public static function sliceStringBetweenMarkers(input:String, leftMarker:String, 
			rightMarker:String, greedy:Boolean, removeMarkers:Boolean) : Object
		{
			var leftIndex : int = input.indexOf(leftMarker);
			var rightIndex : int = greedy ? 
				input.lastIndexOf(rightMarker) : input.indexOf(rightMarker);
		
			if (leftIndex != -1 && rightIndex != -1)
			{
				var leftSlice : String = input.substring(0, leftIndex - 
					(removeMarkers ? 0 : leftMarker.length));
				var rightSlice : String = input.substring(rightIndex + 
					(removeMarkers ? 1 : rightMarker.length), input.length);
				var slice : String = 
					input.substring(leftIndex + leftMarker.length, rightIndex);
				
				return {result : leftSlice + rightSlice, slice : slice};
			}
			return {result : input};
		}
		
		public static function removeSubstringFromDelimitedString(
			str : String, substr : String, delimiter : String) : String
		{
			if (!str.length || str.indexOf(substr) == -1)
			{
				return str;
			}
			var list : Array = str.split(delimiter);
			for (var i:int = list.length; i--;)
			{
				if (list[i] == substr)
				{
					list.splice(i, 1);
				}
			}
			return list.join(delimiter);
		}
		
		public static function delimitedStringContainsSubstring(
			str : String, substr : String, delimiter : String) : Boolean
		{
			if (!str.length || str.indexOf(substr) == -1)
			{
				return false;
			}
			var list : Array = str.split(delimiter);
			for (var i:int = list.length; i--;)
			{
				if (list[i] == substr)
				{
					return true;
				}
			}
			return false;
		}
	}
}