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

package reprise.data
{ 
	/**
	 * @author Till Schneidereit
	 * 
	 * simple value object consisting of a label, an id and general data field
	 */
	public class ItemData 
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public var label : String;
		public var data : Object;
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function ItemData(label:String = null, data:Object = null)
		{
			this.label = label;
			this.data = data;
		}
		
		public function toString() : String
		{
			return "ItemData: label=" + label + ", data=" + data;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		
	}
}