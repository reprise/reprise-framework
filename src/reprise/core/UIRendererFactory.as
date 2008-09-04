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

package reprise.core
{ 
	import reprise.ui.UIComponent;
	import reprise.ui.renderers.AbstractTooltip;
	import reprise.ui.renderers.DefaultBackgroundRenderer;
	import reprise.ui.renderers.DefaultBorderRenderer;
	import reprise.ui.renderers.DefaultTooltipRenderer;
	import reprise.ui.renderers.ICSSRenderer;
	
	public class UIRendererFactory 
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var TEXTNODE_TAGS : String = "span,br,strong,null,";
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_idHandlers : Object;
		protected var m_classHandlers : Object;
		protected var m_tagHandlers : Object;
		
		protected var m_borderRenderers : Object;
		protected var m_backgroundRenderers : Object;
		protected var m_tooltipRenderers : Object;
		protected var m_defaultBorderRenderer : Class;
		protected var m_defaultBackgroundRenderer : Class;
		protected var m_defaultTooltipRenderer : Class;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function UIRendererFactory()
		{
			m_idHandlers = {};
			m_classHandlers = {};
			m_tagHandlers = {};
			m_borderRenderers = {};
			m_backgroundRenderers = {};
			m_tooltipRenderers = {};
			m_defaultBorderRenderer = DefaultBorderRenderer;
			m_defaultBackgroundRenderer = DefaultBackgroundRenderer;
			m_defaultTooltipRenderer = DefaultTooltipRenderer;
		}
		/**
		 * registers an id handler
		 */
		public function registerIdRenderer(
			id : String, handler : Class) : void
		{
			m_idHandlers[id.toLowerCase()] = handler;
		}
		/**
		 * registers a class handler
		 */
		public function registerClassRenderer(
			className : String, handler : Class) : void
		{
			className = className.toLowerCase();
			m_classHandlers[className.toLowerCase()] = handler;
		}
		/**
		 * registers a tag handler
		 */
		public function registerTagRenderer(
			tagName : String, handler : Class) : void
		{
			m_tagHandlers[tagName.toLowerCase()] = handler;
		}
		
		/**
		* registers a border renderer
		**/
		public function registerBorderRenderer(id : String, renderer : Class) : void
		{
			m_borderRenderers[id.toLowerCase()] = renderer;
		}
		
		/**
		* registers a background renderer
		**/
		public function registerBackgroundRenderer(id : String, renderer : Class) : void
		{
			m_backgroundRenderers[id.toLowerCase()] = renderer;
		}
		
		public function registerTooltipRenderer(id : String, renderer : Class) : void
		{
			m_tooltipRenderers[id.toLowerCase()] = renderer;
		}
		
		public function registerDefaultBorderRenderer(renderer : Class) : void
		{
			m_defaultBorderRenderer = renderer;
		}
		
		public function registerDefaultBackgroundRenderer(renderer : Class) : void
		{
			m_defaultBackgroundRenderer = renderer;
		}
		
		public function registerDefaultTooltipRenderer(renderer : Class) : void
		{
			m_defaultTooltipRenderer = renderer;
		}
		
		/**
		 * returns a child class of UIComponent based on the handlers
		 * registered with this factory and the given node definition
		 */
		public function rendererByNode(node : XML) : UIComponent
		{
			var renderer:UIComponent;
			//check if the node is a text node.
			//If so, tread it as a <p> node without any classes or an id.
			if (node.nodeKind() == 'text')
			{
				return rendererByTag("p");
			}
			//check if the node has an id and there's a renderer registered for
			//this id. If so, create an instance of the renderer and return it.
			var nodeId:String;
			var idProps : XMLList = node.@id;
			if (idProps.length())
			{
				nodeId = XML(idProps[0]).toString();
				if (nodeId)
				{
					renderer = rendererById(nodeId);
					if (renderer)
					{
						return renderer;
					}
				}
			}
			
			//check for renderers for all of the classes of the node.
			//Return an instance of the renderer if one is found.
			var classProps : XMLList = node.@['class'];
			if (classProps.length())
			{
				var classesString:String = classProps[0];
				if (classesString)
				{
					var classes:Array = classesString.split(' ');
					for (var i : Number = classes.length; i--;)
					{
						var className:String = String(classes[i]);
						renderer = rendererByClass(className);
						if (renderer)
						{
							return renderer;
						}
					}
				}
			}
			
			//check for a renderer for the nodes' tag.
			//Return an instance of the renderer if one is found.
			renderer = rendererByTag(node.localName());
			return renderer;
		}
		
		
		/**
		 * returns the Function that's been registered 
		 * as the handler for the given id
		 */
		public function rendererById(id : String) : UIComponent
		{
			var idHandler : Class = m_idHandlers[id.toLowerCase()];
			if (!idHandler)
			{
				return null;
			}
			return UIComponent(new idHandler());
		}
		/**
		 * returns the Function that's been registered 
		 * as the handler for the given class
		 */
		public function rendererByClass(className : String) : UIComponent
		{
			var classHandler : Class = m_classHandlers[className.toLowerCase()];
			if (!classHandler)
			{
				return null;
			}
			return UIComponent(new classHandler());
		}
		/**
		 * returns the Function that's been registered 
		 * as the handler for the given tag
		 */
		public function rendererByTag(tagName : String) : UIComponent
		{
			var tagHandler : Class = m_tagHandlers[tagName.toLowerCase()];
			if (!tagHandler)
			{
				return null;
			}
			return UIComponent(new tagHandler());
		}
		
		/**
		* returns a new borderrenderer for a given id
		**/
		public function borderRendererById(id : String) : ICSSRenderer
		{
			var rendererClass : Class = m_borderRenderers[(id || '').toLowerCase()];
			if (rendererClass == null)
			{
				rendererClass = m_defaultBorderRenderer;
			}
			var renderer:ICSSRenderer = new rendererClass();
			renderer.setId(id);
			return renderer;
		}
		
		/**
		* returns a new backgroundrenderer for a given id
		**/
		public function backgroundRendererById(id : String) : ICSSRenderer
		{
			var rendererClass:Class = m_backgroundRenderers[(id || '').toLowerCase()];
			if (rendererClass == null)
			{
				rendererClass = m_defaultBackgroundRenderer;
			}
			var renderer:ICSSRenderer = new rendererClass();
			renderer.setId(id);
			return renderer;
		}
		
		public function tooltipRendererById(id : String) : AbstractTooltip
		{
			if (id == null)
			{
				return new m_defaultTooltipRenderer();
			}
			var renderer:Class = m_tooltipRenderers[id.toLowerCase()];
			if (renderer == null)
			{
				renderer = m_defaultTooltipRenderer;
			}
			return new renderer();
		}
	}
}