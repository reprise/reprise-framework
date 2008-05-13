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

package reprise.css.propertyparsers
{
	import reprise.css.CSS;
	import reprise.css.CSSPropertyParser;
	import reprise.utils.ProxyFunction;
	import reprise.utils.StringUtil;
	
	
	public dynamic class RuntimeParser extends CSSPropertyParser
	{
		
		public static var KNOWN_PROPERTIES : Array = [];
		public static var INHERITABLE_PROPERTIES : Array = [];
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public static function registerProperty(
			name : String, type : uint, inheritable : Boolean) : void
		{
			var parserMethod : Function;
			
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
					trace('e Error registering property with name "' + name + 
						'". Unknown type ' + type);
					return;
				}
			}
			
			KNOWN_PROPERTIES.push(name);
			if (inheritable)
			{
				INHERITABLE_PROPERTIES.push(name);
			}
			var methodName : String = 'parse' + StringUtil.ucFirst(name);
			RuntimeParser[methodName] = parserMethod;
		}
		
		
		/***************************************************************************
		*							private methods								   *
		***************************************************************************/
		public function RuntimeParser()
		{
		}
	}
}