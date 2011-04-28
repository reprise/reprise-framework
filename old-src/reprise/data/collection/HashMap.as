/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.data.collection
{ 
	public class HashMap
	{
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _map : Array;
		protected var _size : int;
		
		
			
		//----------------------               Public Methods               ----------------------//
		public function HashMap()
		{
			clear();
		}
			
		public function clear() : void
		{
			_map = [];
			_size = 0;
		}
		
		public function containsKey(key : String) : Boolean
		{
			return _map[key] != undefined;
		}
		
		public function containsObject(value : Object) : Boolean
		{
			for (var key : String in _map)
			{
				if (_map[key] == value)
				{
					return true;
				}
			}
			return false;
		}
		
		public function objectForKey(key : String) : Object
		{
			var obj : Object = _map[key];
			return obj;
		}
		
		public function setObjectForKey(value : Object, key : String) : void
		{
			if (!containsKey(key))
			{
				_size++;
			}
			_map[key] = value;
		}
		
		public function removeObjectForKey(key : String) : void
		{
			if (!containsKey(key))
			{
				return;
			}
			delete _map[key];
			_size--;
		}
		
		public function removeObject(value : Object) : void
		{
			for (var key : String in _map)
			{
				if (_map[key] == value)
				{
					delete _map[key];
					_size--;
				}
			}
		}
		
		public function size() : int
		{
			return _size;
		}
		
		public function keys() : Array
		{
			var keysArray : Array = [];
			for (var key : String in _map)
			{
				keysArray.push(key);
			}
			return keysArray;
		}
		
		public function values() : Array
		{
			var valuesArray : Array = [];
			for (var key : String in _map)
			{
				valuesArray.push(_map[key]);
			}
			return valuesArray;
		}
		
		public function toObject() : Object
		{
			return _map;
		}
	}
}