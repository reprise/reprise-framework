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
	import reprise.utils.StringUtil;	
	import reprise.core.reprise;
	import reprise.css.CSS;
	import reprise.css.CSSDeclaration;
	import reprise.css.CSSParsingHelper;
	import reprise.css.CSSProperty;
	import reprise.events.LabelEvent;
	import reprise.ui.AbstractInput;
	
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
		public static var className : String = "Label";
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var AS_LINK_PREFIX : String = "event:";
		
		protected var m_labelDisplay : TextField;
		protected var m_textSetExternally : Boolean;
		protected var m_selectable : Boolean;
		
		protected var m_textLinkHrefs : Array;
		
		protected var m_internalStyleIndex : Number;
	
		protected var m_labelXML : XML;
	
		protected var m_htmlMode : Boolean;
	
		protected var m_textAlignment : String;
		protected var m_containsImages : Boolean;	
		protected var m_overflowIsInvalid : Boolean;
		
		protected var m_bitmapCache : Bitmap;
		private var m_cacheInvalid : Boolean;

		
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
			m_labelXML = new XML('<p>' + label + '</p>');
			m_textSetExternally = true;
			invalidate();
		}
		public function getLabel() : String
		{
			var labelStr:String = m_labelXML.toXMLString();
			return labelStr;
			return labelStr.substring(
				labelStr.indexOf(">") + 1, labelStr.lastIndexOf("<"));
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
		
		/**
		 * sets whether the label should be displayed with html formatting or not
		 */
		public function set html(value:Boolean) : void
		{
			if (m_htmlMode != value)
			{
				m_htmlMode = value;
				invalidate();
			}
		}
		/**
		 * sets whether the label should be displayed with html formatting or not
		 */
		public function get html() : Boolean
		{
			return m_htmlMode;
		}
		
		public function set enabled(value:Boolean) : void
		{
			m_instanceStyles.setStyle('selectable', value ? 'true' : 'false');
			m_labelDisplay.selectable = enabled;
		}
		
		public function get enabled () : Boolean
		{
			return m_selectable;
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
		}
		protected override function createChildren() : void
		{
			m_labelDisplay = new TextField();
			m_labelDisplay = m_contentDisplay.addChild(m_labelDisplay) as TextField;
			m_labelDisplay.name = 'labelDisplay';
			m_labelDisplay.condenseWhite = true;
			m_labelDisplay.styleSheet = CSSDeclaration.TEXT_STYLESHEET;
			m_labelDisplay.addEventListener(MouseEvent.CLICK, labelDisplay_click);
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
			super.applyStyles();
			m_selectable = m_currentStyles.selectable;
			
			var fmt : TextFormat = new TextFormat();
			if (m_currentStyles.tabStops)
			{
				var tabStops : Array = 
					m_currentStyles.tabStops.split(", ").join(",").split(",");
				fmt.tabStops = tabStops;
			}
			else
			{
				fmt.tabStops = null;
			}
		}
		
		/**
		 * Don't do anything here: Labels don't have child elements
		 */
		protected override function parseXMLContent(node : XML) : void
		{
			m_xmlDefinition = node;
			if (node.localName() != 'p')
			{
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
			if (m_stylesInvalidated)
			{
				if (m_selectorPathChanged)
				{
					m_labelDisplay.selectable = m_selectable;
					
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
			}
			if (m_stylesInvalidated || m_textSetExternally)
			{
				m_labelDisplay.x = m_currentStyles.paddingLeft - 2;
				m_labelDisplay.y = m_currentStyles.paddingTop - 2;
				if (m_currentStyles.width)
				{
					m_labelDisplay.width = m_currentStyles.width + 6;
				}
				else
				{
					m_labelDisplay.autoSize = 'left';
				}
				
				m_internalStyleIndex = 0;
				m_textAlignment = null;
				m_containsImages = false;
				
				var labelString : String = m_labelXML.toXMLString();
				labelString = resolveBindings(labelString);
				var labelXML : XML = new XML(labelString);
				labelXML.normalize();
				cleanNode(labelXML, m_selectorPath, m_rootElement.styleSheet);
				//TODO: check if condenseWhite = true is ok to use!
				
				var text : String = labelXML.toXMLString();
				if (text.substr(0, text.length - 3) != m_labelDisplay.htmlText)
				{
					m_labelDisplay.htmlText = text.substr(0, text.length - 3);
					m_cacheInvalid = true;
				}
				
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
				
				m_textSetExternally = false;
				m_overflowIsInvalid = true;
			}
		}
		
		protected override function applyInFlowChildPositions() : void
		{
			renderLabel();
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
		protected function cleanNode(node:XML, selectorPath:String, 
			stylesheet:CSS, transform:String = null) : void
		{
			if (node.nodeKind() == 'text')
			{
				if (transform)
				{
					node.parent().children()[node.childIndex()] = 
						transformText(node.toString(), transform);
				}
				//nothing else to clean in text nodes
				return;
			}
			if (node.localName() == 'br' || node.hasOwnProperty('ignore'))
			{
				//nothing to clean in <br>-nodes
				return;
			}
			
			//bring all style definitions into a form the player can understand
			var nodeStyle : CSSDeclaration;
			if (!node.parent())
			{
				nodeStyle = m_complexStyles.clone();
				var transformStyle : CSSProperty = nodeStyle.getStyle('textTransform');
				transformStyle && (transform = String(transformStyle.valueOf()));
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
				selectorPath += " @" + node.localName() + "@" + classesStr + id;
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
			
			if (nodeStyle)
			{
				var styleName : String = 
					nodeStyle.textStyleName(m_internalStyleIndex++ == 0);
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
			}
			
			switch (node.localName())
			{
				//TODO: Check if we need the whitespace cleanup stuff. We most certainly 
				//don't, because we call XML::normalize on the root node. (Ok, turns out 
				//we don't do that, but use TextField::condenseWhite, so that should be 
				//fine.)
//				case "br":
//				{
//					//remove all redundant whitespace around "<br />"-tags
//					var parent : XML = node.parent();
//					var siblings : XMLList = parent ? parent.children() : null;
//					if (!siblings)
//					{
//						//we are the root node, get outta here
//						//TODO: check if that's even possible
//						 break;
//					}
//					var sibling : XML = siblings[node.childIndex() - 1];
//					if (sibling && sibling.nodeKind() == 'text')
//					{
//						sibling.setChildren(StringUtil.rTrim(sibling.toString()));
//					}
//					sibling = siblings[node.childIndex() + 1];
//					if (sibling && sibling.nodeKind() == 'text')
//					{
//						sibling.setChildren(StringUtil.lTrim(sibling.toString()));
//					}
//					break;
//				}
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
					/*
					 * TODO: Find a way to simulate correct margins instead of just 
					 * adding a line break.
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
					//do nothing these tags are fine
					break;
				}
				case "img":
				{
					//we can't shrink the TextField later on, because the player 
					//doesn't include images in its calculation of textWidth and 
					//textHeight. Therefore, we flag that now and don't try to 
					//reduce the size
					m_containsImages = true;
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
				cleanNode(child, selectorPath, stylesheet, transform);
			}
		}
		/**
		 * event handler, invoked on click of one of 
		 * the links inside of the displayed text
		 */
		protected function labelDisplay_click(event : MouseEvent) : Boolean
		{
			var clickedChar : int = m_labelDisplay.getCharIndexAtPoint(
				m_labelDisplay.mouseX, m_labelDisplay.mouseY);
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
			labelEvent.url = href;
			labelEvent.linkTarget = target;
			dispatchEvent(labelEvent);
			if (!labelEvent.isDefaultPrevented())
			{
				var request:URLRequest = new URLRequest(labelEvent.url);
				navigateToURL(request, labelEvent.linkTarget || '_self');
			}
			event.stopImmediatePropagation();
			event.stopPropagation();
			
			return true;
		}
		
		protected function labelDisplay_link(e:TextEvent):void
		{
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();			
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