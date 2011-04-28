//
//  RadioButtonGroup.as
//
//  Created by Marc Bauer on 2008-06-19.
//  Copyright (c) 2008 Fork Unstable Media GmbH. All rights reserved.
//

package reprise.controls
{
	import reprise.controls.RadioButton;
	import reprise.core.FocusManager;
	import reprise.core.reprise;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	use namespace reprise;
	
	public class RadioButtonGroup extends EventDispatcher
	{
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected static var g_radioGroups:Object;
		protected var _radioButtons:Array;
		protected var _name:String;
		protected var _selectedIndex:int = -1;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public function RadioButtonGroup(name:String)
		{
			_name = name;
			_radioButtons = [];
		}
		
		
		public static function groupWithName(name:String):RadioButtonGroup
		{
			if (!g_radioGroups)
			{
				g_radioGroups = {};
			}
			if (!g_radioGroups[name])
			{
				g_radioGroups[name] = new RadioButtonGroup(name);	
			}
			return g_radioGroups[name];
		}
		
		public function addRadioButton(btn:RadioButton):void
		{
			_radioButtons.push(btn);
		}
		
		public function removeRadioButton(btn:RadioButton):void
		{
			_radioButtons.splice(_radioButtons.indexOf(btn), 1);
		}
		
		public function reset():void
		{
			for (var i:int = 0; i < _radioButtons.length; i++)
			{
				var rbtn:RadioButton = _radioButtons[i] as RadioButton;
				rbtn.setSelected(false);
			}
			_selectedIndex = -1;
		}
		
		public function setRadioButtonSelected(btn:RadioButton, bFlag:Boolean):void
		{
			var oldIndex : int = _selectedIndex;
			if (!bFlag)
			{
				btn.setSelected(false);
				return;
			}
			var i:uint = 0;
			for (; i < _radioButtons.length; i++)
			{
				var rbtn:RadioButton = _radioButtons[i] as RadioButton;
				rbtn.setSelected(rbtn == btn);
				if (rbtn == btn)
				{
					_selectedIndex = i;
				}
			}
			if (_selectedIndex != oldIndex)
			{
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		public function selectRadioButtonWithData(data:*):void
		{
			var i:int = _radioButtons.length;
			while (i--)
			{
				var btn:RadioButton = _radioButtons[i] as RadioButton;
				if (btn.data() == data)
				{
					setRadioButtonSelected(btn, true);
					return;
				}
			}
		}
		
		public function selectedRadioButton():RadioButton
		{
			return _radioButtons[_selectedIndex];
		}
		
		public function selectedData():*
		{
			if (_selectedIndex == -1)
			{
				return null;
			}
			return (_radioButtons[_selectedIndex] as RadioButton).data();
		}
		
		public function radioButtons() : Array
		{
			return _radioButtons;
		}
		
		public function name() : String
		{
			return _name;
		}

		public function selectNextButton(currentButton : RadioButton) : void
		{
			var currentIndex : int = _radioButtons.indexOf(currentButton);
			if (currentIndex < _radioButtons.length - 1)
			{
				var nextButton : RadioButton = _radioButtons[currentIndex + 1];
				setRadioButtonSelected(nextButton, true);
			}
		}
		
		public function selectPreviousButton(currentButton : RadioButton) : void
		{
			var currentIndex : int = _radioButtons.indexOf(currentButton);
			if (currentIndex > 0)
			{
				var nextButton : RadioButton = _radioButtons[currentIndex - 1];
				setRadioButtonSelected(nextButton, true);
			}
		}
		
		public function activateNextButton(currentButton : RadioButton) : void
		{
			var currentIndex : int = _radioButtons.indexOf(currentButton);
			if (currentIndex < _radioButtons.length - 1)
			{
				currentButton.document.setFocusedElement(
					RadioButton(_radioButtons[currentIndex + 1]),
					FocusManager.FOCUS_METHOD_KEYBOARD);
			}
		}
		public function activatePreviousButton(currentButton : RadioButton) : void
		{
			var currentIndex : int = _radioButtons.indexOf(currentButton);
			if (currentIndex > 0)
			{
				currentButton.document.setFocusedElement(RadioButton(_radioButtons[0]),
					FocusManager.FOCUS_METHOD_KEYBOARD);
			}
		}
	}
}