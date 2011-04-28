/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css
{
	import reprise.core.reprise;
	
	use namespace reprise;
	
	public class CSSPropertyCache 
	{
		//----------------------             Public Properties              ----------------------//
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected static var g_propertyCache : Object = {};
		
		
		//----------------------               Public Methods               ----------------------//
		reprise static function propertyForKeyValue(
			key:String, value:String, file : String, weak : Boolean = false) : Object
		{
			var prop:Object = g_propertyCache[key+"="+value+file + weak];
			if (!prop)
			{
				var parser : Function = CSSDeclaration.parserForProperty(key);
				prop = parser(value, file);
				if (weak)
				{
					if (prop is CSSProperty)
					{
						CSSProperty(prop).setIsWeak(true);
					}
					else if (prop is CSSParsingResult)
					{
						var props : Object = prop.properties();
						for (key in props)
						{
							CSSProperty(props[key]).setIsWeak(true);
						}
					}
				}
				g_propertyCache[key+"="+value+file+weak] = prop;
			}
			return prop;
		}
		
		//----------------------         Private / Protected Methods        ----------------------//
		public function CSSPropertyCache()
		{
			
		}
		
	}
}