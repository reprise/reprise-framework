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
		protected var m_label:Label;
		protected var m_toggleBtn:SimpleButton;
		protected var m_backgroundCell:UIComponent;
		protected var m_placeholder:String = null;
		protected var m_list : List;		
		
		
		/***************************************************************************
		*                              Public methods                              *
		***************************************************************************/
		public function ComboBox() {}
		
		
		
		public function addItemWithTitleAndValue(title:String, value:*):void
		{
			m_list.addItemWithTitleAndValue(title, value);
			if (m_list.selectedIndex() == -1 && m_placeholder == null)
			{
				m_list.setSelectedIndex(0);
				m_label.setLabel(m_list.selectedLabel());
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
		
		public function setSelectedIndex(index : int) : void
		{
			m_list.setSelectedIndex(index);
			updateLabel();
		}

		public override function value():*
		{
			return m_list.value();
		}
		
		public override function setValue(value:*):void
		{
			if (m_list.options.length)
			{
				m_list.setValue(value);
				updateLabel();
			}
		}
		
		/**
		 * @private
		 */
		public function setValueAttribute(value : String) : void
		{
			setValue(value);
		}
		
		public function setPlaceholderAttribute(value : String):void
		{
			m_placeholder = value;
			updateLabel();
		}
		
		
		
		/***************************************************************************
		*                             Protected methods                            *
		***************************************************************************/
		protected override function initialize():void
		{
			super.initialize();
//			m_canBecomeKeyView = true;
			addEventListener(MouseEvent.MOUSE_DOWN, self_mouseDown);
		}
		
		protected override function createChildren():void
		{
			m_backgroundCell = new UIComponent();
			addChild(m_backgroundCell);
			m_backgroundCell.addCSSClass('backgroundCell');
			m_backgroundCell.setStyle('position', 'absolute');
			
			m_label = new Label();
			addChild(m_label);
			
			m_list = new List();
			addChild(m_list);
			m_list.addCSSClass('hidden');
			m_list.addEventListener(Event.CHANGE, list_change);
		}
		
		protected override function parseXMLContent(node:XML):void
		{
			m_list.removeEventListener(Event.CHANGE, list_change);
			for each (var childNode:XML in node.children())
			{
				preprocessTextNode(childNode);
				if (childNode.localName() != 'option')
				{
					log('Illegal node ' + childNode.localName() + ' below ComboBox');
					continue;
				}
				else
				{
					addItemWithTitleAndValue(childNode.text(), childNode.@value.toString());
				}
			}
			m_list.addEventListener(Event.CHANGE, list_change);
		}
		
		protected function updateLabel() : void
		{
			if (m_list.selectedIndex() == -1)
			{
				m_label.setLabel(m_placeholder);
				addCSSClass('placeholder');
			}
			else
			{
				m_label.setLabel(m_list.selectedLabel());
				removeCSSClass('placeholder');
			}
		}
		
		protected function showList():void
		{			
			removeEventListener(MouseEvent.MOUSE_DOWN, self_mouseDown);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDown);
			m_list.removeCSSClass('hidden');
		}
		
		protected function hideList():void
		{
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDown);
			addEventListener(MouseEvent.MOUSE_DOWN, self_mouseDown);
			m_list.addCSSClass('hidden');
		}
		
		protected function self_mouseDown(e:MouseEvent):void
		{
			showList();
		}
		
		protected function stage_mouseDown(e:MouseEvent):void
		{
			if (contains(DisplayObject(e.target)))
			{
				return;
			}
			hideList();
		}
		
		protected function list_change(e:Event):void
		{
			updateLabel();
			hideList();
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}