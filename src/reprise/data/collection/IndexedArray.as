/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.data.collection
{
	
	
	public dynamic class IndexedArray extends Array
	{
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function IndexedArray()
		{
			AS3::splice.apply(this, ([0, 0]).concat(arguments));
		}
			
		public function init() : void
		{
			AS3::splice(0, this.length);
		}
		
		public function addObjectsFromArray(arr:Array):void
		{
			for (var i:int = 0; i < arr.length; i++)
			{
				push(arr[i]);
			}
		}
		
		public function getIndex(o : Object) : int
		{
			return indexOf(o);
		}
		
		public function objectExists(o : Object) : Boolean
		{
			return indexOf(o) != -1;
		}	
		
		public function remove(o : Object) : Boolean
		{
			var i : int = indexOf(o);
			if (i == -1)
			{
				return false;
			}
			removeObjectAtIndex(i);
			return true;
		}
		
		public function removeObjectAtIndex(index : int) : Boolean
		{
			if (index < 0 || index > length - 1)
			{
				return false;
			}
			AS3::splice(index, 1);
			return true;			
		}
		
		public function insertObjectAtIndex(o:Object, index:int) : void
		{
			AS3::splice(index, 0, o);
		}
		
		public function replaceObjectWithObject(objectToReplace:Object, objectToUse:Object) : Boolean
		{
			var index:int = indexOf(objectToReplace);
			if (index == -1)
			{
				return false;
			}
			this[index] = objectToUse;
			return true;
		}
		
		public function isEmpty() : Boolean
		{
			return this.length < 1;
		}
	}
}