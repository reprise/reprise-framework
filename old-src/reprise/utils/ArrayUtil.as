/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.utils
{
	 /**
	 * Array related utility functions
	 *
	 * @author	Florian Finke
	 * @version	$Revision$ | $Id$
	 */
	public final class ArrayUtil
	{
	
		/**
		 * Constructor. Private to prevent instantiation from outside
		 */
		public function ArrayUtil() 
		{
		}
	
	
		/**
		 * @param	arr	The Array to search in.
		 * @param	obj	The object to search for.
		 *
		 * @return	Boolean	True if the object exists inside the array.
		 */
		public static function inArray( arr : Array, obj : Object ) : Boolean
		{
			return arr.indexOf(obj) > -1;
		}
		
		/**
		 * Shuffles the array in place
		 * 
		 * @see http://en.wikipedia.org/wiki/Fisher-Yates_shuffle
		 */
		public static function shuffle(arr:Array) : void
		{
			var i : int = arr.length;
			while (i > 1)
	        {
	        	var swapIndex : int = Math.random() * i--;
	            var temp : Object = arr[i];
	            arr[i] = arr[swapIndex];
	            arr[swapIndex] = temp;
	        }
		}
		
		public static function compareArrays(
			array1 : Array, array2 : Array, exactComparison : Boolean = false) : Boolean
		{
			if (array1 == array2)
			{
				return true;
			}
			if (array1.length != array2.length)
			{
				return false;
			}
			var i : int = array1.length;
			if (exactComparison)
			{
				while(i--)
				{
					if (array1[i] !== array2[i])
					{
						return false;
					}
				}
			}
			else
			{
				while(i--)
				{
					if (array1[i] != array2[i])
					{
						return false;
					}
				}
			}
			
			return true;
		}
	}
}