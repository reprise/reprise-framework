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
		
		public function getIndex(o : Object) : Number
		{
			var i : Number = this.length;
			while (i--)
				if (this[i] == o)
					return i;
			return -1;
		}
		
		public function objectExists(o : Object) : Boolean
		{
			return getIndex(o) != -1;
		}	
		
		public function remove(o : Object) : Boolean
		{
			var i : Number = getIndex(o);
			if (i == -1)
			{
				return false;
			}
			removeObjectAtIndex(i);
			return true;
		}
		
		public function removeObjectAtIndex(index : Number) : Boolean
		{
			if (index < 0 || index > length - 1)
			{
				return false;
			}
			AS3::splice(index, 1);
			return true;			
		}
		
		public function insertObjectAtIndex(o:Object, index:Number) : void
		{
			AS3::splice(index, 0, o);
		}
		
		public function replaceObjectWithObject(objectToReplace:Object, objectToUse:Object) : Boolean
		{
			var index:Number = getIndex(objectToReplace);
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