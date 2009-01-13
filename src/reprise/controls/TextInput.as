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
	import reprise.core.reprise;
	import reprise.css.CSSDeclaration;
	import reprise.ui.DocumentView;
	import reprise.utils.StringUtil;
	
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.TextFormat;		
	
	use namespace reprise;
	
	public class TextInput extends Label
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const className : String = "TextInput";
		
		
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		protected var m_enabled : Boolean;
		protected var m_labelStr : String;
		protected var m_verticalScrollingOn : Boolean;
		protected var m_horizontalScrollingOn : Boolean;
		
		protected var m_placeholder : String;
		
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
			if (value == m_enabled)
			{
				return;
			}
			m_enabled = value;
			if (!value)
			{
				addCSSPseudoClass("disabled");
				m_labelDisplay.type = "dynamic";
			}
			else
			{
				removeCSSPseudoClass("disabled");
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
		public override function setFocus(value : Boolean, method : String):void
		{
			super.setFocus(value, method);
			if (value)
			{
				stage.focus = m_labelDisplay;
				if (getLabel() == m_placeholder)
				{
					removeCSSClass('placeholder');
					setLabel('');
				}
				if (method == DocumentView.FOCUS_METHOD_KEYBOARD)
				{
					m_labelDisplay.setSelection(0, m_labelDisplay.length);
				}
				else if (m_labelDisplay.length)
				{
					var clickedChar : int = m_labelDisplay.getCharIndexAtPoint(
						m_labelDisplay.mouseX, m_labelDisplay.mouseY);
					if (clickedChar == -1)
					{
						clickedChar = m_labelDisplay.length;
					}
					m_labelDisplay.setSelection(clickedChar, clickedChar);
				}
			}
			else
			{
				if (m_placeholder && !m_labelDisplay.length)
				{
					setLabel(m_placeholder);
				}
				if (m_labelStr == m_placeholder)
				{
					addCSSClass('placeholder');
				}
			}
		}
		
		public override function setLabel(label:String) : void
		{
			if (label == null && m_placeholder)
			{
				label = m_placeholder;
			}
			if (label == m_placeholder)
			{
				addCSSClass('placeholder');
			}
			else
			{
				removeCSSClass('placeholder');
			}
			m_labelStr = label;
			m_labelDisplay.text = label;
			invalidate();
		}
		
		public override function getLabel() : String
		{
			return m_labelStr;
		}
		
		public function getValue() : Object
		{
			return getLabel();
		}
		public override function setValue(value : *) : void
		{
			setLabel(value);
		}
		
		/**
		 * @private
		 */
		public function setPlaceholderAttribute(value : String):void
		{
			m_placeholder = value;
			if (!m_labelStr)
			{
				setLabel(value);
			}
		}
		public override function didSucceed():Boolean
		{
			if (m_validator || !m_required || !m_placeholder)
			{
				return super.didSucceed();
			}
			
			var success:Boolean = value() != m_placeholder;
			success ? markAsValid() : markAsInvalid();
			return success;
		}
		
		
		/***************************************************************************
		*							protected methods					
		***************************************************************************/
		protected override function initialize() : void
		{
			super.initialize();
			m_canBecomeKeyView = true;
			m_enabled = true;
		}
		
		protected override function createChildren() : void
		{
			super.createChildren();
			m_labelDisplay.type = "input";
			m_labelDisplay.mouseEnabled = true;
			m_labelDisplay.addEventListener(Event.CHANGE, label_change);
		}

		/**
		 * Just pass the content on to the labelDisplay
		 */
		protected override function parseXMLContent(node : XML) : void
		{
			m_xmlDefinition = node;
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
			if (m_currentStyles.inputCharRestrict && 
				m_currentStyles.inputCharRestrict != 'none')
			{
				m_labelDisplay.restrict = m_currentStyles.inputCharRestrict;
			}
			else
			{
				m_labelDisplay.restrict = null;
			}
			m_labelDisplay.maxChars = m_currentStyles.inputLengthRestrict || 0;
			if (m_currentStyles.textTransform && m_currentStyles.textTransform != 'none')
			{
				m_labelDisplay.addEventListener(TextEvent.TEXT_INPUT, label_textInput);
			}
			else
			{
				m_labelDisplay.removeEventListener(TextEvent.TEXT_INPUT, label_textInput);
			}
		}

		protected override function renderLabel() : void
		{
			var selectionStart : int = m_labelDisplay.selectionBeginIndex;
			var selectionEnd : int = m_labelDisplay.selectionEndIndex;
			m_labelXML = <p>[[!]]</p>;
			m_labelDisplay.styleSheet = CSSDeclaration.TEXT_STYLESHEET;
			super.renderLabel();
			var format:TextFormat = m_labelDisplay.getTextFormat();
			m_labelDisplay.styleSheet = null;
			m_labelDisplay.defaultTextFormat = format;
			m_labelDisplay.text = m_labelStr || '';
			m_labelDisplay.setSelection(selectionStart, selectionEnd);
			m_labelDisplay.width = calculateContentWidth() + 4;
			m_labelDisplay.height = calculateContentHeight() + 4;
		}
		
		protected function label_change(event : Event) : void
		{
			m_labelStr = m_labelDisplay.text;
			event.stopImmediatePropagation();
			event.stopPropagation();
			dispatchEvent(new Event(Event.CHANGE));
			applyOverflowProperty();
		}
		
		protected function label_textInput(event : TextEvent) : void
		{
			event.preventDefault();
			var text : String = event.text;
			if (m_labelDisplay.maxChars)
			{
				text = event.text.substr(
					0, m_labelDisplay.maxChars - m_labelDisplay.length + 
					m_labelDisplay.selectionEndIndex - m_labelDisplay.selectionBeginIndex);
				if (!text)
				{
					return;
				}
			}
			if (m_currentStyles.textTransform == 'uppercase')
			{
				text = text.toUpperCase();
			}
			else if (m_currentStyles.textTransform == 'lowercase')
			{
				text = text.toLowerCase();
			}
			m_labelDisplay.replaceSelectedText(text);
			if (m_currentStyles.textTransform == 'capitalize')
			{
				var selStart : int = m_labelDisplay.selectionBeginIndex;
				var selEnd : int = m_labelDisplay.selectionEndIndex;
				m_labelDisplay.text = StringUtil.toTitleCase(m_labelDisplay.text);
				m_labelDisplay.setSelection(selStart, selEnd);
			}
			m_labelDisplay.dispatchEvent(new Event(Event.CHANGE, true));
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
	}
}