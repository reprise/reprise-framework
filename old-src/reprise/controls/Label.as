/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.controls
{
	import reprise.core.reprise;
	import reprise.css.CSS;
	import reprise.css.CSSDeclaration;
	import reprise.css.CSSParsingHelper;
	import reprise.css.CSSProperty;
	import reprise.events.LabelEvent;
	import reprise.ui.AbstractInput;
	import reprise.utils.StringUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;		
	
	use namespace reprise;

	public class Label extends AbstractInput
	{
		//----------------------             Public Properties              ----------------------//
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected static var AS_LINK_PREFIX : String = "event:";
		
		protected var _labelDisplay : TextField;
		protected var _textSetExternally : Boolean;
		
		protected var _internalStyleIndex : int;
	
		protected var _labelXML : XML;
		protected var _usedLabelXML : XML;
		protected var _nodesMap : Array;
		protected var _textLinkHrefs : Array;
	
		protected var _textAlignment : String;
		protected var _containsImages : Boolean;
		protected var _overflowIsInvalid : Boolean;
		
		protected var _bitmapCache : Bitmap;
		protected var _cacheInvalid : Boolean;
		protected var _lastHoverIndex : int;

		
		//----------------------               Public Methods               ----------------------//
		public function Label ()
		{
		}
		
		/**
		 * sets the label to display
		 */
		public function setLabel(label:String) : void
		{
			XML.ignoreWhitespace = false;
			_labelXML = new XML('<p>' + label + '</p>');
			XML.ignoreWhitespace = true;
			_textSetExternally = true;
			invalidate();
		}
		public function getLabel() : String
		{
			XML.prettyPrinting = false;
			var labelStr:String = _labelXML.toXMLString();
			return labelStr;
		}
	
		public function get label() : String
		{
			return getLabel();
		}
		
		public function set label(txt:String) : void
		{
			setLabel(txt);
		}
		
		public override function value():*
		{
			return label;
		}
		
		public override function setValue(value:*):void
		{
			label = value.toString();
		}
		
		public function set enabled(value:Boolean) : void
		{
			_instanceStyles.setStyle('selectable', value ? 'true' : 'false');
			_labelDisplay.selectable = enabled;
			_labelDisplay.mouseEnabled = enabled;
		}
		
		public function get enabled () : Boolean
		{
			return _currentStyles.selectable;
		}
		
		public function get textWidth() : Number
		{
			return _labelDisplay.textWidth;
		}
		
		public function get textHeight() : Number
		{
			return _labelDisplay.textHeight;
		}
	
		/**
		* setter for the opacity property.
		* This override allows for proper opacity setting even for labels 
		* containing device text.
		*/
		public override function set opacity(value : Number) : void
		{
			//set oldOpacity to an impossible value if it doesn't exist 
			//to make comparison easy
			var oldOpacity : Number = _currentStyles.opacity || -1;
			if (value == oldOpacity)
			{
				return;
			}
			
			super.opacity = value;
			var oldOpacityRange : Number = 
				(oldOpacity == 0 ? 0 : (oldOpacity < 1 ? 1 : 2));
			var opacityRange : Number = 
				(value == 0 ? 0 : (value < 1 ? 1 : 2));
			if (oldOpacityRange != opacityRange)
			{
				draw();
			}
		}
		
		public function handleTextClick(event : MouseEvent) : Boolean
		{
			return labelDisplay_click(event);
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function initialize () : void
		{
			super.initialize();
			
			_labelXML = <p/>;
			_textLinkHrefs = [];
			_nodesMap = [];
		}
		protected override function createChildren() : void
		{
			_labelDisplay = new TextField();
			_labelDisplay = TextField(_contentDisplay.addChild(_labelDisplay));
			_labelDisplay.name = 'labelDisplay';
			_labelDisplay.styleSheet = CSSDeclaration.TEXT_STYLESHEET;
			_contentDisplay.addEventListener(MouseEvent.CLICK, labelDisplay_click);
			_contentDisplay.addEventListener(MouseEvent.MOUSE_MOVE, contentDisplay_mouseMove);
			_contentDisplay.addEventListener(MouseEvent.MOUSE_OUT, contentDisplay_mouseOut);
			_labelDisplay.addEventListener(TextEvent.LINK, labelDisplay_link);
		}
		
		protected override function initDefaultStyles() : void
		{
			_elementDefaultStyles.setStyle('selectable', 'true');
			_elementDefaultStyles.setStyle('display', 'inline');
			_elementDefaultStyles.setStyle('wordWrap', 'wrap');
			_elementDefaultStyles.setStyle('multiline', 'true');
		}
		
		protected override function applyStyles() : void
		{
			super.applyStyles();
			
			//TODO: find a way to re-enable tab stops
//			var fmt : TextFormat = new TextFormat();
//			if (_currentStyles.tabStops)
//			{
//				var tabStops : Array = 
//					_currentStyles.tabStops.split(", ").join(",").split(",");
//				fmt.tabStops = tabStops;
//			}
//			else
//			{
//				fmt.tabStops = null;
//			}
			
			_labelDisplay.selectable = _currentStyles.selectable;
			_labelDisplay.mouseEnabled = _currentStyles.selectable;
			if (_currentStyles.color)
			{
				_labelDisplay.alpha = _currentStyles.color.opacity();
			}
			else
			{
				_labelDisplay.alpha = 1;
			}
			
			_labelDisplay.embedFonts = _currentStyles.embedFonts;
			_labelDisplay.antiAliasType = _currentStyles.antiAliasType ||
				AntiAliasType.NORMAL;
			if (_labelDisplay.antiAliasType == AntiAliasType.ADVANCED)
			{
				_labelDisplay.gridFitType =
					_currentStyles.gridFitType || GridFitType.PIXEL;
				_labelDisplay.sharpness = _currentStyles.sharpness || 0;
				_labelDisplay.thickness = _currentStyles.thickness || 0;
			}
			_labelDisplay.wordWrap = _currentStyles.wordWrap == 'wrap';
			_labelDisplay.multiline = _currentStyles.multiline;
		}

		override protected function validateChildren() : void
		{
			renderLabel();
		}

		override protected function parseXMLDefinition(xmlDefinition : XML) : void
		{
			super.parseXMLDefinition(xmlDefinition);
			
			if (xmlDefinition.localName().toLowerCase() != 'p')
			{
				XML.prettyPrinting = false;
				_labelXML = <p/>;
				_labelXML.setChildren(xmlDefinition);
			}
			else
			{
				_labelXML = xmlDefinition;
			}
		}

		/**
		 * Don't do anything here: Labels don't have child elements
		 */
		protected override function parseXMLContent(children : XMLList) : void
		{
		}
		
		protected override function measure() : void
		{
			if (_labelDisplay.text == '')
			{
				_intrinsicWidth = 0;
				_intrinsicHeight = 0;
			}
			else
			{
				//TODO: find a way to make measuring work if the TextField contains IMGs
				_intrinsicWidth = Math.ceil(_labelDisplay.textWidth);
				_intrinsicHeight = Math.ceil(_labelDisplay.height - 4);
			}
		}
		
		protected function renderLabel() : void
		{
			if (!(_stylesInvalidated || _textSetExternally))
			{
				return;
			}
			
			_internalStyleIndex = 0;
			_textAlignment = null;
			_containsImages = false;
			
			XML.prettyPrinting = false;
			var labelString : String = _labelXML.toXMLString();
			labelString = resolveBindings(labelString);
			XML.ignoreWhitespace = false;
			var labelXML : XML;
			try
			{
				labelXML = new XML(labelString);
			}
			catch (error : Error)
			{
				labelXML = new XML('<p style="color: red;">malformed content</p>');
			}
			XML.ignoreWhitespace = true;
			_nodesMap.length = 0;
			cleanNode(labelXML, _selectorPath, _rootElement.styleSheet, new NodeCleanupConfig());
			
			_textSetExternally = false;
			applyLabel(labelXML);
			
			//apply final positioning
			_labelDisplay.y = _currentStyles.paddingTop - 2;
			if (_textAlignment == 'left')
			{
				_labelDisplay.x = _currentStyles.paddingLeft - 2;
			}
			else if (_textAlignment == 'right')
			{
				_labelDisplay.x = _currentStyles.paddingLeft +
					_currentStyles.width - _labelDisplay.width + 2;
			}
			else if (_textAlignment == 'center')
			{
				_labelDisplay.x = _currentStyles.paddingLeft + Math.round(
					_currentStyles.width / 2 - _labelDisplay.width / 2);
			}
		}
		
		protected function applyLabel(labelXML : XML) : void
		{
			XML.prettyPrinting = false;
			var text : String = labelXML.toXMLString();
			text = text.substr(0, text.length - 3);
			var textChanged : Boolean = text != _labelDisplay.htmlText;
			
			if (!textChanged && _oldContentBoxWidth == _contentBoxWidth &&
				_oldContentBoxHeight == _contentBoxHeight)
			{
				return;
			}
			
			_cacheInvalid = true;
			
			if (_currentStyles.width)
			{
				_labelDisplay.width = _currentStyles.width + 6;
			}
			else
			{
				_labelDisplay.autoSize = 'left';
			}
			if (textChanged)
			{
				_labelDisplay.htmlText = text;
				_usedLabelXML = labelXML;
			}
			if (_labelDisplay.wordWrap)
			{
				_labelDisplay.autoSize = 'left';
				var enforceUpdate : Number = _labelDisplay.height;
			}
			else
			{
				_labelDisplay.height = _labelDisplay.textHeight + 8;
			}
			_labelDisplay.autoSize = 'none';
			
			_overflowIsInvalid = true;
			
			//shrink the TextField to the smallest width possible
			if (_textAlignment != 'mixed' && !_containsImages &&
				_labelDisplay.textWidth < _labelDisplay.width - 10)
			{
				var correctTextHeight : Number = _labelDisplay.textHeight;
				var correctTextWidth : Number = _labelDisplay.textWidth;
				var originalWidth : Number = _labelDisplay.width;
				_labelDisplay.width = _labelDisplay.textWidth + 10;
				if (_labelDisplay.textHeight != correctTextHeight ||
					_labelDisplay.textWidth != correctTextWidth)
				{
					/* in some cases, the TextField incorrectly wraps text to the next line 
					 * even though there's plenty enough room for it on the current line. 
					 * In case such an incorrect wrapping occurs after shrinking the TextField, 
					 * we have to roll it back.
					 */
					_labelDisplay.width = originalWidth;
				}
			}
		}
		
		protected override function applyInFlowChildPositions() : void
		{
		}
		
		/**
		 * we're guaranteed not to have any child elements, so we can ignore this
		 */
		protected override function applyOutOfFlowChildPositions() : void
		{
		}
		
		/**
		 * cleanes the given node to prepare it for display in a TextField
		 */
		protected function cleanNode(
			node:XML, selectorPath:String, stylesheet:CSS, config : NodeCleanupConfig) : void
		{
			var startIndex : int = config.index;
			if (node.nodeKind() == 'text')
			{
				var textChanged : Boolean = false;
				var text : String = node.toString();
				if (config.transform)
				{
					text = transformText(text, config.transform);
					textChanged = true;
				}
				for (var i : int = 0; i < text.length - 1; i++)
				{
					if (' \n\r\t'.indexOf(text.charAt(i)) != -1 && 
						' \n\r\t'.indexOf(text.charAt(i + 1)) != -1)
					{
						textChanged = true;
						text = text.substr(0, i + 1) + text.substr(i + 2);
						i--;
					}
				}
				if (config.removeFirstWhitespace && ' \n\r\t'.indexOf(text.charAt(0)) != -1)
				{
					text = text.substr(1);
				}
				if (text.length)
				{
					config.removeFirstWhitespace = 
						' \n\r\t'.indexOf(text.charAt(text.length - 1)) != -1;
				}
				config.index += text.length;
				
				if (textChanged)
				{
					node.parent().children()[node.childIndex()] = text;
				}
				//nothing else to clean in text nodes
				return;
			}
			if (node.localName().toLowerCase() == 'br')
			{
				//nothing to clean in <br>-nodes, but we need to remove the next whitespace
				config.removeFirstWhitespace = true;
				config.index++;
				return;
			}
			if (node.hasOwnProperty('ignore'))
			{
				return;
			}
			
			//bring all style definitions into a form the player can understand
			var nodeStyle : CSSDeclaration;
			if (!node.parent())
			{
				nodeStyle = _complexStyles.clone();
				var transformStyle : CSSProperty = nodeStyle.getStyle('textTransform');
				transformStyle && (config.transform = String(transformStyle.valueOf()));
			}
			else
			{
				var classesStr:String = node.@['class'].toString();
				if (classesStr.length)
				{
					classesStr = "@." + classesStr.split(" ").join("@.") + "@";
				}
				var id:String = node.@id.toString();
				if (id.length)
				{
					id = "@#" + id + "@";
					delete node.@id;
				}
				selectorPath += " @" + node.localName().toLowerCase() + "@" + classesStr + id;
				nodeStyle = stylesheet.getStyleForEscapedSelectorPath(selectorPath);
			}
			//the player doesn't understand the "style" attribute, so we need to
			//copy all information into a class
			var stylesStr:String = node.@style.toString();
			if (stylesStr.length)
			{
				nodeStyle.mergeCSSDeclaration(
					CSSParsingHelper.parseDeclarationString(stylesStr, null));
				delete node.@style;
			}
			
			var styleName : String = nodeStyle.textStyleName(_internalStyleIndex++ == 0);
			node.@['class'] = styleName;
			
			// check if the label has mixed textAlign properties.
			// If it does its TextField can't be shrinked horizontally
			if (_textAlignment != 'mixed')
			{
				var textAlignProperty : CSSProperty = nodeStyle.getStyle('textAlign');
				var textAlign : String;
				if (textAlignProperty)
				{
					textAlign = textAlignProperty.valueOf() as String;
				}
				else
				{
					textAlign = 'left';
				}
				if (!_textAlignment)
				{
					_textAlignment = textAlign;
				}
				else if (_textAlignment != textAlign)
				{
					_textAlignment = 'mixed';
				}
			}
			
			var isBlockNode : Boolean = false;
			switch (node.localName().toLowerCase())
			{
				case "a":
				{
					//extract all links and redirect them to an ActionScript method
					var href:String = node.@href.toString();
					if (href.length)
					{
						var target:String = node.@target.toString();
						if (target.length)
						{
							href += '|' + target;
							delete node.@target;
						}
						node.@href = AS_LINK_PREFIX + _textLinkHrefs.length;
						_textLinkHrefs.push(href);
					}
					break;
				}
				case "p":
				{
					if (!node.parent())
					{
						break;
					}
					isBlockNode = true;
					/*
					 * TODO: Find a way to support marginTop
					 */ 
					if (nodeStyle.hasStyle('marginBottom'))
					{
						var leading : Number = ((nodeStyle.getStyle(
							'marginBottom').valueOf() as Number) - 2);
						stylesStr = 'leading: ' + leading + '; font-size: 1;';
						var leadingStyle : CSSDeclaration = 
							CSSParsingHelper.parseDeclarationString(stylesStr, null);
						styleName = 
							leadingStyle.textStyleName(_internalStyleIndex++ == 0);
						node.parent().insertChildAfter(node, new XML(
							'<p ignore="1" class="' + styleName + '">&nbsp;</p>'));
					}
					break;
				}
				case "span":
				case "ul":
				case "li":
				{
					//do nothing, these tags are fine
					break;
				}
				case "img":
				{
					//we can't shrink the TextField later on, because the player 
					//doesn't include images in its calculation of textWidth and 
					//textHeight. Therefore, we flag that now and don't try to 
					//reduce the size
					_containsImages = true;
					var nodeDisplayType : String = nodeStyle.getStyle('display')
						? nodeStyle.getStyle('display').specifiedValue() 
						: 'block';
					if (nodeDisplayType == 'block')
					{
						isBlockNode = true;
					}
					break;
				}
				default:
				{
					//replace unknown tags by <span> tag. This enables styling 
					//the node using the "class"-attribute, which is not possible 
					//on tags unknown to the player
					node.setLocalName('span');
				}
			}
			
			for each (var child : XML in node.children())
			{
				cleanNode(child, selectorPath, stylesheet, config);
			}
			if (isBlockNode)
			{
				config.removeFirstWhitespace = true;
				config.index++;
			}
			_nodesMap.push({start : startIndex, end : config.index, path : selectorPath,
				styleName : styleName, node : node});
		}
		/**
		 * event handler, invoked on click of one of 
		 * the links inside of the displayed text
		 */
		protected function labelDisplay_click(event : MouseEvent) : Boolean
		{
			var clickedChar : int = _labelDisplay.getCharIndexAtPoint(_labelDisplay.mouseX, _labelDisplay.mouseY);
			if (!_labelDisplay.length || clickedChar == -1)
			{
				return false;
			}
			var clickedFormat : TextFormat = 
				_labelDisplay.getTextFormat(clickedChar, clickedChar + 1);
			
			if (!clickedFormat.url)
			{
				return false;
			}
			var linkIndex:Number = parseInt(clickedFormat.url.substring(AS_LINK_PREFIX.length));
			var hrefArr:Array = String(_textLinkHrefs[linkIndex]).split("|");
			var href:String = hrefArr[0];
			var target:String = hrefArr[1];
			
			var labelEvent : LabelEvent = new LabelEvent(LabelEvent.LINK_CLICK, true);
			labelEvent.href = href;
			labelEvent.linkTarget = target;
			dispatchEvent(labelEvent);
			if (!labelEvent.isDefaultPrevented())
			{
				var request:URLRequest = new URLRequest(labelEvent.href);
				navigateToURL(request, labelEvent.linkTarget || '_self');
			}
			event.stopImmediatePropagation();
			
			return true;
		}
		
		protected function labelDisplay_link(e:TextEvent):void
		{
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();			
		}
		
		protected function contentDisplay_mouseMove(event : MouseEvent) : void
		{
			updateHover();
		}
		protected function contentDisplay_mouseOut(event : MouseEvent) : void
		{
			updateHover(true);
		}

		protected function updateHover(mouseOut : Boolean = false) : void
		{
			var labelChanged : Boolean;
			var index : int = -1;
			if (!mouseOut)
			{
				index = _labelDisplay.getCharIndexAtPoint(
					_labelDisplay.mouseX, _labelDisplay.mouseY);
			}
			if (index == _lastHoverIndex)
			{
				return;
			}
			
			for (var i : int = _nodesMap.length; i--;)
			{
				var def : Object = _nodesMap[i];
				var node : XML = def.node;
				if (int(_nodesMap[i].start) <= index && int(_nodesMap[i].end) > index)
				{
					if (!def.hover)
					{
						def.hover = true;
						def.defaultClass = node.@['class'].toString();
						var hoverStyle : CSSDeclaration = _rootElement.styleSheet.
							getStyleForEscapedSelectorPath(def.path + '@:hover@');
						node.@['class'] = hoverStyle.textStyleName(node.parent() == null);
						labelChanged = true;
					}
				}
				else if (def.hover)
				{
					def.hover = false;
					node.@['class'] = def.defaultClass;
					labelChanged = true;
				}
			}
			
			if (labelChanged)
			{
				var oldWidth : Number = _labelDisplay.width;
				var oldHeight : Number = _labelDisplay.height;
				applyLabel(_usedLabelXML);
				_labelDisplay.width = oldWidth;
				_labelDisplay.height = oldHeight;
				if (_overflowIsInvalid)
				{
					invalidate();
				}
			}
			_lastHoverIndex = index;
		}
		
		protected function transformText(text:String, transform:String) : String
		{
			switch (transform)
			{
				case 'uppercase':
				{
					if (text.indexOf('ß') != -1)
					{
						text = text.split('ß').join('SS');
					}
					text = text.toUpperCase();
					break;
				}
				case 'lowercase':
				{
					text = text.toLowerCase();
					break;
				}
				case 'capitalize':
				{
					text = StringUtil.toTitleCase(text);
					break;
				}
			}
			return text;
		}

		override protected function validateAfterChildren() : void
		{
			_stylesInvalidated ||= _overflowIsInvalid;
			super.validateAfterChildren();
		}

		protected override function applyOverflowProperty() : void
		{
			if (!_overflowIsInvalid)
			{
				return;
			}
			_overflowIsInvalid = false;
			var overflowX : * = _currentStyles.overflowX;
			var overflowY : * = _currentStyles.overflowY;
			
			if ((_currentStyles.overflowX == null ||
				overflowX == 'visible' || overflowX == 'hidden') && 
				(_currentStyles.overflowY == null || overflowY == 'visible' ||
				overflowY == 'hidden'))
			{
				super.applyOverflowProperty();
				return;
			}
			
			var availableWidth:Number = _currentStyles.width;
			var availableHeight:Number = Math.max(calculateContentHeight(), 
				_currentStyles.height);
			var scrollbarWidth : Number = 
				_currentStyles.scrollbarWidth || DEFAULT_SCROLLBAR_WIDTH;
			
			if (overflowY == 'scroll')
			{
				if (!_vScrollbar)
				{
					_vScrollbar = createScrollbar(Scrollbar.ORIENTATION_VERTICAL);
				}
				availableWidth -= scrollbarWidth;
				_vScrollbar.setVisibility(true);
			}
			if (overflowX == 'scroll')
			{
				if (!_hScrollbar)
				{
					_hScrollbar = createScrollbar(Scrollbar.ORIENTATION_HORIZONTAL);
				}
				availableHeight -= scrollbarWidth;
				_hScrollbar.setVisibility(true);
			}
			if (overflowY == 0) //'auto' gets resolved to '0'
			{
				_labelDisplay.height = availableHeight + 4;
				_labelDisplay.width = availableWidth + 4;
				//we have to query maxScrollH before maxScrollV because otherwise the 
				//value returned for maxScrollV isn't always correct.
				var maxScrollH : int = _labelDisplay.maxScrollH;
				var maxScrollV : int = _labelDisplay.maxScrollV;
				if (maxScrollV > 1)
				{
					if (!_vScrollbar)
					{
						_vScrollbar = createScrollbar(Scrollbar.ORIENTATION_VERTICAL);
					}
					availableWidth -= scrollbarWidth;
					_vScrollbar.setVisibility(true);
					_labelDisplay.width = availableWidth + 3;
				}
				else if (_vScrollbar)
				{
					_vScrollbar.setVisibility(false);
				}
			}
			if (overflowX == 0)
			{
				if (!_labelDisplay.wordWrap && maxScrollH > 0)
				{
					if (!_hScrollbar)
					{
						_hScrollbar = createScrollbar(Scrollbar.ORIENTATION_HORIZONTAL);
					}
					availableHeight -= scrollbarWidth;
					_hScrollbar.setVisibility(true);
					
					if ((!_vScrollbar || !_vScrollbar.visibility()) &&
						_labelDisplay.maxScrollV > 1)
					{
						if (!_vScrollbar)
						{
							_vScrollbar =
								createScrollbar(Scrollbar.ORIENTATION_VERTICAL);
						}
						availableWidth -= scrollbarWidth;
						_vScrollbar.setVisibility(true);
					}
				}
				else if (_hScrollbar)
				{
					_hScrollbar.setVisibility(false);
				}
			}
			if (!(_vScrollbar && _vScrollbar.visibility()) &&
				!(_hScrollbar && _hScrollbar.visibility()))
			{
				return;
			}
			
			if (_hScrollbar && overflowX == 'hidden')
			{
				_hScrollbar.setVisibility(false);
			}
			if (_vScrollbar && overflowY == 'hidden')
			{
				_vScrollbar.setVisibility(false);
			}
			
			_labelDisplay.width = availableWidth + 6;
			_labelDisplay.height = availableHeight + 6;
			
			availableHeight += _currentStyles.paddingTop + _currentStyles.paddingBottom;
			availableWidth += _currentStyles.paddingLeft + _currentStyles.paddingRight;
			
			if (_vScrollbar)
			{
				_vScrollbar.height = availableHeight;
				_vScrollbar.top = _currentStyles.borderTopWidth;
				_vScrollbar.left = availableWidth + _currentStyles.borderLeftWidth;
				_vScrollbar.delayValidation();
			}
			
			if (_hScrollbar)
			{
				_hScrollbar.height = availableWidth;
				_hScrollbar.top = availableHeight + scrollbarWidth;
				_hScrollbar.left = _currentStyles.borderLeftWidth;
				_hScrollbar.delayValidation();
			}
		}
	
		protected override function createScrollbar(orientation : String, 
			skipListenerRegistration : Boolean = true) : Scrollbar
		{
			var scrollbar : Scrollbar = super.createScrollbar(orientation, true);
			scrollbar.setScrollTarget(_labelDisplay, orientation);
			scrollbar.addEventListener(Event.CHANGE, scrollbar_change);
			return scrollbar;
		}
		
		protected override function draw() : void
		{
			if (!_cacheInvalid && !_dimensionsChanged)
			{
				return;
			}
			_cacheInvalid = false;
			applyRasterize();
		}

		/**
		 * Applies the 'rasterize-device-fonts' CSS setting by making a bitmap copy of the text 
		 * field and displaying that instead of the text field itself. This allows text set in 
		 * device fonts to be transformed and displayed with opacities other than 1.
		 */
		protected function applyRasterize() : void
		{
			if (_bitmapCache)
			{
				_contentDisplay.removeChild(_bitmapCache);
				_bitmapCache = null;
			}
			if (!_currentStyles.embedFonts &&
				(_currentStyles.opacity < 1 || _currentStyles.rasterizeDeviceFonts))
			{
				_labelDisplay.visible = false;
				if (_currentStyles.opacity == 0 || !_labelDisplay.width || !_labelDisplay.height)
				{
					_cacheInvalid = true;
					return;
				}
				var bitmap : BitmapData = new BitmapData(
					_labelDisplay.width, _labelDisplay.height, true, 0);
				bitmap.draw(_labelDisplay, null, null, null, null, true);
				_bitmapCache = new Bitmap(bitmap, 'auto', true);
				_contentDisplay.addChild(_bitmapCache);
				_bitmapCache.x = _labelDisplay.x;
				_bitmapCache.y = _labelDisplay.y;
			}
			else
			{
				_labelDisplay.visible = true;
			}
		}

		protected function scrollbar_change(event : Event) : void
		{
			draw();
		}
	}
}

final class NodeCleanupConfig
{
	public var index : int = 0;
	public var removeFirstWhitespace : Boolean = true;
	public var transform : String;
	public function NodeCleanupConfig()
	{
		
	}
}