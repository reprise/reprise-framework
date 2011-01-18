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
		/***************************************************************************
		*                           Protected properties                           *
		***************************************************************************/
		protected var m_currentItemDisplay : IListItem;
		protected var m_toggleBtn : SimpleButton;
		protected var m_backgroundCell : UIComponent;
		protected var m_placeholder : String = null;
		protected var m_list : List;
		protected var m_itemRendererClass : Class = ListItem;		

		
		/***************************************************************************
		*                              Public methods                              *
		***************************************************************************/
		public function ComboBox()
		{
		}

		public function setItemRendererClass(rendererClass : Class) : void
		{
			m_itemRendererClass = rendererClass || ListItem;
			m_list && m_list.setItemRendererClass(rendererClass);
			if (m_initialized)
			{
				if (m_currentItemDisplay)
				{
					UIComponent(m_currentItemDisplay).remove();
				}
				m_currentItemDisplay = new m_itemRendererClass();
				UIComponent(m_currentItemDisplay).addCSSClass('currentItem');
				addChildAt(UIComponent(m_currentItemDisplay), 1);
			}
		}

		public function itemRendererClass() : Class
		{
			return m_itemRendererClass;
		}

		
		public function addItemWithData(data : Object) : void
		{
			m_list.addItemWithData(data);
			if (m_list.selectedIndex() == -1 && m_placeholder == null)
			{
				m_list.setSelectedIndex(0);
				m_currentItemDisplay.setData(m_list.selectedData());
			}
		}

		public function set options(options : Array) : void
		{
			m_list.options = options;
		}

		public function get options() : Array
		{
			return m_list.options;
		}

		override public function reset() : void
		{
			super.reset();
			m_placeholder = '';
			m_list.removeAllItems();
			m_list.setSelectedIndex(-1);
			updateLabel();
		}

		public function setSelectedIndex(index : int) : void
		{
			m_list.setSelectedIndex(index);
			updateLabel();
		}

		public override function setValue(value : *) : void
		{
			if (m_list.options.length)
			{
				m_list.setValue(value);
				updateLabel();
			}
		}

		public override function value() : *
		{
			return m_list.value();
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
			m_placeholder = value;
			updateLabel();
		}

		public function placeHolder() : String
		{
			return m_placeholder;
		}

		
		
		/***************************************************************************
		*                             Protected methods                            *
		***************************************************************************/
		protected override function initialize() : void
		{
			super.initialize();
			//			m_canBecomeKeyView = true;
			addEventListener(MouseEvent.MOUSE_DOWN, self_mouseDown);
		}

		protected override function createChildren() : void
		{
			m_backgroundCell = new UIComponent();
			addChild(m_backgroundCell);
			m_backgroundCell.addCSSClass('backgroundCell');
			m_backgroundCell.setStyle('position', 'absolute');
			
			m_currentItemDisplay = new m_itemRendererClass();
			UIComponent(m_currentItemDisplay).addCSSClass('currentItem');
			addChild(UIComponent(m_currentItemDisplay));
			
			m_list = new List();
			addChild(m_list);
			m_itemRendererClass && m_list.setItemRendererClass(m_itemRendererClass);
			m_list.addCSSClass('hidden');
			m_list.addEventListener(Event.CHANGE, list_change);
		}

		protected override function parseXMLContent(children : XMLList) : void
		{
			m_list.removeEventListener(Event.CHANGE, list_change);
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
			m_list.addEventListener(Event.CHANGE, list_change);
		}

		protected function updateLabel() : void
		{
			if (m_list.selectedIndex() == -1)
			{
				m_currentItemDisplay.setData({label : m_placeholder});
				addCSSClass('placeholder');
			}
			else
			{
				m_currentItemDisplay.setData(m_list.selectedData());
				removeCSSClass('placeholder');
			}
		}

		protected function showList() : void
		{			
			removeEventListener(MouseEvent.MOUSE_DOWN, self_mouseDown);
			m_rootElement.addEventListener(MouseEvent.MOUSE_DOWN, document_mouseDown);
			m_list.removeCSSClass('hidden');
		}

		protected function hideList() : void
		{
			m_rootElement.removeEventListener(MouseEvent.MOUSE_DOWN, document_mouseDown);
			addEventListener(MouseEvent.MOUSE_DOWN, self_mouseDown);
			m_list.addCSSClass('hidden');
		}

		protected function self_mouseDown(e : MouseEvent) : void
		{
			showList();
			e.stopPropagation();
		}

		protected function document_mouseDown(e : MouseEvent) : void
		{
			if (m_list.contains(DisplayObject(e.target)))
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