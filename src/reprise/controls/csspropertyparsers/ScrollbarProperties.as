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

package reprise.controls.csspropertyparsers
{
	import reprise.css.CSSPropertyParser; 

	/**
	 * @author Till Schneidereit
	 */
	public class ScrollbarProperties extends CSSPropertyParser
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const KNOWN_PROPERTIES : Object = 
		{
			autoHide : {parser : strToBoolProperty},
			scaleScrollThumb : {parser : strToBoolProperty},
			lineScrollSize : {parser : strToIntProperty},
			pageScrollSize : {parser : strToIntProperty}
		};
	}
}