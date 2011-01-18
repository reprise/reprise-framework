/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.ui.layoutmanagers
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;

	import reprise.ui.UIComponent;

	public interface ILayoutManager
	{
		function applyFlowPositions(element : UIComponent, children : Array) : void;
		function applyAbsolutePositions(element : UIComponent, children : Array) : void;
		function applyDepthSorting(lowerContainer : DisplayObjectContainer,
		                           upperContainer : DisplayObjectContainer) : void;
	}
}