//
//  List.as
//
//  Created by Marc Bauer on 2008-06-20.
//  Copyright (c) 2008 Fork Unstable Media GmbH. All rights reserved.
//

package reprise.controls
{

	import reprise.ui.AbstractInput;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import reprise.controls.ListItem;
	
	
	public class List extends AbstractInput
	{
		
		/***************************************************************************
		*                             Public properties                            *
		***************************************************************************/
		public static var itemRenderer:Class = ListItem;
		
		
		
		/***************************************************************************
		*                           Protected properties                           *
		***************************************************************************/
		protected var m_items:Array;
		protected var m_selectedIndex:int = -1;
		
		
		
		/***************************************************************************
		*                              Public methods                              *
		***************************************************************************/
		public function List() {}
		
		
		public function addItemWithTitleAndValue(title:String, value:*):void
		{
			(m_data as Array).push({title:title, value:value});
			var item:ListItem = new itemRenderer() as ListItem;
			item.setLabel(title);
			addItem(item);
		}
		
		public function set options(options : Array) : void
		{
			removeAllItems();
			m_data = [];
			for each (var item : Object in options)
			{
				addItemWithTitleAndValue(item.label, item.value);
			}
			setSelectedIndex(-1);
		}
		
		public function removeAllItems() : void
		{
			var itemsCopy:Array = m_items.concat();
			for each (var item : ListItem in itemsCopy)
			{
				removeItem(item);
			}
		}
		
		public function removeItem(item : ListItem) : void
		{
			m_items.splice(m_items.indexOf(item), 1);
			item.remove();
		}

		public function get options():Array
		{
			return m_data as Array;
		}
		
		public override function setData(theData:*):void
		{
			super.setData(theData);
			options = theData;
		}
		
		public function selectItem(item:ListItem):void
		{
			setSelectedIndex(m_items.indexOf(item));
		}
		
		public function selectItemWithValue(value:*):void
		{
			var i:int = m_items.length;
			while (i--)
			{
				var entry:Object = m_data[i];
				if (entry.value == value)
				{
					setSelectedIndex(i);
					return;
				}
			}
		}
		
		public function selectedItem():ListItem
		{
			return m_items[m_selectedIndex] as ListItem; 
		}
		
		public function selectedLabel():String
		{
			return selectedItem().getLabel();
		}
		
		public function selectedIndex():int
		{
			return m_selectedIndex;
		}
		
		public function setSelectedIndex(index : int):void
		{
			if (m_items[m_selectedIndex] is ListItem)
			{
				ListItem(m_items[m_selectedIndex]).selected = false;
			}
			m_selectedIndex = Math.min(Math.max(index, -1), m_items.length - 1);
			if (m_items[m_selectedIndex] is ListItem)
			{
				ListItem(m_items[m_selectedIndex]).selected = true;
			}
		}
		
		public override function setValue(value:*):void
		{
			selectItemWithValue(value);
		}
		
		public override function value():*
		{
			if (m_selectedIndex == -1)
			{
				return null;
			}
			return (m_data as Array)[m_selectedIndex].value;
		}
		
		
		
		/***************************************************************************
		*                             Protected methods                            *
		***************************************************************************/
		protected override function initialize():void
		{
			super.initialize();
			m_items = [];
			m_data = [];
			addEventListener(MouseEvent.MOUSE_DOWN, self_mouseDown);
		}
		
		protected function addItem(item:ListItem):void
		{
			m_items.push(item);
			addChild(item);
			item.addEventListener(MouseEvent.CLICK, item_click);
		}
		
		protected override function parseXMLContent(node:XML):void
		{
			for each (var childNode:XML in node.children())
			{
				// should we allow display objects other than list items below us?
				if (childNode.localName().toLowerCase() != 'option')
				{
					log('Unsupported tag ' + childNode.localName() + 'below <list>');
				}
				var item:ListItem = new itemRenderer() as ListItem;
				item.setLabel(childNode.text());
				addItem(item);
			}
		}
		
		protected function item_click(e:Event):void
		{
			selectItem(e.target as ListItem);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		protected function self_mouseDown(e:MouseEvent):void
		{
			e.stopPropagation();
		}
	}
}