/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.controls
{
	import reprise.ui.AbstractInput;
	import reprise.ui.UIComponent;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;

	public class List extends AbstractInput
	{

		//----------------------             Public Properties              ----------------------//
		
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _itemRendererClass : Class = ListItem;
		protected var _items : Array;
		protected var _selectedIndex : int = -1;

		
		
		//----------------------               Public Methods               ----------------------//
		public function List() 
		{
		}

		public function addItemWithData(data : Object) : void
		{
			(_data as Array).push(data);
			var item : IListItem = new _itemRendererClass() as IListItem;
			item.setData(data);
			addItem(item);
		}

		public function setItemRendererClass(rendererClass : Class) : void
		{
			_itemRendererClass = rendererClass;
		}

		public function itemRendererClass() : Class
		{
			return _itemRendererClass;
		}

		public function set options(options : Array) : void
		{
			removeAllItems();
			_data = [];
			for each (var item : Object in options)
			{
				addItemWithData(item);
			}
			setSelectedIndex(-1);
		}

		public function removeAllItems() : void
		{
			var itemsCopy : Array = _items.concat();
			for each (var item : IListItem in itemsCopy)
			{
				removeItem(item);
			}
			_data = [];
		}

		public function removeItem(item : IListItem) : void
		{
			_items.splice(_items.indexOf(item), 1);
			UIComponent(item).remove();
		}

		public function get options() : Array
		{
			return _data as Array;
		}

		public override function setData(theData : *) : void
		{
			super.setData(theData);
			options = theData;
		}

		public function setSelectedItem(item : IListItem) : void
		{
			setSelectedIndex(_items.indexOf(item));
		}
		public function selectedItem() : IListItem
		{
			return _items[_selectedIndex];
		}
		
		public function setSelectedData(data : Object) : void
		{
			setSelectedIndex((_data as Array).indexOf(data));
		}
		public function selectedData() : Object
		{
			return _data[_selectedIndex];
		}

		public function setSelectedIndex(index : int) : void
		{
			//TODO: use interface here, instead
			if (_items[_selectedIndex] is AbstractButton)
			{
				AbstractButton(_items[_selectedIndex]).selected = false;
			}
			_selectedIndex = Math.min(Math.max(index, -1), _items.length - 1);
			if (_items[_selectedIndex] is AbstractButton)
			{
				AbstractButton(_items[_selectedIndex]).selected = true;
			}
		}
		public function selectedIndex() : int
		{
			return _selectedIndex;
		}

		public override function setValue(value : *) : void
		{
			for (var i : int = (_data as Array).length; i--;)
			{
				if (_data.value == value)
				{
					setSelectedIndex(i);
					return;
				}
			}
		}
		public override function value() : *
		{
			if (_selectedIndex == -1)
			{
				return null;
			}
			return _data[_selectedIndex].value;
		}

		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function initialize() : void
		{
			super.initialize();
			_items = [];
			_data = [];
			addEventListener(MouseEvent.MOUSE_DOWN, self_mouseDown);
		}

		protected function addItem(item : IListItem) : void
		{
			_items.push(item);
			addChild(DisplayObject(item));
			EventDispatcher(item).addEventListener(MouseEvent.CLICK, item_click);
		}

		protected override function parseXMLContent(children : XMLList) : void
		{
			for each (var childNode:XML in children)
			{
				// should we allow display objects other than list items below us?
				if (childNode.localName().toLowerCase() != 'option')
				{
					log('Unsupported tag ' + childNode.localName() + 'below <list>');
				}
				var item : IListItem = new _itemRendererClass() as IListItem;
				var data : Object = {label:childNode.text()};
				data.value = data.label;
				item.setData(data);
				addItem(item);
			}
		}

		protected function item_click(e : Event) : void
		{
			var selectedIndex : int = _selectedIndex;
			setSelectedItem(e.target as IListItem);
			if (_selectedIndex != selectedIndex)
			{
				dispatchEvent(new Event(Event.CHANGE));
			}
		}

		protected function self_mouseDown(e : MouseEvent) : void
		{
			e.stopPropagation();
		}
	}
}