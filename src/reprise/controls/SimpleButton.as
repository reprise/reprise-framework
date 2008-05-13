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

package reprise.controls { 
	/**
	 * @author Till Schneidereit
	 */
	import flash.display.MovieClip;
	import flash.events.Event;
	public class SimpleButton extends AbstractButton
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var className : String = "SimpleButton";
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function SimpleButton ()
		{
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function createButtonDisplay() : void
		{
			m_buttonDisplay = this;
		}
	}
}