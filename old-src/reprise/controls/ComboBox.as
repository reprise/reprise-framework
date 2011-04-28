//
//  ComboBox.as
//
//  Created by Marc Bauer on 2008-06-20.
//  Copyright (c) 2008 Fork Unstable Media GmbH. All rights reserved.
//

package reprise.controls
{
	import reprise.ui.AbstractInput;
	import reprise.ui.UIComponent;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class ComboBox extends AbstractInput
	{
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _currentItemDisplay : IListItem;
		protected var _toggleBtn : SimpleButton;
		protected var _backgroundCell : UIComponent;
		protected var _placeholder : String = null;
		protected var _list : List;
		protected var _itemRendererClass : Class = ListItem;

		
		//----------------------               Public Methods               ----------------------//
		public function ComboBox()
		{
		}

		public function setItemRendererClass(rendererClass : Class) : void
		{
			_itemRendererClass = rendererClass || ListItem;
			_list && _list.setItemRendererClass(rendererClass);
			if (_initialized)
			{
				if (_currentItemDisplay)
				{
					UIComponent(_currentItemDisplay).remove();
				}
				_currentItemDisplay = new _itemRendererClass();
				UIComponent(_currentItemDisplay).addCSSClass('currentItem');
				addChildAt(UIComponent(_currentItemDisplay), 1);
			}
		}

		public function itemRendererClass() : Class
		{
			return _itemRendererClass;
		}

		
		public function addItemWithData(data : Object) : void
		{
			_list.addItemWithData(data);
			if (_list.selectedIndex() == -1 && _placeholder == null)
			{
				_list.setSelectedIndex(0);
				_currentItemDisplay.setData(_list.selectedData());
			}
		}

		public function set options(options : Array) : void
		{
			_list.options = options;
		}

		public function get options() : Array
		{
			return _list.options;
		}

		override public function reset() : void
		{
			super.reset();
			_placeholder = '';
			_list.removeAllItems();
			_list.setSelectedIndex(-1);
			updateLabel();
		}

		public function setSelectedIndex(index : int) : void
		{
			_list.setSelectedIndex(index);
			updateLabel();
		}

		public override function setValue(value : *) : void
		{
			if (_list.options.length)
			{
				_list.setValue(value);
				updateLabel();
			}
		}

		public override function value() : *
		{
			return _list.value();
		}

		/**
		* @private
		*/
		public function setValueAttribute(value : String) : void
		{
			setValue(value);
		}

		public function setPlaceholderAttribute(value : String) : void
		{
			_placeholder = value;
			updateLabel();
		}

		public function placeHolder() : String
		{
			return _placeholder;
		}

		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function initialize() : void
		{
			super.initialize();
			//			_canBecomeKeyView = true;
			addEventListener(MouseEvent.MOUSE_DOWN, self_mouseDown);
		}

		protected override function createChildren() : void
		{
			_backgroundCell = new UIComponent();
			addChild(_backgroundCell);
			_backgroundCell.addCSSClass('backgroundCell');
			_backgroundCell.setStyle('position', 'absolute');
			
			_currentItemDisplay = new _itemRendererClass();
			UIComponent(_currentItemDisplay).addCSSClass('currentItem');
			addChild(UIComponent(_currentItemDisplay));
			
			_list = new List();
			addChild(_list);
			_itemRendererClass && _list.setItemRendererClass(_itemRendererClass);
			_list.addCSSClass('hidden');
			_list.addEventListener(Event.CHANGE, list_change);
		}

		protected override function parseXMLContent(children : XMLList) : void
		{
			_list.removeEventListener(Event.CHANGE, list_change);
			for each (var childNode:XML in children)
			{
				preprocessTextNode(childNode);
				if (childNode.localName() != 'option')
				{
					log('Illegal node ' + childNode.localName() + ' below ComboBox');
					continue;
				}
				else
				{
					addItemWithData({label : childNode.text(), value : childNode.@value.toString()});
				}
			}
			_list.addEventListener(Event.CHANGE, list_change);
		}

		protected function updateLabel() : void
		{
			if (_list.selectedIndex() == -1)
			{
				_currentItemDisplay.setData({label : _placeholder});
				addCSSClass('placeholder');
			}
			else
			{
				_currentItemDisplay.setData(_list.selectedData());
				removeCSSClass('placeholder');
			}
		}

		protected function showList() : void
		{			
			removeEventListener(MouseEvent.MOUSE_DOWN, self_mouseDown);
			_rootElement.addEventListener(MouseEvent.MOUSE_DOWN, document_mouseDown);
			_list.removeCSSClass('hidden');
		}

		protected function hideList() : void
		{
			_rootElement.removeEventListener(MouseEvent.MOUSE_DOWN, document_mouseDown);
			addEventListener(MouseEvent.MOUSE_DOWN, self_mouseDown);
			_list.addCSSClass('hidden');
		}

		protected function self_mouseDown(e : MouseEvent) : void
		{
			showList();
			e.stopPropagation();
		}

		protected function document_mouseDown(e : MouseEvent) : void
		{
			if (_list.contains(DisplayObject(e.target)))
			{
				return;
			}
			hideList();
		}

		protected function list_change(e : Event) : void
		{
			updateLabel();
			hideList();
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}