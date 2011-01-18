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
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_map : Array;
		protected var m_size : int;
		
		
			
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function HashMap()
		{
			clear();
		}
			
		public function clear() : void
		{
			m_map = [];
			m_size = 0;
		}
		
		public function containsKey(key : String) : Boolean
		{
			return m_map[key] != undefined;
		}
		
		public function containsObject(value : Object) : Boolean
		{
			for (var key : String in m_map)
			{
				if (m_map[key] == value)
				{
					return true;
				}
			}
			return false;
		}
		
		public function objectForKey(key : String) : Object
		{
			var obj : Object = m_map[key];
			return obj;
		}
		
		public function setObjectForKey(value : Object, key : String) : void
		{
			if (!containsKey(key))
			{
				m_size++;
			}
			m_map[key] = value;
		}
		
		public function removeObjectForKey(key : String) : void
		{
			if (!containsKey(key))
			{
				return;
			}
			delete m_map[key];
			m_size--;
		}
		
		public function removeObject(value : Object) : void
		{
			for (var key : String in m_map)
			{
				if (m_map[key] == value)
				{
					delete m_map[key];
					m_size--;
				}
			}
		}
		
		public function size() : int
		{
			return m_size;
		}
		
		public function keys() : Array
		{
			var keysArray : Array = [];
			for (var key : String in m_map)
			{
				keysArray.push(key);
			}
			return keysArray;
		}
		
		public function values() : Array
		{
			var valuesArray : Array = [];
			for (var key : String in m_map)
			{
				valuesArray.push(m_map[key]);
			}
			return valuesArray;
		}
		
		public function toObject() : Object
		{
			return m_map;
		}
	}
}