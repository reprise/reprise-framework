/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css.propertyparsers
{
	import reprise.core.reprise;
	import reprise.css.CSS;
	import reprise.css.CSSPropertyParser;	
	
	use namespace reprise;
	
	public dynamic class RuntimeParser extends CSSPropertyParser
	{
		
		public static var KNOWN_PROPERTIES : Object = [];
		
		
		//----------------------               Public Methods               ----------------------//
		public static function registerProperty(
			name : String, type : uint, inheritable : Boolean, 
			transition : Class = null, parserMethod : Function = null) : void
		{
			if (parserMethod == null)
			{
				switch (type)
				{
					case CSS.PROPERTY_TYPE_STRING:
					{
						parserMethod = strToStringProperty;
						break;
					}
					case CSS.PROPERTY_TYPE_INT:
					{
						parserMethod = strToIntProperty;
						break;
					}
					case CSS.PROPERTY_TYPE_FLOAT:
					{
						parserMethod = strToFloatProperty;
						break;
					}
					case CSS.PROPERTY_TYPE_BOOL:
					{
						parserMethod = strToBoolProperty;
						break;
					}
					case CSS.PROPERTY_TYPE_URL:
					{
						parserMethod = strToURLProperty;
						break;
					}
					case CSS.PROPERTY_TYPE_COLOR:
					{
						parserMethod = strToColorProperty;
						break;
					}
					default:
					{
						log('e Error registering property with name "' + name + 
							'". Unknown type ' + type);
						return;
					}
				}
			}
			
			var obj : Object = {parser : parserMethod};
			if (inheritable)
			{
				obj['inheritable'] = true;
			}
			KNOWN_PROPERTIES[name] = obj;
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		public function RuntimeParser()
		{
		}
	}
}