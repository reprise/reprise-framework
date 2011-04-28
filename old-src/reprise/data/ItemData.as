/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.data
{ 
	/**
	 * @author Till Schneidereit
	 * 
	 * simple value object consisting of a label, an id and general data field
	 */
	public class ItemData 
	{
		//----------------------             Public Properties              ----------------------//
		public var label : String;
		public var data : Object;
		//----------------------       Private / Protected Properties       ----------------------//
		
		
		//----------------------               Public Methods               ----------------------//
		public function ItemData(label:String = null, data:Object = null)
		{
			this.label = label;
			this.data = data;
		}
		
		public function toString() : String
		{
			return "ItemData: label=" + label + ", data=" + data;
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		
	}
}