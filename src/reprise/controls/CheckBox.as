/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

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
		
		/**
		 * @private
		 */
		public function setCheckedAttribute(value : String) : void
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
		}
	}
}