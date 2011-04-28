/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css 
{
	public dynamic class CSSPropertiesChangeList 
	{
		//----------------------             Public Properties              ----------------------//
		public var length : int = 0;
		
		//----------------------               Public Methods               ----------------------//
		public function addChange(property : String) : void
		{
			if (!this[property])
			{
				this[property] = true;
				length++;
			}
		}
	}
}
