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
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import reprise.ui.UIComponent;		

	/**
	 * @author till
	 */
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
			
			m_displayStack = [];
			
			var widestChildWidth:Number = 0;
			var collapsibleMargin:Number = 0;
			var topMarginCollapsible:Boolean = !element.style.borderTopWidth && 
				!element.style.paddingTop && element.positionInFlow;
			if (topMarginCollapsible)
			{
				collapsibleMargin = element.style.marginTop;
			}
			var totalAvailableWidth:Number = element.innerWidth();
			var currentLineBoxTop:Number = element.style.paddingTop;
			var currentLineBoxHeight:Number = 0;
			var currentLineBoxLeftBoundary:Number = element.style.paddingLeft;
			var currentLineBoxRightBoundary:Number = totalAvailableWidth;
			var currentLineBoxChildren : Array = [];
			
			function closeLineBox() : void
			{
				if (currentLineBoxHeight)
				{
					currentLineBoxTop += currentLineBoxHeight + collapsibleMargin;
					collapsibleMargin = 0;
					currentLineBoxHeight = 0;
					currentLineBoxLeftBoundary = element.style.paddingLeft;
					currentLineBoxRightBoundary = totalAvailableWidth;
					currentLineBoxChildren = [];
				}
			}
			
			var i : int;
			for (i = 0; i < childCount; i++)
			{
				var child:UIComponent = children[i] as UIComponent;
				//only deal with children that derive from UIComponent
				if (!child || !child.isDisplayed())
				{
					continue;
				}
				
				//apply horizontal position
				if (child.style.float)
				{
					if (collapsibleMargin)
					{
						currentLineBoxTop += collapsibleMargin;
						collapsibleMargin = 0;
					}
					var childWidth:Number = child.borderBoxWidth + 
						child.style.marginLeft + child.style.marginRight;
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
					if (child.style.float == 'left')
					{
						child.x = 
							currentLineBoxLeftBoundary + child.style.marginLeft;
						currentLineBoxLeftBoundary = child.x + 
							child.outerWidth + child.style.marginRight;
					}
					else if (child.style.float == 'right')
					{
						child.x = currentLineBoxRightBoundary - 
							child.outerWidth - child.style.marginRight;
						currentLineBoxRightBoundary = 
							child.x - child.style.marginLeft;
					}
					currentLineBoxHeight = Math.max(currentLineBoxHeight, 
						child.outerHeight + 
						child.style.marginTop + child.style.marginBottom);
					var childVAlign : String = 
						child.style.verticalAlign || 'top';
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
								child.style.marginRight - element.style.paddingRight;
						}
					}
					else
					{
						//align left
						child.x = child.style.marginLeft + element.style.paddingLeft;
					}
				}
				widestChildWidth = Math.max(child.x + 
					child.outerWidth + child.style.marginRight, 
					widestChildWidth);
				
				//apply vertical position including margin collapsing
				if (child.positionInFlow)
				{
					closeLineBox();
					var childMarginTop:Number = child.style.marginTop;
					var collapsedMargin:Number;
					if (collapsibleMargin >= 0 && childMarginTop >= 0)
					{
						collapsedMargin = 
							Math.max(collapsibleMargin, childMarginTop);
					}
					else if (collapsibleMargin >= 0 && childMarginTop < 0)
					{
						collapsedMargin = collapsibleMargin + childMarginTop;
					}
					else if (collapsibleMargin < 0 && childMarginTop >= 0)
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
						//TODO: wont work
						element.style.marginTop = collapsedMargin;
						collapsedMargin = 0;
						topMarginCollapsible = false;
					}
					child.y = currentLineBoxTop + collapsedMargin;
					
					//collapse margins through empty elements 
					if (!child.outerHeight)
					{
						collapsibleMargin = 
							Math.max(collapsedMargin, child.style.marginBottom);
					}
					else
					{
						collapsibleMargin = child.style.marginBottom;
						topMarginCollapsible = false;
						currentLineBoxTop = child.y + child.outerHeight;
					}
				}
				else
				{
					if (child.style.float || 
						(child.autoFlags.top && child.autoFlags.bottom))
					{
						if (!child.style.float)
						{
							closeLineBox();
						}
						child.y = currentLineBoxTop + child.style.marginTop;
					}
				}
				//add to displaystack for later sorting
				var depthStackEntry : Object = 
				{
					element : child, 
					index : i, 
					zIndex : child.style.zIndex || 0
				};
				depthStackEntry.zIndex > 0 && depthStackEntry.zIndex++;
				m_displayStack.push(depthStackEntry);
			}
			if (collapsibleMargin && !element.style.borderBottomWidth && 
				!element.style.paddingBottom && element.positionInFlow)
			{
				element.style.marginBottom = 
					Math.max(element.style.marginBottom, collapsibleMargin);
				collapsibleMargin = 0;
			}
			
			if (currentLineBoxChildren.length)
			{
				applyVerticalPositionsInLineBox(
					currentLineBoxTop, currentLineBoxHeight, currentLineBoxChildren);
			}
			element.style.intrinsicHeight = currentLineBoxTop + currentLineBoxHeight + 
				collapsibleMargin - element.style.paddingTop;
			element.style.intrinsicWidth = widestChildWidth - element.style.paddingLeft;
		}
		
		public function applyAbsolutePositions(
			element : UIComponent, children : Array) : void
		{
			var childCount : int = children.length;
			for (var i:Number = 0; i < childCount; i++)
			{
				var child:UIComponent = children[i] as UIComponent;
				if (!child || !child.isDisplayed())
				{
					//only deal with children that derive from UIComponent
					continue;
				}
				if (!child.positionInFlow && !child.style.float)
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
							child.x = child.style.left + Math.round((
								child.containingBlock.paddingBoxWidth - 
								child.style.right - child.style.left) / 2 - 
								child.borderBoxWidth /2);
						}
						else
						{
							child.x = child.style.left + 
								child.style.marginLeft - absolutePosition.x;
						}
					}
					else if (!child.autoFlags.right)
					{
						child.x = child.containingBlock.paddingBoxWidth - 
							child.borderBoxWidth -  
							child.style.right - child.style.marginRight - 
							absolutePosition.x;
					}
					
					if (!child.autoFlags.top)
					{
						if (!child.autoFlags.bottom && 
							child.autoFlags.marginTop && child.autoFlags.marginBottom)
						{
							//center vertically if margin-top and margin-bottom 
							//are both auto and top and bottom have values.
							child.y = child.style.top + Math.round((
								child.containingBlock.paddingBoxHeight - 
								child.style.bottom - child.style.top) / 2 - 
								child.borderBoxHeight /2);
						}
						else
						{
							child.y = child.style.top + 
								child.style.marginTop - absolutePosition.y;
						}
					}
					else if (!child.autoFlags.bottom)
					{
						child.y = child.containingBlock.paddingBoxHeight - 
							child.borderBoxHeight - 
							child.style.bottom - child.style.marginBottom - 
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
				var zIndex : Number = m_displayStack[i].zIndex;
				
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
			lineBoxTop : Number, lineBoxHeight : Number, lineBoxChildren : Array) : void
		{
			var i : Number = lineBoxChildren.length;
			while (i--)
			{
				var child : UIComponent = lineBoxChildren[i];
				switch (child.style.verticalAlign)
				{
					case 'middle':
					{
						child.y = lineBoxTop + Math.round(
							lineBoxHeight / 2 - (child.outerHeight + 
							child.style.marginTop + child.style.marginBottom) / 2);
						break;
					}
					case 'bottom':
					case 'baseline':
					{
						child.y = lineBoxTop + Math.round(
							lineBoxHeight - (child.outerHeight + 
							child.style.marginTop + child.style.marginBottom));
						break;
					}
					default:
				}
			}
		}
	}
}