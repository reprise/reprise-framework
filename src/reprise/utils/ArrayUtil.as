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
	 /**
	 * Array related utility functions
	 *
	 * @author	Florian Finke
	 * @version	$Revision$ | $Id$
	 */
	public class ArrayUtil
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
			return arrayIndex(arr, obj) > -1;
		}
	
	
	
		/**
		 * @param	arr	The Array to search in.
		 * @param	obj	The object to search for.
		 *
		 * @return	Number	The array index of the object 
		 * 			or -1 if the obj doesn't exist in the array.
		 */
		public static function arrayIndex( arr : Array, obj : Object ) : int
		{
			if (arr.length)
			{
				for (var i:Number = arr.length; i--;)
				{
					if (arr[i] == obj)
					{
						return i;
					}
				}
			}
			return -1;
		}
		
		
		public static function shuffle(arr:Array) : Array
		{
			// aye, uglyness!
			return arr.sort(
				function(a:Object, b:Object) : int
				{
					return (Math.random() < .5) ? -1 : 1;
				}, 
				Array.NUMERIC);
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
			var i : Number = array1.length;
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