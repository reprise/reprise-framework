/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

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
		
		/**
		* transforms the first character of a each new word in a string to uppercase
		* 
		* Adapted from David Gouchs JS version, which itself is a port of John Grubers 
		* original Perl version:
		* http://individed.com/code/to-title-case/
		* http://daringfireball.net/2008/08/title_case_update
		* 
		* Copyright (c) 2008, John Gruber, Aristotle Pagaltzis, David Gouch, Till Schneidereit
		* 
		* Permission is hereby granted, free of charge, to any person obtaining a copy
		* of this software and associated documentation files (the "Software"), to deal
		* in the Software without restriction, including without limitation the rights
		* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		* copies of the Software, and to permit persons to whom the Software is
		* furnished to do so, subject to the following conditions:
		* 
		* The above copyright notice and this permission notice shall be included in
		* all copies or substantial portions of the Software.
		**/
		public static function toTitleCase(input : String) : String
		{
			var replacer : Function = function(
				match : String, p1 : int, index : int, title : String) : String
			{
				if (index > 0 && title.charAt(index - 2) != ":" && 
				match.search(/^(a(nd?|s|t)?|b(ut|y)|en|for|i[fn]|o[fnr]|t(he|o)|vs?\.?|via)[ -]/i) > -1)
				{
					return match.toLowerCase();
				}
				if (title.substring(index - 1, index + 1).search(/['"_{([]/) > -1)
				{
					return match.charAt(0) + 
						match.charAt(1).toUpperCase() + match.substr(2);
				}
				if (match.substr(1).search(/[A-Z]+|&|[\w]+[._][\w]+/) > -1 ||
					title.substring(index - 1, index + 1).search(/[\])}]/) > -1)
				{
					return match;
				}
				return match.charAt(0).toUpperCase() + match.substr(1);
			};
			return input.replace(/([\w&`'‘’"“.@:\/\{\(\[<>_]+-? *)/g, replacer);
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