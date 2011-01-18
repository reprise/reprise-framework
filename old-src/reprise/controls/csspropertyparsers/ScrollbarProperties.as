/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

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
			buttonPositioning : {parser : strToStringProperty},
			lineScrollSize : {parser : strToIntProperty},
			pageScrollSize : {parser : strToIntProperty}
		};
	}
}