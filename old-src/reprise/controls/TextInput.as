/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.controls
{
	import reprise.core.FocusManager;
	import reprise.core.reprise;
	import reprise.css.CSSDeclaration;
	import reprise.utils.StringUtil;

	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.TextFormat;
	
	use namespace reprise;
	
	public class TextInput extends Label
	{
		//----------------------             Public Properties              ----------------------//
		public static const className : String = "TextInput";
		
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _enabled : Boolean;
		protected var _labelStr : String = '';
		protected var _verticalScrollingOn : Boolean;
		protected var _horizontalScrollingOn : Boolean;
		
		protected var _placeholder : String;
		
		//----------------------               Public Methods               ----------------------//
		public function TextInput ()
		{
			
		}
		
		/**
		 * disables the TextInput, making it non-editable
		 */
		public override function set enabled(value:Boolean) : void
		{
			if (value == _enabled)
			{
				return;
			}
			_enabled = value;
			if (!value)
			{
				addCSSPseudoClass("disabled");
				_labelDisplay.type = "dynamic";
			}
			else
			{
				removeCSSPseudoClass("disabled");
				_labelDisplay.type = "input";
			}
			invalidate();
		}
		public override function get enabled () : Boolean
		{
			return _enabled;
		}
		
		public function setDisplaysAsPassword(bFlag:Boolean):void
		{
			_labelDisplay.displayAsPassword = bFlag;
		}
		public function displaysAsPassword():Boolean
		{
			return _labelDisplay.displayAsPassword;
		}
		
		/**
		 * sets the input focus to this TextInputs' Label field
		 */
		public override function setFocus(value : Boolean, method : String):void
		{
			super.setFocus(value, method);
			if (value)
			{
				stage.focus = _labelDisplay;
				if (getLabel() == _placeholder)
				{
					removeCSSClass('placeholder');
					setLabel('');
				}
				if (method == FocusManager.FOCUS_METHOD_KEYBOARD)
				{
					_labelDisplay.setSelection(0, _labelDisplay.length);
				}
				else if (_labelDisplay.length)
				{
					var clickedChar : int = _labelDisplay.getCharIndexAtPoint(
						_labelDisplay.mouseX, _labelDisplay.mouseY);
					if (clickedChar == -1)
					{
						clickedChar = _labelDisplay.length;
					}
					_labelDisplay.setSelection(clickedChar, clickedChar);
				}
			}
			else
			{
				if (_placeholder && !_labelDisplay.length)
				{
					setLabel(_placeholder);
				}
				if (_labelStr == _placeholder)
				{
					addCSSClass('placeholder');
				}
			}
		}
		
		public override function setLabel(label:String) : void
		{
			if (label == null && _placeholder)
			{
				label = _placeholder;
			}
			if (label == _placeholder)
			{
				addCSSClass('placeholder');
			}
			else
			{
				removeCSSClass('placeholder');
			}
			_labelStr = label;
			_labelDisplay.text = label;
			invalidate();
		}
		
		public override function getLabel() : String
		{
			return _labelStr;
		}
		
		public function getValue() : Object
		{
			return getLabel() == _placeholder ? '' : getLabel();
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
			_placeholder = value;
			if (!_labelStr)
			{
				setLabel(value);
			}
		}
		public function getPlaceholderAttribute() : String
		{
			return _placeholder;
		}

		public override function didSucceed():Boolean
		{
			if (_validator || !_required || !_placeholder)
			{
				return super.didSucceed();
			}
			
			var success:Boolean = value() != _placeholder;
			success ? markAsValid() : markAsInvalid();
			return success;
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function initialize() : void
		{
			super.initialize();
			_canBecomeKeyView = true;
			_enabled = true;
		}
		
		protected override function createChildren() : void
		{
			super.createChildren();
			_labelDisplay.type = "input";
			_labelDisplay.mouseEnabled = true;
			_labelDisplay.addEventListener(Event.CHANGE, label_change);
		}

		/**
		 * Just pass the content on to the labelDisplay
		 */
		protected override function parseXMLContent(children : XMLList) : void
		{
		}
	
		protected override function initDefaultStyles() : void
		{
			super.initDefaultStyles();
			_elementDefaultStyles.setStyle('multiline', 'false');
			_elementDefaultStyles.setStyle('display', 'block');
			_elementDefaultStyles.setStyle('wordWrap', 'false');
			_elementDefaultStyles.setStyle('height', '18px');
			_elementDefaultStyles.setStyle('padding', '2px');
		}
		protected override function applyStyles() : void
		{
			super.applyStyles();
			if (_currentStyles.inputCharRestrict &&
				_currentStyles.inputCharRestrict != 'none')
			{
				_labelDisplay.restrict = _currentStyles.inputCharRestrict;
			}
			else
			{
				_labelDisplay.restrict = null;
			}
			_labelDisplay.maxChars = _currentStyles.inputLengthRestrict || 0;
			if (_currentStyles.textTransform && _currentStyles.textTransform != 'none')
			{
				_labelDisplay.addEventListener(TextEvent.TEXT_INPUT, label_textInput);
			}
			else
			{
				_labelDisplay.removeEventListener(TextEvent.TEXT_INPUT, label_textInput);
			}
		}

		protected override function renderLabel() : void
		{
			var selectionStart : int = _labelDisplay.selectionBeginIndex;
			var selectionEnd : int = _labelDisplay.selectionEndIndex;
			_labelXML = <p>[[!]]</p>;
			_labelDisplay.styleSheet = CSSDeclaration.TEXT_STYLESHEET;
			super.renderLabel();
			var format:TextFormat = _labelDisplay.getTextFormat();
			_labelDisplay.styleSheet = null;
			_labelDisplay.defaultTextFormat = format;
			_labelDisplay.text = _labelStr || '';
			_labelDisplay.setSelection(selectionStart, selectionEnd);
			_labelDisplay.width = calculateContentWidth() + 4;
			_labelDisplay.height = calculateContentHeight() + 4;
		}
		
		protected function label_change(event : Event) : void
		{
			_labelStr = _labelDisplay.text;
			event.stopImmediatePropagation();
			event.stopPropagation();
			dispatchEvent(new Event(Event.CHANGE));
			applyOverflowProperty();
		}
		
		protected function label_textInput(event : TextEvent) : void
		{
			event.preventDefault();
			var text : String = event.text;
			if (_labelDisplay.maxChars)
			{
				text = event.text.substr(
					0, _labelDisplay.maxChars - _labelDisplay.length +
					_labelDisplay.selectionEndIndex - _labelDisplay.selectionBeginIndex);
				if (!text)
				{
					return;
				}
			}
			if (_currentStyles.textTransform == 'uppercase')
			{
				text = text.toUpperCase();
			}
			else if (_currentStyles.textTransform == 'lowercase')
			{
				text = text.toLowerCase();
			}
			_labelDisplay.replaceSelectedText(text);
			if (_currentStyles.textTransform == 'capitalize')
			{
				var selStart : int = _labelDisplay.selectionBeginIndex;
				var selEnd : int = _labelDisplay.selectionEndIndex;
				_labelDisplay.text = StringUtil.toTitleCase(_labelDisplay.text);
				_labelDisplay.setSelection(selStart, selEnd);
			}
			_labelDisplay.dispatchEvent(new Event(Event.CHANGE, true));
		}

		protected override function applyOverflowProperty() : void
		{
			if ((_labelDisplay.maxScrollV > 1) != _verticalScrollingOn ||
				(_labelDisplay.maxScrollH > 0) != _horizontalScrollingOn)
			{
				_overflowIsInvalid = true;
				super.applyOverflowProperty();
				_verticalScrollingOn = _labelDisplay.maxScrollV > 1;
				_horizontalScrollingOn = _labelDisplay.maxScrollH > 0;
			}
		}

		override protected function updateHover(mouseOut : Boolean = false) : void
		{
			if (!stage || stage.focus == _labelDisplay)
			{
				return;
			}
			super.updateHover(mouseOut);
		}
	}
}