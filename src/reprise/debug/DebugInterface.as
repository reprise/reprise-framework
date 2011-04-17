/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.debug 
{
	import flash.display.Stage;
	import flash.utils.Dictionary;

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
		protected static const _instance : DebugInterface = new DebugInterface();


		protected var m_debuggingMode : Boolean;
		protected var m_currentDebugElement : UIComponent;
		protected var m_debugInterface : Sprite;
		protected var m_debugConnection : LocalConnection;
		protected var m_clientConnection : LocalConnection;
		protected var m_clientConnectionName : String;

		protected const _documentsByReference : Dictionary = new Dictionary();
		protected const _documentsByName : Dictionary = new Dictionary();

		private var _documentsCount : int = 0;
		private var _stage : Stage;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function DebugInterface()
		{
		}

		public static function addDocument(document : DocumentView) : void
		{
			_instance.addDocument(document);
		}

		public static function removeDocument(document : DocumentView) : void
		{
			_instance.removeDocument(document);
		}

		protected function addDocument(document : DocumentView) : void
		{
			_documentsByReference[document] = document;
			_documentsByName[document.name] = document;

			if (_documentsCount++ > 0)
			{
				return;
			}
			_stage = document.stage;
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDown);
		}

		protected function removeDocument(document : DocumentView) : void
		{
			delete _documentsByReference[document];
			delete _documentsByName[document.name];

			if (--_documentsCount > 0)
			{
				return;
			}
			_stage = null;
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, stage_keyDown);
		}
		
		
		/***************************************************************************
		*							reprise methods								   *
		***************************************************************************/
		reprise static function startWatchingStylesheets(document : DocumentView) : void
		{
			_instance.startWatchingStylesheets(document);
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
				msg += 'stage rect:\t' + element.getBounds(_stage).toString() + '\n';
				msg += 'opacity:\t\t' + element.alpha + '\n';
				msg += 'visible:\t\t' + element.visible + '\n';
				msg += 'hidden anc:\t' + element.hasHiddenAncestors() + '\n';
			}
			m_debugConnection.send('_repriseDebugger', 'showDetailsForElement', path, msg);
		}
		
		
		/***************************************************************************
		*							protected methods							   *
		***************************************************************************/
		protected function startWatchingStylesheets(document : DocumentView) : void
		{
			var stylesheets : Array = document.styleSheet.stylesheetURLs();
			for each (var url : String in stylesheets)
			{
				if (url.indexOf('file://') == 0)
				{
					zz_observe_file(url.substr(7), file_changed);
				}
			}
		}
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
			m_debugInterface.mouseChildren = false;
			_stage.addChild(m_debugInterface);
			
			_stage.addEventListener(MouseEvent.MOUSE_OVER, debugging_mouseOver, true, 100);
			
//			if (!m_debugConnection)
//			{
//				m_debugConnection = new LocalConnection();
//				m_debugConnection.client = this;
//
//	            m_debugConnection.addEventListener(StatusEvent.STATUS, onStatus);
//			}
//
//			m_clientConnectionName = '_repriseDebugClient_' + new Date().time;
//			var test : Array = [{name:'document', elements:childTree(m_document)}];
//			var bytes : ByteArray = new ByteArray();
//			bytes.writeObject(test);
//			bytes.position = 0;
//			try
//			{
//				m_debugConnection.send(
//					'_repriseDebugger', 'setRepriseDisplayList', bytes, m_clientConnectionName);
//				m_clientConnection = new LocalConnection();
//				m_clientConnection.allowDomain('*');
//				m_clientConnection.connect(m_clientConnectionName);
//				m_clientConnection.client = this;
//			}
//			catch(error : Error)
//			{
//				log(error);
//			}
		}
		protected function deactivateDebuggingMode() : void
		{
			if (!m_debuggingMode)
			{
				return;
			}
			m_debuggingMode = false;
			
			_stage.removeChild(m_debugInterface);
			m_debugInterface = null;
			m_currentDebugElement = null;
			
			_stage.removeEventListener(MouseEvent.MOUSE_OVER, debugging_mouseOver, true);
		}

		protected function elementForPath(path : String) : UIObject
		{
			var parts : Array = path.split('.');
			var element : UIObject = _documentsByName[parts[0]];
			if (!element)
			{
				log('document not registered in DebugInterface: ' + parts[0]);
				return null;
			}
			parts.shift();
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
			m_debugInterface.graphics.clear();
			if (!element)
			{
				return '';
			}
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
			
			var position : Point = element.getPositionRelativeToDisplayObject(_stage);
			m_debugInterface.x = position.x;
			m_debugInterface.y = position.y;

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

			log(output);
			return output;
		}
		
		protected function reloadStyles() : void
		{
			//TODO: make sure that CSS variables are treated correctly when reloading
			for each (var document : DocumentView in _documentsByReference)
			{
				document.styleSheet.addEventListener(Event.COMPLETE, styleSheet_complete);
				document.styleSheet.reset();
				document.styleSheet.execute();
			}
		}

		protected function stage_keyDown(event : KeyboardEvent) : void
		{
			if (event.shiftKey && event.ctrlKey)
			{
				var key : String = String.fromCharCode(event.keyCode).toLowerCase();
				if (key == 'd')
				{
					toggleDebuggingMode();
					return;
				}
				if (key == 's' && m_currentDebugElement)
				{
					log('Complex styles:\n' + m_currentDebugElement.valueForKey('m_complexStyles'));
					return;
				}
				if (key == 'r')
				{
					reloadStyles();
					return;
				}
				if (key == 'w')
				{
					for each (var document : DocumentView in _documentsByReference)
					{
						startWatchingStylesheets(document);
					}
					return;
				}
				if (key == 'h')
				{
					log('debug keys:\n' +
						'd - toggle debug mode\n' +
							's - log currently debugged element\'s complex styles\n' +
							'r - reload stylesheets\n' +
							'w - start watching stylesheets');
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
			var document : DocumentView = DocumentView(event.target);
			document.styleSheet.removeEventListener(Event.COMPLETE, styleSheet_complete);
			document.dispatchEvent(new DebugEvent(DebugEvent.WILL_RESET_STYLES));
			document.resetStyles();
			document.dispatchEvent(new DebugEvent(DebugEvent.DID_RESET_STYLES));
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
			debugMarkElement(element);
//			m_debugConnection.send('_repriseDebugger', 'showDetailsForElement',
//				element.toString(), debugStr + '\n\nComplex styles:\n' +
//					UIComponent(element).valueForKey('m_complexStyles'));
		}
		
		protected function onStatus(event : StatusEvent) : void
		{
		}
	}
}