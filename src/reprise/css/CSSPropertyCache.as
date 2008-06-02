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

package reprise.css { 
	/**
	 * @author Till Schneidereit
	 */
	public class CSSPropertyCache 
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_propertyCache : Object = {};
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public static function propertyForKeyValue(
			key:String, value:String, file : String) : Object
		{
			var prop:Object = g_propertyCache[value + file];
			if (!prop)
			{
				var parser : Function = CSSDeclaration.parserForProperty(key);
				prop = parser(value, file);
				g_propertyCache[value + file] = prop;
			}
			return prop;
		}
		public static function setPropertyForKeyValue(
			key:String, value:String, file : String, property:Object) : void
		{
			g_propertyCache[value + file] = property;
		}
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		public function CSSPropertyCache()
		{
			
		}
		
	}
}