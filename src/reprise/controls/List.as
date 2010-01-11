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

		/***************************************************************************
		 *                             Public properties                            *
		 ***************************************************************************/
		
		
		/***************************************************************************
		 *                           Protected properties                           *
		 ***************************************************************************/
		protected var m_itemRendererClass : Class = ListItem;
		protected var m_items : Array;
		protected var m_selectedIndex : int = -1;

		
		
		/***************************************************************************
		 *                              Public methods                              *
		 ***************************************************************************/
		public function List() 
		{
		}

		public function addItemWithData(data : Object) : void
		{
			(m_data as Array).push(data);
			var item : IListItem = new m_itemRendererClass() as IListItem;
			item.setData(data);
			addItem(item);
		}

		public function setItemRendererClass(rendererClass : Class) : void
		{
			m_itemRendererClass = rendererClass;
		}

		public function itemRendererClass() : Class
		{
			return m_itemRendererClass;
		}

		public function set options(options : Array) : void
		{
			removeAllItems();
			m_data = [];
			for each (var item : Object in options)
			{
				addItemWithData(item);
			}
			setSelectedIndex(-1);
		}

		public function removeAllItems() : void
		{
			var itemsCopy : Array = m_items.concat();
			for each (var item : IListItem in itemsCopy)
			{
				removeItem(item);
			}
			m_data = [];
		}

		public function removeItem(item : IListItem) : void
		{
			m_items.splice(m_items.indexOf(item), 1);
			UIComponent(item).remove();
		}

		public function get options() : Array
		{
			return m_data as Array;
		}

		public override function setData(theData : *) : void
		{
			super.setData(theData);
			options = theData;
		}

		public function setSelectedItem(item : IListItem) : void
		{
			setSelectedIndex(m_items.indexOf(item));
		}
		public function selectedItem() : IListItem
		{
			return m_items[m_selectedIndex]; 
		}
		
		public function setSelectedData(data : Object) : void
		{
			setSelectedIndex((m_data as Array).indexOf(data));
		}
		public function selectedData() : Object
		{
			return m_data[m_selectedIndex];
		}

		public function setSelectedIndex(index : int) : void
		{
			//TODO: use interface here, instead
			if (m_items[m_selectedIndex] is AbstractButton)
			{
				AbstractButton(m_items[m_selectedIndex]).selected = false;
			}
			m_selectedIndex = Math.min(Math.max(index, -1), m_items.length - 1);
			if (m_items[m_selectedIndex] is AbstractButton)
			{
				AbstractButton(m_items[m_selectedIndex]).selected = true;
			}
		}
		public function selectedIndex() : int
		{
			return m_selectedIndex;
		}

		public override function setValue(value : *) : void
		{
			for (var i : int = (m_data as Array).length; i--;)
			{
				if (m_data.value == value)
				{
					setSelectedIndex(i);
					return;
				}
			}
		}
		public override function value() : *
		{
			if (m_selectedIndex == -1)
			{
				return null;
			}
			return m_data[m_selectedIndex].value;
		}

		
		
		/***************************************************************************
		 *                             Protected methods                            *
		 ***************************************************************************/
		protected override function initialize() : void
		{
			super.initialize();
			m_items = [];
			m_data = [];
			addEventListener(MouseEvent.MOUSE_DOWN, self_mouseDown);
		}

		protected function addItem(item : IListItem) : void
		{
			m_items.push(item);
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
				var item : IListItem = new m_itemRendererClass() as IListItem;
				var data : Object = {label:childNode.text()};
				data.value = data.label;
				item.setData(data);
				addItem(item);
			}
		}

		protected function item_click(e : Event) : void
		{
			var selectedIndex : int = m_selectedIndex;
			setSelectedItem(e.target as IListItem);
			if (m_selectedIndex != selectedIndex)
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