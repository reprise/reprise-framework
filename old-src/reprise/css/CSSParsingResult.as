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
	
	public class CSSParsingResult
	{
		protected var _properties : Object;
		
		public function CSSParsingResult() 
		{
			_properties = {};
		}
		
		
		
		reprise function addPropertyForKey( prop : CSSProperty, key : String ) : void
		{
			_properties[ key ] = prop;
		}
		
		reprise function propertyForKey( key : String ) : CSSProperty
		{
			return CSSProperty( _properties[ key ] );
		}
		
		reprise function properties() : Object
		{
			return _properties;
		}
		
		reprise function addEntriesFromResult( res : CSSParsingResult ) : void
		{
			var props : Object = res.properties();
			for (var key : String in props)
			{
				addPropertyForKey(props[key], key);
			}
		}
		
		
		
		/**
		* pass instances of CSSProperty and String in an alternating order
		**/
		reprise static function ResultWithPropertiesAndKeys(... args) : CSSParsingResult
		{
			var res : CSSParsingResult = new CSSParsingResult();
			
			for (var i : int = 0; i < args.length; i += 2)
			{
				var prop : CSSProperty = args[ i ];
				var key : String = args[ i + 1 ];
				
				if ( !( prop is CSSProperty ) || 
						typeof( key ) != 'string' )
				{
					log( 'WARNING! Wrong type of parameters in ResultWithPropertiesAndKeys. Please make sure ' +
						' you\'re passing instances of CSSProperty and String in alternating order' );
					//com.nesium.utils.ObjUtils.dump( arguments );
					continue;
				}
				
				res.addPropertyForKey( prop, key );
			}
			
			return res;
		}
		
		
		public function toString() : String
		{
			var str : String = '';
			for (var key : String in _properties)
				str += key + ': ' + _properties[key] + '\n';
			return str;
		}
	}
}