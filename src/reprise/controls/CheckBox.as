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

package reprise.controls
{
	/**
	 * @author marco
	 */
	public class CheckBox extends LabelButton
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
	
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CheckBox() {}
		
		
		public function get checked() : Boolean
		{
			return selected;
		}
		
		public function getLabelDisplay() : Label
		{
			return m_labelDisplay;
		}
		
		public function setAttributeChecked(value : String) : void
		{
			selected = (value == '1' || value == 'true');
		}



		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function initialize() : void
		{
			super.initialize();
			m_isToggleButton = true;
		}
		protected override function createChildren() : void
		{
			super.createChildren();
			m_labelDisplay.html = true;
		}
	}
}