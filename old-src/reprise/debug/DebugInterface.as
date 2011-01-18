/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.debug 
{
	import reprise.core.reprise;
	import reprise.css.ComputedStyles;
	import reprise.events.DebugEvent;
	import reprise.ui.DocumentView;
	import reprise.ui.UIComponent;
	import reprise.ui.UIObject;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.StatusEvent;
	import flash.geom.Point;
	import flash.net.LocalConnection;
	import flash.utils.ByteArray;
	
	use namespace reprise;
	
	public class DebugInterface 
	{
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		protected var m_debuggingMode : Boolean;
		protected var m_currentDebugElement : UIComponent;
		protected var m_debugInterface : Sprite;
		protected var m_debugConnection : LocalConnection;
		protected var m_clientConnection : LocalConnection;
		protected var m_clientConnectionName : String;
		protected var m_document : DocumentView;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function DebugInterface(document : DocumentView)
		{
			m_document = document;
			document.stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDown);
		}
		
		
		/***************************************************************************
		*							reprise methods								   *
		***************************************************************************/
		reprise function startWatchingStylesheets() : void
		{
			var stylesheets : Array = m_document.styleSheet.stylesheetURLs();
			for each (var url : String in stylesheets)
			{
				if (url.indexOf('file://') == 0)
				{
					zz_observe_file(url.substr(7), file_changed);
				}
			}
		}
		
		public function sendDebugInfoForElementPath(path : String) : void
		{
			var element : UIObject = elementForPath(path);
			var msg : String;
			if (!element)
			{
				msg = 'not found';
			}
			else if (element is UIComponent)
			{
				msg = debugMarkElement(UIComponent(element));
				msg += '\n\nComplex styles:\n' + 
					UIComponent(element).valueForKey('m_complexStyles');
			}
			else
			{
				msg = 'UIObject\n';
				msg += 'rect:\t\t' + element.getBounds(element.parentElement()).toString() + '\n';
				msg += 'stage rect:\t' + element.getBounds(m_document.stage).toString() + '\n';
				msg += 'opacity:\t\t' + element.alpha + '\n';
				msg += 'visible:\t\t' + element.visible + '\n';
				msg += 'hidden anc:\t' + element.hasHiddenAncestors() + '\n';
			}
			m_debugConnection.send('_repriseDebugger', 'showDetailsForElement', path, msg);
		}
		
		
		/***************************************************************************
		*							protected methods							   *
		***************************************************************************/
		protected function toggleDebuggingMode() : void
		{
			if (m_debuggingMode)
			{
				deactivateDebuggingMode();
			}
			else
			{
				activateDebuggingMode();
			}
		}
		protected function activateDebuggingMode() : void
		{
			if (m_debuggingMode)
			{
				return;
			}
			m_debuggingMode = true;
			
			m_debugInterface = new Sprite();
			m_debugInterface.mouseEnabled = false;
			m_document.addChild(m_debugInterface);
			
			m_document.stage.addEventListener(
				MouseEvent.MOUSE_OVER, debugging_mouseOver, true, 100);
			
			if (!m_debugConnection)
			{
				m_debugConnection = new LocalConnection();
				m_debugConnection.client = this;
				
	            m_debugConnection.addEventListener(StatusEvent.STATUS, onStatus);
			}
			
			m_clientConnectionName = '_repriseDebugClient_' + new Date().time;
			var test : Array = [{name:'document', elements:childTree(m_document)}];
			var bytes : ByteArray = new ByteArray();
			bytes.writeObject(test);
			bytes.position = 0;
			try
			{
				m_debugConnection.send(
					'_repriseDebugger', 'setRepriseDisplayList', bytes, m_clientConnectionName);
				m_clientConnection = new LocalConnection();
				m_clientConnection.allowDomain('*');
				m_clientConnection.connect(m_clientConnectionName);
				m_clientConnection.client = this;
			}
			catch(error : Error)
			{
				log(error);
			}
		}
		protected function deactivateDebuggingMode() : void
		{
			if (!m_debuggingMode)
			{
				return;
			}
			m_debuggingMode = false;
			
			m_document.removeChild(m_debugInterface);
			m_debugInterface = null;
			m_currentDebugElement = null;
			
			m_document.stage.removeEventListener(MouseEvent.MOUSE_OVER, debugging_mouseOver, true);
		}

		protected function elementForPath(path : String) : UIObject
		{
			var parts : Array = path.split('.');
			parts.shift();
			var element : UIObject = m_document;
			while (parts.length && element)
			{
				var name : String = parts.shift();
				element = element.elementForName(name);
			}
			return element;
		}
		
		protected function childTree(root : UIObject) : Array
		{
			var tree : Array = [];
			var elements : Array = root.children();
			for (var i : int = 0; i < elements.length; i++)
			{
				var child : UIObject = elements[i];
				if (!child)
				{
					continue;
				}
				tree.push({name : child.name, path : child.toString(), elements : childTree(child)});
			}
			return tree;
		}

		protected function debugMarkElement(element : UIComponent) : String
		{
			m_currentDebugElement = element;
			var style : ComputedStyles = element.style;
			var autoFlags : Object = element.autoFlags;
			var output : String = '\nElement: ' + element + 
				'\nSelectorpath: ' + element.selectorPath.split('@').join('') + '\n' + 
				'position: ' + (style.position || 'static') + ', ';
			output += 'top: ' + (autoFlags.top ? 'auto' : style.top + 'px') + 
				', right: ' + (autoFlags.right ? 'auto' : style.right + 'px') + 
				', bottom: ' + (autoFlags.bottom ? 'auto' : style.bottom + 'px') + 
				', left: ' + (autoFlags.left ? 'auto' : style.left + 'px') + '\n';
			output += 'margin: ' + style.marginTop + 'px ' + style.marginRight + 'px ' + 
				style.marginBottom + 'px ' + style.marginLeft + 'px\n';
			
			var position : Point = element.getPositionRelativeToDisplayObject(m_document);
			m_debugInterface.x = position.x;
			m_debugInterface.y = position.y;
			
			m_debugInterface.graphics.clear();
			m_debugInterface.graphics.lineStyle(1, 0xffff);
			
			var boxWidth : Number = element.borderBoxWidth;
			var boxHeight : Number = element.borderBoxHeight;
			output += 'Border Box: width ' + boxWidth + ', height ' + boxHeight + '\n';
			m_debugInterface.graphics.drawRect(-style.borderLeftWidth, 
				-style.borderTopWidth, boxWidth, boxHeight);
			
			boxWidth -= style.borderLeftWidth;
			boxWidth -= style.borderRightWidth;
			boxHeight -= style.borderTopWidth;
			boxHeight -= style.borderBottomWidth;
			output += 'Padding Box: width ' + boxWidth + ', height ' + boxHeight + '\n';
			m_debugInterface.graphics.endFill();
			m_debugInterface.graphics.drawRect(0, 0, boxWidth, boxHeight);
			
			boxWidth -= style.paddingLeft;
			boxWidth -= style.paddingRight;
			boxHeight -= style.paddingTop;
			boxHeight -= style.paddingBottom;
			output += 'Content Box: width ' + boxWidth + ', height ' + boxHeight + '\n';
			m_debugInterface.graphics.endFill();
			m_debugInterface.graphics.drawRect(style.paddingLeft, 
				style.paddingTop, boxWidth, boxHeight);
			
			return output;
		}
		
		protected function reloadStyles() : void
		{
			//TODO: make sure that CSS variables are treated correctly when reloading
			m_document.styleSheet.addEventListener(Event.COMPLETE, styleSheet_complete);
			m_document.styleSheet.reset();
			m_document.styleSheet.execute();
		}

		protected function stage_keyDown(event : KeyboardEvent) : void
		{
			if (event.shiftKey && event.ctrlKey)
			{
				if (event.keyCode == 4) //'d'
				{
					toggleDebuggingMode();
					return;
				}
				if (event.keyCode == 19 && m_currentDebugElement) //'s'
				{
					log('Complex styles:\n' + m_currentDebugElement.valueForKey('m_complexStyles'));
					return;
				}
				if (event.keyCode == 18) //'r'
				{
					reloadStyles();
					return;
				}
				if (event.keyCode == 23) //'w'
				{
					startWatchingStylesheets();
					return;
				}
			}
		}

		protected function file_changed(path : String) : void
		{
			reloadStyles();
		}
		
		protected function styleSheet_complete(event : Event) : void
		{
			m_document.styleSheet.removeEventListener(Event.COMPLETE, styleSheet_complete);
			m_document.dispatchEvent(new DebugEvent(DebugEvent.WILL_RESET_STYLES));
			m_document.resetStyles();
			m_document.dispatchEvent(new DebugEvent(DebugEvent.DID_RESET_STYLES));
		}

		protected function debugging_mouseOver(event : MouseEvent) : void
		{
			var parent : DisplayObject = DisplayObject(event.target);
			var element : UIComponent;
			while (parent)
			{
				if (parent is UIComponent)
				{
					element = UIComponent(parent);
					break;
				}
				parent = parent.parent;
			}
			if (!element)
			{
				m_document.removeChild(m_debugInterface);
				m_debugInterface = null;
				m_currentDebugElement = null;
				return;
			}
			var debugStr : String = debugMarkElement(element);
			m_debugConnection.send('_repriseDebugger', 'showDetailsForElement', 
				element.toString(), debugStr + '\n\nComplex styles:\n' + 
					UIComponent(element).valueForKey('m_complexStyles'));
			log(debugStr);
		}
		
		protected function onStatus(event : StatusEvent) : void
		{
		}
	}
}