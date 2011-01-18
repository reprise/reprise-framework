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
		
		/***************************************************************************
		*                           protected properties                           *
		***************************************************************************/
		protected static var g_radioGroups:Object;
		protected var m_radioButtons:Array;
		protected var m_name:String;
		protected var m_selectedIndex:int = -1;
		
		
		
		/***************************************************************************
		*                              Public methods                              *
		***************************************************************************/
		public function RadioButtonGroup(name:String)
		{
			m_name = name;
			m_radioButtons = [];
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
			m_radioButtons.push(btn);
		}
		
		public function removeRadioButton(btn:RadioButton):void
		{
			m_radioButtons.splice(m_radioButtons.indexOf(btn), 1);
		}
		
		public function reset():void
		{
			for (var i:int = 0; i < m_radioButtons.length; i++)
			{
				var rbtn:RadioButton = m_radioButtons[i] as RadioButton;
				rbtn.setSelected(false);
			}
			m_selectedIndex = -1;
		}
		
		public function setRadioButtonSelected(btn:RadioButton, bFlag:Boolean):void
		{
			var oldIndex : int = m_selectedIndex;
			if (!bFlag)
			{
				btn.setSelected(false);
				return;
			}
			var i:uint = 0;
			for (; i < m_radioButtons.length; i++)
			{
				var rbtn:RadioButton = m_radioButtons[i] as RadioButton;
				rbtn.setSelected(rbtn == btn);
				if (rbtn == btn)
				{
					m_selectedIndex = i;
				}
			}
			if (m_selectedIndex != oldIndex)
			{
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		public function selectRadioButtonWithData(data:*):void
		{
			var i:int = m_radioButtons.length;
			while (i--)
			{
				var btn:RadioButton = m_radioButtons[i] as RadioButton;
				if (btn.data() == data)
				{
					setRadioButtonSelected(btn, true);
					return;
				}
			}
		}
		
		public function selectedRadioButton():RadioButton
		{
			return m_radioButtons[m_selectedIndex];
		}
		
		public function selectedData():*
		{
			if (m_selectedIndex == -1)
			{
				return null;
			}
			return (m_radioButtons[m_selectedIndex] as RadioButton).data();
		}
		
		public function radioButtons() : Array
		{
			return m_radioButtons;
		}
		
		public function name() : String
		{
			return m_name;
		}

		public function selectNextButton(currentButton : RadioButton) : void
		{
			var currentIndex : int = m_radioButtons.indexOf(currentButton);
			if (currentIndex < m_radioButtons.length - 1)
			{
				var nextButton : RadioButton = m_radioButtons[currentIndex + 1];
				setRadioButtonSelected(nextButton, true);
			}
		}
		
		public function selectPreviousButton(currentButton : RadioButton) : void
		{
			var currentIndex : int = m_radioButtons.indexOf(currentButton);
			if (currentIndex > 0)
			{
				var nextButton : RadioButton = m_radioButtons[currentIndex - 1];
				setRadioButtonSelected(nextButton, true);
			}
		}
		
		public function activateNextButton(currentButton : RadioButton) : void
		{
			var currentIndex : int = m_radioButtons.indexOf(currentButton);
			if (currentIndex < m_radioButtons.length - 1)
			{
				currentButton.document.setFocusedElement(
					RadioButton(m_radioButtons[currentIndex + 1]), 
					FocusManager.FOCUS_METHOD_KEYBOARD);
			}
		}
		public function activatePreviousButton(currentButton : RadioButton) : void
		{
			var currentIndex : int = m_radioButtons.indexOf(currentButton);
			if (currentIndex > 0)
			{
				currentButton.document.setFocusedElement(RadioButton(m_radioButtons[0]), 
					FocusManager.FOCUS_METHOD_KEYBOARD);
			}
		}
	}
}