////////////////////////////////////////////////////////////////////////////////
//
//  Fork unstable media GmbH
//  Copyright 2006-2008 Fork unstable media GmbH
//  All Rights Reserved.
//
//  NOTICE: Fork unstable media permits you to use, modify, and distribute this
//  file in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package reprise.controls
{
	import reprise.css.ComputedStyles;
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
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var AS_LINK_PREFIX : String = "event:";
		
		protected var m_labelDisplay : TextField;
		protected var m_textSetExternally : Boolean;
		
		protected var m_internalStyleIndex : Number;
	
		protected var m_labelXML : XML;
		protected var m_usedLabelXML : XML;
		protected var m_nodesMap : Array;
		protected var m_textLinkHrefs : Array;
	
		protected var m_textAlignment : String;
		protected var m_containsImages : Boolean;	
		protected var m_overflowIsInvalid : Boolean;
		
		protected var m_bitmapCache : Bitmap;
		protected var m_cacheInvalid : Boolean;
		protected var m_lastHoverIndex : int;
		protected var m_usePointer : Boolean;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function Label ()
		{
		}
		
		/**
		 * sets the label to display
		 */
		public function setLabel(label:String) : void
		{
			XML.ignoreWhitespace = false;
			m_labelXML = new XML('<p>' + label + '</p>');
			XML.ignoreWhitespace = true;
			m_textSetExternally = true;
			invalidate();
		}
		public function getLabel() : String
		{
			XML.prettyPrinting = false;
			var labelStr:String = m_labelXML.toXMLString();
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
			m_instanceStyles.setStyle('selectable', value ? 'true' : 'false');
			m_labelDisplay.selectable = enabled;
		}
		
		public function get enabled () : Boolean
		{
			return m_currentStyles.selectable;
		}
		
		public function get textWidth() : Number
		{
			return m_labelDisplay.textWidth;
		}
		
		public function get textHeight() : Number
		{
			return m_labelDisplay.textHeight;
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
			var oldOpacity : Number = m_currentStyles.opacity || -1;
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
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function initialize () : void
		{
			super.initialize();
			
			m_labelXML = <p/>;
			m_textLinkHrefs = [];
			m_nodesMap = [];
		}
		protected override function createChildren() : void
		{
			m_labelDisplay = new TextField();
			m_labelDisplay = TextField(m_contentDisplay.addChild(m_labelDisplay));
			m_labelDisplay.name = 'labelDisplay';
			m_labelDisplay.mouseEnabled = false;
			m_labelDisplay.styleSheet = CSSDeclaration.TEXT_STYLESHEET;
			m_contentDisplay.addEventListener(MouseEvent.CLICK, labelDisplay_click);
			m_contentDisplay.addEventListener(MouseEvent.MOUSE_MOVE, contentDisplay_mouseMove);
			m_contentDisplay.addEventListener(MouseEvent.MOUSE_OUT, contentDisplay_mouseOut);
			m_labelDisplay.addEventListener(TextEvent.LINK, labelDisplay_link);
		}
		
		protected override function initDefaultStyles() : void
		{
			m_elementDefaultStyles.setStyle('selectable', 'true');
			m_elementDefaultStyles.setStyle('display', 'inline');
			m_elementDefaultStyles.setStyle('wordWrap', 'wrap');
			m_elementDefaultStyles.setStyle('multiline', 'true');
		}
		
		protected override function applyStyles() : void
		{
			if (m_usePointer && m_currentStyles.cursor != 'pointer')
			{
				var oldCursor : String = m_currentStyles.cursor;
				m_currentStyles.cursor = 'pointer';
				super.applyStyles();
				m_currentStyles.cursor = oldCursor;
			}
			else
			{
				super.applyStyles();
			}
			
			//TODO: find a way to re-enable tab stops
//			var fmt : TextFormat = new TextFormat();
//			if (m_currentStyles.tabStops)
//			{
//				var tabStops : Array = 
//					m_currentStyles.tabStops.split(", ").join(",").split(",");
//				fmt.tabStops = tabStops;
//			}
//			else
//			{
//				fmt.tabStops = null;
//			}
			
			m_labelDisplay.selectable = m_currentStyles.selectable;
			if (m_currentStyles.color)
			{
				m_labelDisplay.alpha = m_currentStyles.color.opacity();
			}
			else
			{
				m_labelDisplay.alpha = 1;
			}
			
			m_labelDisplay.embedFonts = m_currentStyles.embedFonts;
			m_labelDisplay.antiAliasType = m_currentStyles.antiAliasType || 
				AntiAliasType.NORMAL;
			if (m_labelDisplay.antiAliasType == AntiAliasType.ADVANCED)
			{
				m_labelDisplay.gridFitType = 
					m_currentStyles.gridFitType || GridFitType.PIXEL;
				m_labelDisplay.sharpness = m_currentStyles.sharpness || 0;
				m_labelDisplay.thickness = m_currentStyles.thickness || 0;
			}
			m_labelDisplay.wordWrap = m_currentStyles.wordWrap == 'wrap';
			m_labelDisplay.multiline = m_currentStyles.multiline;
		}

		override protected function validateChildren() : void
		{
			renderLabel();
		}
		
		/**
		 * Don't do anything here: Labels don't have child elements
		 */
		protected override function parseXMLContent(node : XML) : void
		{
			m_xmlDefinition = node;
			if (node.localName().toLowerCase() != 'p')
			{
				XML.prettyPrinting = false;
				XML.ignoreWhitespace = false;
				m_labelXML = <p/>;
				m_labelXML.setChildren(node);
			}
			else
			{
				m_labelXML = node;
			}
		}
		
		protected override function measure() : void
		{
			if (m_labelDisplay.text == '')
			{
				m_intrinsicWidth = 0;
				m_intrinsicHeight = 0;
			}
			else
			{
				//TODO: find a way to make measuring work if the TextField contains IMGs
				m_intrinsicWidth = Math.ceil(m_labelDisplay.textWidth);
				m_intrinsicHeight = Math.ceil(m_labelDisplay.height - 4);
			}
		}
		
		protected function renderLabel() : void
		{
			if (!(m_stylesInvalidated || m_textSetExternally))
			{
				return;
			}
			m_labelDisplay.x = m_currentStyles.paddingLeft - 2;
			m_labelDisplay.y = m_currentStyles.paddingTop - 2;
			
			m_internalStyleIndex = 0;
			m_textAlignment = null;
			m_containsImages = false;
			
			XML.prettyPrinting = false;
			XML.ignoreWhitespace = false;
			var labelString : String = m_labelXML.toXMLString();
			labelString = resolveBindings(labelString);
			var labelXML : XML;
			try
			{
				labelXML = new XML(labelString);
			}
			catch (error : Error)
			{
				labelXML = new XML('<p style="color: red;">malformed content</p>');
			}
			m_nodesMap.length = 0;
			cleanNode(labelXML, m_selectorPath, m_rootElement.styleSheet, new NodeCleanupConfig());
			
			m_textSetExternally = false;
			applyLabel(labelXML);
		}
		
		protected function applyLabel(labelXML : XML) : void
		{
			XML.prettyPrinting = false;
			XML.ignoreWhitespace = false;
			var text : String = labelXML.toXMLString();
			text = text.substr(0, text.length - 3);
			if (text == m_labelDisplay.htmlText)
			{
				return;
			}
			
			if (m_currentStyles.width)
			{
				m_labelDisplay.width = m_currentStyles.width + 6;
			}
			else
			{
				m_labelDisplay.autoSize = 'left';
			}
			m_labelDisplay.htmlText = text;
			m_usedLabelXML = labelXML;
			m_cacheInvalid = true;
			
			if (m_labelDisplay.wordWrap)
			{
				m_labelDisplay.autoSize = 'left';
				var enforceUpdate : Number = m_labelDisplay.height;
			}
			else
			{
				m_labelDisplay.height = m_labelDisplay.textHeight + 8;
			}
			m_labelDisplay.autoSize = 'none';
			
			//shrink the TextField to the smallest width possible
			if (m_textAlignment != 'mixed' && !m_containsImages)
			{
				if (m_labelDisplay.textWidth < m_labelDisplay.width - 10)
				{
					m_labelDisplay.width = m_labelDisplay.textWidth + 10;
					if (m_textAlignment == 'right')
					{
						m_labelDisplay.x = m_currentStyles.paddingLeft + 
							m_currentStyles.width - m_labelDisplay.width + 2;
					}
					else if (m_textAlignment == 'center')
					{
						m_labelDisplay.x = m_currentStyles.paddingLeft + Math.round(
							m_currentStyles.width / 2 - 
							m_labelDisplay.width / 2);
					}
				}
			}
			
			m_overflowIsInvalid = true;
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
				nodeStyle = m_complexStyles.clone();
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
			
			var styleName : String = nodeStyle.textStyleName(m_internalStyleIndex++ == 0);
			node.@['class'] = styleName;
			
			// check if the label has mixed textAlign properties.
			// If it does its TextField can't be shrinked horizontally
			if (m_textAlignment != 'mixed')
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
				if (!m_textAlignment)
				{
					m_textAlignment = textAlign;
				}
				else if (m_textAlignment != textAlign)
				{
					m_textAlignment = 'mixed';
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
						node.@href = AS_LINK_PREFIX + m_textLinkHrefs.length;
						m_textLinkHrefs.push(href);
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
							leadingStyle.textStyleName(m_internalStyleIndex++ == 0);
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
					m_containsImages = true;
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
			m_nodesMap.push({start : startIndex, end : config.index, path : selectorPath, 
				styleName : styleName, node : node});
		}
		/**
		 * event handler, invoked on click of one of 
		 * the links inside of the displayed text
		 */
		protected function labelDisplay_click(event : MouseEvent) : Boolean
		{
			var clickedChar : int = m_labelDisplay.getCharIndexAtPoint(m_labelDisplay.mouseX, m_labelDisplay.mouseY);
			if (!m_labelDisplay.length || clickedChar == -1)
			{
				return false;
			}
			var clickedFormat : TextFormat = 
				m_labelDisplay.getTextFormat(clickedChar, clickedChar + 1);
			
			if (!clickedFormat.url)
			{
				return false;
			}
			var linkIndex:Number = parseInt(clickedFormat.url.substring(AS_LINK_PREFIX.length));
			var hrefArr:Array = String(m_textLinkHrefs[linkIndex]).split("|");
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
				index = m_labelDisplay.getCharIndexAtPoint(
					m_labelDisplay.mouseX, m_labelDisplay.mouseY);
			}
			if (index == m_lastHoverIndex)
			{
				return;
			}
			
			var usePointer : Boolean = false;
			var innerStart : int = 0;
			var innerEnd : int = m_labelDisplay.length;
			for (var i : int = m_nodesMap.length; i--;)
			{
				var def : Object = m_nodesMap[i];
				var node : XML = def.node;
				if (int(def.start) <= index && int(def.end) > index)
				{
					if (!def.hover)
					{
						def.hover = true;
						def.defaultClass = node.@['class'].toString();
						var hoverStyle : CSSDeclaration = m_rootElement.styleSheet.
							getStyleForEscapedSelectorPath(def.path + '@:hover@');
						node.@['class'] = hoverStyle.textStyleName(node.parent() == null);
						labelChanged = true;
						def.pointer ||= (hoverStyle.hasStyle('cursor') 
							? hoverStyle.getStyle('cursor').specifiedValue()
							: null) == 'pointer';
					}
					if (def.start > innerStart || def.end < innerEnd)
					{
						innerStart = def.start;
						innerEnd = def.end;
						usePointer = def.pointer;
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
				var oldWidth : Number = m_labelDisplay.width;
				var oldHeight : Number = m_labelDisplay.height;
				applyLabel(m_usedLabelXML);
				m_labelDisplay.width = oldWidth;
				m_labelDisplay.height = oldHeight;
				if (m_overflowIsInvalid)
				{
					invalidate();
				}
			}
			if (usePointer)
			{
				m_usePointer = true;
				if (!buttonMode)
				{
					buttonMode = true;
					useHandCursor = true;
				}
			}
			else if (buttonMode && m_currentStyles.cursor != 'pointer')
			{
				buttonMode = false;
				useHandCursor = false;
			}
			m_lastHoverIndex = index;
		}
		
		protected function transformText(text:String, transform:String) : String
		{
			switch (transform)
			{
				case 'uppercase':
				{
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
			m_stylesInvalidated ||= m_overflowIsInvalid;
			super.validateAfterChildren();
		}

		protected override function applyOverflowProperty() : void
		{
			if (!m_overflowIsInvalid)
			{
				return;
			}
			m_overflowIsInvalid = false;
			var overflowX : * = m_currentStyles.overflowX;
			var overflowY : * = m_currentStyles.overflowY;
			
			if ((m_currentStyles.overflowX == null || 
				overflowX == 'visible' || overflowX == 'hidden') && 
				(m_currentStyles.overflowY == null || overflowY == 'visible' || 
				overflowY == 'hidden'))
			{
				super.applyOverflowProperty();
				return;
			}
			
			var availableWidth:Number = m_currentStyles.width;
			var availableHeight:Number = Math.max(calculateContentHeight(), 
				m_currentStyles.height);
			var scrollbarWidth : Number = 
				m_currentStyles.scrollbarWidth || DEFAULT_SCROLLBAR_WIDTH;
			
			if (overflowY == 'scroll')
			{
				if (!m_vScrollbar)
				{
					m_vScrollbar = createScrollbar(Scrollbar.ORIENTATION_VERTICAL);
				}
				availableWidth -= scrollbarWidth;
				m_vScrollbar.setVisibility(true);
			}
			if (overflowX == 'scroll')
			{
				if (!m_hScrollbar)
				{
					m_hScrollbar = createScrollbar(Scrollbar.ORIENTATION_HORIZONTAL);
				}
				availableHeight -= scrollbarWidth;
				m_hScrollbar.setVisibility(true);
			}
			if (overflowY == 0) //'auto' gets resolved to '0'
			{
				m_labelDisplay.height = availableHeight + 4;
				m_labelDisplay.width = availableWidth + 4;
				//we have to query maxScrollH before maxScrollV because otherwise the 
				//value returned for maxScrollV isn't always correct.
				var maxScrollH : int = m_labelDisplay.maxScrollH;
				var maxScrollV : int = m_labelDisplay.maxScrollV;
				if (maxScrollV > 1)
				{
					if (!m_vScrollbar)
					{
						m_vScrollbar = createScrollbar(Scrollbar.ORIENTATION_VERTICAL);
					}
					availableWidth -= scrollbarWidth;
					m_vScrollbar.setVisibility(true);
					m_labelDisplay.width = availableWidth + 3;
				}
				else if (m_vScrollbar)
				{
					m_vScrollbar.setVisibility(false);
				}
			}
			if (overflowX == 0)
			{
				if (!m_labelDisplay.wordWrap && maxScrollH > 0)
				{
					if (!m_hScrollbar)
					{
						m_hScrollbar = createScrollbar(Scrollbar.ORIENTATION_HORIZONTAL);
					}
					availableHeight -= scrollbarWidth;
					m_hScrollbar.setVisibility(true);
					
					if ((!m_vScrollbar || !m_vScrollbar.visibility()) && 
						m_labelDisplay.maxScrollV > 1)
					{
						if (!m_vScrollbar)
						{
							m_vScrollbar = 
								createScrollbar(Scrollbar.ORIENTATION_VERTICAL);
						}
						availableWidth -= scrollbarWidth;
						m_vScrollbar.setVisibility(true);
					}
				}
				else if (m_hScrollbar)
				{
					m_hScrollbar.setVisibility(false);
				}
			}
			if (!(m_vScrollbar && m_vScrollbar.visibility()) && 
				!(m_hScrollbar && m_hScrollbar.visibility()))
			{
				return;
			}
			
			if (m_hScrollbar && overflowX == 'hidden')
			{
				m_hScrollbar.setVisibility(false);
			}
			if (m_vScrollbar && overflowY == 'hidden')
			{
				m_vScrollbar.setVisibility(false);
			}
			
			m_labelDisplay.width = availableWidth + 6;
			m_labelDisplay.height = availableHeight + 6;
			
			availableHeight += m_currentStyles.paddingTop + m_currentStyles.paddingBottom;
			availableWidth += m_currentStyles.paddingLeft + m_currentStyles.paddingRight;
			
			if (m_vScrollbar)
			{
				m_vScrollbar.height = availableHeight;
				m_vScrollbar.top = m_currentStyles.borderTopWidth;
				m_vScrollbar.left = availableWidth + m_currentStyles.borderLeftWidth;
				m_vScrollbar.delayValidation();
			}
			
			if (m_hScrollbar)
			{
				m_hScrollbar.height = availableWidth;
				m_hScrollbar.top = availableHeight + scrollbarWidth;
				m_hScrollbar.left = m_currentStyles.borderLeftWidth;
				m_hScrollbar.delayValidation();
			}
		}
	
		protected override function createScrollbar(orientation : String, 
			skipListenerRegistration : Boolean = true) : Scrollbar
		{
			var scrollbar : Scrollbar = super.createScrollbar(orientation, true);
			scrollbar.setScrollTarget(m_labelDisplay, orientation);
			scrollbar.addEventListener(Event.CHANGE, scrollbar_change);
			return scrollbar;
		}
		
		protected override function draw() : void
		{
			if (!m_cacheInvalid && !m_dimensionsChanged)
			{
				return;
			}
			m_cacheInvalid = false;
			applyRasterize();
		}
		
		/**
		 * Applies the 'rasterize-device-fonts' CSS setting by making a bitmap copy of the text 
		 * field and displaying that instead of the text field itself. This allows text set in 
		 * device fonts to be transformed and displayed with opacities other than 1.
		 */
		protected function applyRasterize() : void
		{
			if (m_bitmapCache)
			{
				m_contentDisplay.removeChild(m_bitmapCache);
				m_bitmapCache = null;
			}
			if (!m_currentStyles.embedFonts && 
				(m_currentStyles.opacity < 1 || m_currentStyles.rasterizeDeviceFonts))
			{
				m_labelDisplay.visible = false;
				if (m_currentStyles.opacity == 0)
				{
					m_cacheInvalid = true;
					return;
				}
				var bitmap : BitmapData = new BitmapData(
					m_labelDisplay.width, m_labelDisplay.height, true, 0);
				bitmap.draw(m_labelDisplay, null, null, null, null, true);
				m_bitmapCache = new Bitmap(bitmap, 'auto', true);
				m_contentDisplay.addChild(m_bitmapCache);
				m_bitmapCache.x = m_labelDisplay.x - 2;
				m_bitmapCache.y = m_labelDisplay.y - 2;
			}
			else
			{
				m_labelDisplay.visible = true;
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