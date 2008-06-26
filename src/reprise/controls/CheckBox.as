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
	import reprise.controls.Label;
	import reprise.controls.LabelButton;
	import reprise.data.validators.IDataValidator;
	import flash.events.MouseEvent;
	
	/**
	 * @author marco
	 */
	public class Checkbox extends LabelButton
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var className : String = "Checkbox";
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_required : Boolean;
		protected var m_validator : IDataValidator;
	
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function Checkbox()
		{
		}
		public function get checked() : Boolean
		{
			return selected;	
		}
		
		public function getLabelDisplay() : Label
		{
			return m_labelDisplay;
		}
		
			
		public function getValue() : Object
		{
			return {checked:selected};
		}
		
		public function isValid() : Boolean
		{
			if(m_required && !selected)
			{
				return false;
			}
			return true;
		}
		
		public function setRequired(required : Boolean) : void
		{
			m_required = required;
		}
	
		public function required() : Boolean
		{
			return m_required;
		}

		//@FIXME
		/*public function setValidator(validator : IDataValidator) : void
		{
			m_validator = validator;
		}*/
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function initialize() : void
		{
			super.initialize();
			isToggleButton = true;
			m_labelDisplay.html = true;
		}

		//@FIXME
		/*public function validator() : IDataValidator
		{
			return m_validator;	
		}*/
	}
}