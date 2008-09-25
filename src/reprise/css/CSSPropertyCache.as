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

package reprise.css
{
	import reprise.core.reprise;
	
	use namespace reprise;
	
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
		reprise static function propertyForKeyValue(
			key:String, value:String, file : String) : Object
		{
			var prop:Object = g_propertyCache[key+"="+value+file];
			if (!prop)
			{
				var parser : Function = CSSDeclaration.parserForProperty(key);
				prop = parser(value, file);
				setPropertyForKeyValue(key, value, file, prop);
			}
			return prop;
		}
		reprise static function setPropertyForKeyValue(
			key:String, value:String, file : String, property:Object) : void
		{
			g_propertyCache[key+"="+value+file] = property;
		}
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		public function CSSPropertyCache()
		{
			
		}
		
	}
}