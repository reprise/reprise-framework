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

package reprise.ui.layoutmanagers 
{
	import reprise.css.ComputedStyles;	
	import reprise.core.reprise;
	import reprise.ui.UIComponent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	use namespace reprise;
	
	public class CSSBoxModelLayoutManager 
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		private var m_displayStack : Array;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/ 
		public function applyFlowPositions(
			element : UIComponent, children : Array) : void
		{
			var childCount : int = children.length;
			if (!childCount)
			{
				element.style.intrinsicHeight = 0;
				element.style.intrinsicWidth = 0;
				return;
			}
			
			element.style.collapsedMarginTop = element.style.marginTop;
			element.style.collapsedMarginBottom = element.style.marginBottom;
			
			m_displayStack = [];
			var elementStyle : ComputedStyles = element.style;
			
			var widestChildWidth:int = 0;
			var collapsibleMargin:int = 0;
			var topMarginCollapsible:Boolean = !elementStyle.borderTopWidth && 
				!elementStyle.paddingTop && element.positionInFlow;
			if (topMarginCollapsible)
			{
				collapsibleMargin = elementStyle.marginTop;
			}
			
			var totalAvailableWidth:int = element.innerWidth();
			var currentLineBoxTop:int = elementStyle.paddingTop;
			var currentLineBoxHeight:int = 0;
			var initialLineBoxLeftBoundary : int = elementStyle.paddingLeft;
			var currentLineBoxLeftBoundary:int = initialLineBoxLeftBoundary;
			var currentLineBoxRightBoundary:int = totalAvailableWidth;
			var currentLineBoxChildren : Array = [];
			
			function closeLineBox() : void
			{
				if (currentLineBoxHeight)
				{
					currentLineBoxTop += currentLineBoxHeight + collapsibleMargin;
					collapsibleMargin = 0;
					currentLineBoxHeight = 0;
					currentLineBoxLeftBoundary = initialLineBoxLeftBoundary;
					currentLineBoxRightBoundary = totalAvailableWidth;
					currentLineBoxChildren = [];
				}
			}
			
			var i : int;
			for (i = 0; i < childCount; i++)
			{
				var child:UIComponent = children[i] as UIComponent;
				//only deal with children that derive from UIComponent
				if (!child || !child.isRendered())
				{
					continue;
				}
				
				var childStyle : ComputedStyles = child.style;
				
				//apply horizontal position
				if (childStyle.float)
				{
					if (collapsibleMargin)
					{
						currentLineBoxTop += collapsibleMargin;
						collapsibleMargin = 0;
					}
					var childWidth:int = child.borderBoxWidth + 
						childStyle.marginLeft + childStyle.marginRight;
					if (childWidth > currentLineBoxRightBoundary - 
						currentLineBoxLeftBoundary)
					{
						if (currentLineBoxChildren.length)
						{
							applyVerticalPositionsInLineBox(
								currentLineBoxTop, currentLineBoxHeight, 
								currentLineBoxChildren);
						}
						closeLineBox();
					}
					if (childStyle.float == 'left')
					{
						child.x = 
							currentLineBoxLeftBoundary + childStyle.marginLeft;
						currentLineBoxLeftBoundary = child.x + 
							child.outerWidth + childStyle.marginRight;
					}
					else if (childStyle.float == 'right')
					{
						child.x = currentLineBoxRightBoundary - 
							child.outerWidth - childStyle.marginRight;
						currentLineBoxRightBoundary = 
							child.x - childStyle.marginLeft;
					}
					currentLineBoxHeight = Math.max(currentLineBoxHeight, 
						child.outerHeight + 
						childStyle.collapsedMarginTop + childStyle.collapsedMarginBottom);
					var childVAlign : String = 
						childStyle.verticalAlign || 'top';
					if (childVAlign != 'top')
					{
						currentLineBoxChildren.push(child);
					}
				}
				else if (child.positionInFlow || 
					(child.autoFlags.left && child.autoFlags.right))
				{
					if (child.autoFlags.marginLeft)
					{
						if (child.autoFlags.marginRight)
						{
							//center horizontally
							child.x = Math.round(totalAvailableWidth / 2 - 
								child.outerWidth / 2);
						}
						else
						{
							//align right
							child.x = totalAvailableWidth - child.outerWidth - 
								childStyle.marginRight - elementStyle.paddingRight;
						}
					}
					else
					{
						//align left
						child.x = childStyle.marginLeft + elementStyle.paddingLeft;
					}
				}
				widestChildWidth = Math.max(child.x + 
					child.outerWidth + childStyle.marginRight, 
					widestChildWidth);
				
				//apply vertical position including margin collapsing
				if (child.positionInFlow)
				{
					closeLineBox();
					var childMarginTop:int = childStyle.collapsedMarginTop;
					var collapsedMargin:int;
					if (collapsibleMargin >= 0 && childMarginTop >= 0)
					{
						collapsedMargin = 
							Math.max(collapsibleMargin, childMarginTop);
					}
					else if (collapsibleMargin >= 0 && childMarginTop < 0 ||
						collapsibleMargin < 0 && childMarginTop >= 0)
					{
						collapsedMargin = collapsibleMargin + childMarginTop;
					}
					else
					{
						collapsedMargin = 
							Math.min(collapsibleMargin, childMarginTop);
					}
					
					if (topMarginCollapsible)
					{
						elementStyle.collapsedMarginTop = collapsedMargin;
						collapsedMargin = 0;
						topMarginCollapsible = false;
					}
					child.y = currentLineBoxTop + collapsedMargin;
					
					//collapse margins through empty elements 
					if (!child.outerHeight)
					{
						collapsibleMargin = Math.max(collapsedMargin, 
							childStyle.collapsedMarginBottom);
					}
					else
					{
						collapsibleMargin = childStyle.collapsedMarginBottom;
						topMarginCollapsible = false;
						currentLineBoxTop = child.y + child.outerHeight;
					}
				}
				else
				{
					if (childStyle.float || 
						(child.autoFlags.top && child.autoFlags.bottom))
					{
						if (!childStyle.float)
						{
							closeLineBox();
						}
						child.y = currentLineBoxTop + 
							//ignore the upper outer margin
							(topMarginCollapsible ? 0 : collapsibleMargin) + 
							childStyle.marginTop;
					}
				}
				//add to displaystack for later sorting
				var depthStackEntry : Object = 
				{
					element : child, 
					index : i, 
					zIndex : childStyle.zIndex || 0
				};
				depthStackEntry.zIndex > 0 && depthStackEntry.zIndex++;
				m_displayStack.push(depthStackEntry);
			}
			if (collapsibleMargin && !elementStyle.borderBottomWidth && 
				!elementStyle.paddingBottom && element.positionInFlow)
			{
				elementStyle.collapsedMarginBottom = 
					Math.max(elementStyle.marginBottom, collapsibleMargin);
				collapsibleMargin = 0;
			}
			
			if (currentLineBoxChildren.length)
			{
				applyVerticalPositionsInLineBox(
					currentLineBoxTop, currentLineBoxHeight, currentLineBoxChildren);
			}
			elementStyle.intrinsicHeight = Math.max(currentLineBoxTop + currentLineBoxHeight + 
				collapsibleMargin - elementStyle.paddingTop, 0);
			elementStyle.intrinsicWidth = 
				Math.max(widestChildWidth - elementStyle.paddingLeft, 0);
		}
		
		public function applyAbsolutePositions(
			element : UIComponent, children : Array) : void
		{
			var childCount : int = children.length;
			for (var i:int = 0; i < childCount; i++)
			{
				var child:UIComponent = children[i] as UIComponent;
				if (!child || !child.isRendered())
				{
					//only deal with children that derive from UIComponent
					continue;
				}
				var childStyle : ComputedStyles = child.style;
				if (!child.positionInFlow && !childStyle.float)
				{
					var absolutePosition:Point = 
						child.getPositionRelativeToContext(child.containingBlock);
					absolutePosition.x -= child.x;
					absolutePosition.y -= child.y;
					
					if (!child.autoFlags.left)
					{
						if (!child.autoFlags.right && 
							child.autoFlags.marginLeft && child.autoFlags.marginRight)
						{
							//center horizontally if margin-left and margin-right 
							//are both auto and left and right have values.
							child.x = childStyle.left + Math.round((
								child.containingBlock.paddingBoxWidth - 
								childStyle.right - childStyle.left) / 2 - 
								child.borderBoxWidth /2);
						}
						else
						{
							child.x = childStyle.left + 
								childStyle.marginLeft - absolutePosition.x;
						}
					}
					else if (!child.autoFlags.right)
					{
						child.x = child.containingBlock.paddingBoxWidth - 
							child.borderBoxWidth -  
							childStyle.right - childStyle.marginRight - 
							absolutePosition.x;
					}
					
					if (!child.autoFlags.top)
					{
						if (!child.autoFlags.bottom && 
							child.autoFlags.marginTop && child.autoFlags.marginBottom)
						{
							//center vertically if margin-top and margin-bottom 
							//are both auto and top and bottom have values.
							child.y = childStyle.top + Math.round((
								child.containingBlock.paddingBoxHeight - 
								childStyle.bottom - childStyle.top) / 2 - 
								child.borderBoxHeight /2);
						}
						else
						{
							child.y = childStyle.top + 
								childStyle.marginTop - absolutePosition.y;
						}
					}
					else if (!child.autoFlags.bottom)
					{
						child.y = child.containingBlock.paddingBoxHeight - 
							child.borderBoxHeight - 
							childStyle.bottom - childStyle.marginBottom - 
							absolutePosition.y;
					}
				}
			}
		}
		public function applyDepthSorting(
			lowerContainer : Sprite, upperContainer : Sprite) : void
		{
			if (!m_displayStack || !m_displayStack.length)
			{
				return;
			}
			var inPositiveRange:Boolean = false;
			var currentDepth:int = 0;
			
			//sort children by zIndex and declaration index
			m_displayStack.sortOn(['zIndex', 'index'], Array.NUMERIC);
			for (var i : int = 0; i < m_displayStack.length; i++)
			{
				var element : DisplayObject = m_displayStack[i].element;
				var zIndex : int = m_displayStack[i].zIndex;
				
				if (!inPositiveRange && zIndex >= 0)
				{
					inPositiveRange = true;
					currentDepth = 0;
				}
				
				// reparent elements depending on their z-index
				if (!inPositiveRange && element.parent != lowerContainer)
				{
					lowerContainer.addChildAt(element, currentDepth);
				}
				else if (inPositiveRange && element.parent != upperContainer)
				{
					upperContainer.addChildAt(element, currentDepth);
				}
				else
				{
					element.parent.setChildIndex(element, currentDepth);
				}
				currentDepth++;
			}
			m_displayStack = null;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function applyVerticalPositionsInLineBox(
			lineBoxTop : int, lineBoxHeight : int, lineBoxChildren : Array) : void
		{
			var i : int = lineBoxChildren.length;
			while (i--)
			{
				var child : UIComponent = lineBoxChildren[i];
				switch (child.style.verticalAlign)
				{
					case 'middle':
					{
						child.y = lineBoxTop + Math.round(
							lineBoxHeight / 2 - (child.outerHeight + 
							child.style.collapsedMarginTop + child.style.collapsedMarginBottom) / 2);
						break;
					}
					case 'bottom':
					case 'baseline':
					{
						child.y = lineBoxTop + Math.round(
							lineBoxHeight - (child.outerHeight + 
							child.style.collapsedMarginTop + child.style.collapsedMarginBottom));
						break;
					}
					default:
				}
			}
		}
	}
}