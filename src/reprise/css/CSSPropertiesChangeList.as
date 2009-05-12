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
	public dynamic class CSSPropertiesChangeList 
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public var length : int = 0;
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
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
