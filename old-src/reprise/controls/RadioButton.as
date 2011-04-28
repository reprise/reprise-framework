//
//  RadioButton.as
//
//  Created by Marc Bauer on 2008-06-19.
//  Copyright (c) 2008 Fork Unstable Media GmbH. All rights reserved.
//

package reprise.controls
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;

	
	public class RadioButton extends LabelButton
	{
		//----------------------             Public Properties              ----------------------//
		
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _groupName:String;
	
		
		
		//----------------------               Public Methods               ----------------------//
		public function RadioButton() {}
		
		/**
		 * This override does nothing, preventing the RadioButton from being turned into 
		 * a toggle button.
		 * 
		 * While RadioButtons do have some characteristics of toggle buttons, they can't 
		 * be switched on and off by pressing them repeatedly. Thus, treating them as 
		 * toggle buttons doesn't make sense and complicates internal handling.
		 */
		public override function set isToggleButton(value:Boolean):void
		{
		}
		
		public override function set selected(value:Boolean):void
		{
			group().setRadioButtonSelected(this, value);
		}
		
		public override function get selected():Boolean
		{
			return _selected;
		}
		
		public function setGroupName(name:String):void
		{
			if (name == _groupName)
			{
				return;
			}
			if (_groupName)
			{
				group().removeRadioButton(this);
			}
			_groupName = name;
			group().addRadioButton(this);
		}
		
		public function groupName():String
		{
			return _groupName;
		}
		
		public function group():RadioButtonGroup
		{
			return RadioButtonGroup.groupWithName(_groupName);
		}
		
		public function setChecked(value : String) : void
		{
			selected = value == 'checked';
		}
		
		public override function setName(value : String) : void
		{
			super.setName(value);
			setGroupName(value);
		}
		
		public override function value():*
		{
			return group().selectedData();
		}
		
		public override function setValue(value:*):void
		{
			group().selectRadioButtonWithData(value);
		}

		
		
		internal function setSelected(value:Boolean):void
		{
			value ? activate() : deactivate();
		}

		public override function remove(...args) : void
		{
			group().removeRadioButton(this);
			super.remove(args);
		}

		//----------------------         Private / Protected Methods        ----------------------//
		protected override function initialize () : void
		{
			super.initialize();
			_isToggleButton = false;
		}
		
		protected override function handleKeyEvent(event : KeyboardEvent) : Boolean
		{
			switch(event.keyCode)
			{
				case Keyboard.SPACE:
				{
					dispatchEvent(new MouseEvent(MouseEvent.CLICK));
					return true;
				}
				case Keyboard.LEFT:
				{
					group().activatePreviousButton(this);
					return true;
				}
				case Keyboard.RIGHT:
				{
					group().activateNextButton(this);
					return true;
				}
				default:
				{
					return false;
				}
			}
		}
		
		protected override function buttonDisplay_click(event:MouseEvent):void
		{
			if (!_enabled)
			{
				return;
			}
			super.buttonDisplay_click(event);
			selected = true;
		}
	}
}