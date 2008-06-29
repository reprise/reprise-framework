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
	import flash.events.Event;
	import flash.text.TextFormat;
	
	public class TextInput extends Label
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const className : String = "TextInput";
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_enabled : Boolean;
		protected var m_labelStr : String;
		protected var m_verticalScrollingOn : Boolean;
		protected var m_horizontalScrollingOn : Boolean;
		
		protected var m_hasFocus : Boolean;
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function TextInput ()
		{
			
		}
		
		/**
		 * disables the TextInput, making it non-editable
		 */
		public override function set enabled(value:Boolean) : void
		{
			m_enabled = value;
			if (!value)
			{
				addPseudoClass("disabled");
				m_labelDisplay.type = "dynamic";
			}
			else
			{
				removePseudoClass("disabled");
				m_labelDisplay.type = "input";
			}
			invalidate();
		}
		public override function get enabled () : Boolean
		{
			return m_enabled;
		}
		
		/**
		 * sets the input focus to this TextInputs' Label field
		 */
		public function setFocus() : void
		{
//			Selection.setFocus(m_labelDisplay);
		}
		
		public override function setLabel(label:String) : void
		{
			m_labelStr = label;
			m_labelDisplay.text = label;
		}
		
		public override function getLabel() : String
		{
			return m_labelStr;
		}
		
		public function getValue() : Object
		{
			return getLabel();
		}
		
		
		/***************************************************************************
		*							protected methods					
		***************************************************************************/
		protected override function initialize() : void
		{
			super.initialize();
			enabled = true;
//			m_labelDisplay.onSetFocus = label_focusIn;
//			m_labelDisplay.onKillFocus = label_focusOut;
			m_labelDisplay.addEventListener(Event.CHANGE, label_change);
		}
	
		protected override function initDefaultStyles() : void
		{
			super.initDefaultStyles();
			m_elementDefaultStyles.setStyle('multiline', 'false');
			m_elementDefaultStyles.setStyle('display', 'block');
			m_elementDefaultStyles.setStyle('wordWrap', 'false');
			m_elementDefaultStyles.setStyle('height', '18px');
			m_elementDefaultStyles.setStyle('padding', '2px');
		}
		protected override function applyStyles() : void
		{
			super.applyStyles();
			m_labelDisplay.restrict = m_currentStyles.inputCharRestrict;
			m_labelDisplay.maxChars = m_currentStyles.inputLengthRestrict;
		}
		
		protected override function renderLabel() : void
		{
			m_labelXML = <p>[[!]]</p>;
			super.renderLabel();
			var format:TextFormat = m_labelDisplay.getTextFormat();
			m_labelDisplay.styleSheet = null;
			m_labelDisplay.defaultTextFormat = format;
			m_labelDisplay.text = m_labelStr || '';
			m_labelDisplay.width = calculateContentWidth();
			m_labelDisplay.height = calculateContentHeight();
		}
		
		protected function label_change(event : Event) : void
		{
			m_labelStr = m_labelDisplay.text;
			dispatchEvent(new Event(Event.CHANGE));
			applyOverflowProperty();
		}
		
		protected override function applyOverflowProperty() : void
		{
			if ((m_labelDisplay.maxScrollV > 1) != m_verticalScrollingOn || 
				(m_labelDisplay.maxScrollH > 0) != m_horizontalScrollingOn)
			{
				m_overflowIsInvalid = true;
				super.applyOverflowProperty();
				m_verticalScrollingOn = m_labelDisplay.maxScrollV > 1;
				m_horizontalScrollingOn = m_labelDisplay.maxScrollH > 0;
			}
		}
		
		protected override function draw() : void
		{
			super.draw();
			if (!isNaN(m_tabIndex))
			{
				m_labelDisplay.tabIndex = m_tabIndex;
			}
		}
		protected function label_focusIn() : void
		{
			m_hasFocus = true;
			removeErrorMark();
//			dispatchEvent(new FocusEvent(FocusEvent.FOCUS_IN, true, false, this));
		}
		protected function label_focusOut() : void
		{
			m_hasFocus = false;
//			dispatchEvent(new FocusEvent(FocusEvent.FOCUS_OUT, true, false, this));
		}
	}
}