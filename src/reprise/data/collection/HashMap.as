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
	public class HashMap
	{
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_map : Array;
		protected var m_size : Number;
		
		
			
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
			var key : String;
			for (key in m_map)
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
				return;
			delete m_map[key];
			m_size--;
		}
		
		public function removeObject(value : Object) : void
		{
			var key : String;
			for (key in m_map)
			{
				if (m_map[key] == value)
				{
					delete m_map[key];
					m_size--;
				}
			}
		}
		
		public function size() : Number
		{
			return m_size;
		}
		
		public function keys() : Array
		{
			var keysArray : Array = [];
			var key : String;
			for (key in m_map)
			{
				keysArray.push(key);
			}
			return keysArray;
		}
		
		public function values() : Array
		{
			var valuesArray : Array = [];
			var key : String;
			for (key in m_map)
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