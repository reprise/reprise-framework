/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.core
{
	import reprise.controls.Label;
	import reprise.controls.html.Image;
	import reprise.ui.UIComponent;
	import reprise.ui.renderers.AbstractTooltip;
	import reprise.ui.renderers.DefaultBackgroundRenderer;
	import reprise.ui.renderers.DefaultBorderRenderer;
	import reprise.ui.renderers.DefaultTooltipRenderer;
	import reprise.ui.renderers.ICSSRenderer;	

	public class UIRendererFactory 
	{
		//----------------------             Public Properties              ----------------------//
		public static var TEXTNODE_TAGS : String = "span,br,strong,i,null,";
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _idHandlers : Object;
		protected var _classHandlers : Object;
		protected var _tagHandlers : Object;
		protected var _inputTypeHandlers : Object;
		
		protected var _borderRenderers : Object;
		protected var _backgroundRenderers : Object;
		protected var _tooltipRenderers : Object;
		protected var _defaultBorderRenderer : Class;
		protected var _defaultBackgroundRenderer : Class;
		protected var _defaultTooltipRenderer : Class;

		
		//----------------------               Public Methods               ----------------------//
		public function UIRendererFactory()
		{
			_idHandlers = {};
			_classHandlers = {};
			_tagHandlers = {};
			_inputTypeHandlers = {};
			_borderRenderers = {};
			_backgroundRenderers = {};
			_tooltipRenderers = {};
			registerDefaultRenderers();
		}
		/**
		 * registers an id handler
		 */
		public function registerIdRenderer(
			id : String, handler : Class) : void
		{
			_idHandlers[id.toLowerCase()] = handler;
		}
		/**
		 * registers a class handler
		 */
		public function registerClassRenderer(
			className : String, handler : Class) : void
		{
			className = className.toLowerCase();
			_classHandlers[className.toLowerCase()] = handler;
		}
		/**
		 * registers a tag handler
		 */
		public function registerTagRenderer(
			tagName : String, handler : Class) : void
		{
			_tagHandlers[tagName.toLowerCase()] = handler;
		}
		/**
		 * registers an input type handler.
		 * 
		 * These handlers are used for rendering input elements, for example, you can 
		 * register a TextInput control for rendering elements like 
		 * &lt;input type='text'/&gt;
		 */
		public function registerInputTypeRenderer(
			type : String, handler : Class) : void
		{
			_inputTypeHandlers[type.toLowerCase()] = handler;
		}
		
		/**
		* registers a border renderer
		**/
		public function registerBorderRenderer(id : String, renderer : Class) : void
		{
			_borderRenderers[id.toLowerCase()] = renderer;
		}
		
		/**
		* registers a background renderer
		**/
		public function registerBackgroundRenderer(id : String, renderer : Class) : void
		{
			_backgroundRenderers[id.toLowerCase()] = renderer;
		}
		
		public function registerTooltipRenderer(id : String, renderer : Class) : void
		{
			_tooltipRenderers[id.toLowerCase()] = renderer;
		}
		
		public function registerDefaultBorderRenderer(renderer : Class) : void
		{
			_defaultBorderRenderer = renderer;
		}
		
		public function registerDefaultBackgroundRenderer(renderer : Class) : void
		{
			_defaultBackgroundRenderer = renderer;
		}
		
		public function registerDefaultTooltipRenderer(renderer : Class) : void
		{
			_defaultTooltipRenderer = renderer;
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
			var nodeId:String = node.@id.toString();
			if (nodeId)
			{
				renderer = rendererById(nodeId);
				if (renderer)
				{
					return renderer;
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
					for (var i : int = classes.length; i--;)
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
			
			var tag : String = node.localName() as String;
			
			//check for an input type renderer if we're dealing with an input node
			if (tag == 'input')
			{
				renderer = rendererByInputType(node.@type[0]);
				if (renderer)
				{
					return renderer;
				}
			}
			
			//check for a renderer for the nodes' tag.
			//Return an instance of the renderer if one is found.
			renderer = rendererByTag(tag);
			return renderer;
		}
		
		
		/**
		 * returns the Function that's been registered 
		 * as the handler for the given id
		 */
		public function rendererById(id : String) : UIComponent
		{
			var idHandler : Class = _idHandlers[id.toLowerCase()];
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
			var classHandler : Class = _classHandlers[className.toLowerCase()];
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
			var tagHandler : Class = _tagHandlers[tagName.toLowerCase()];
			if (!tagHandler)
			{
				return null;
			}
			return UIComponent(new tagHandler());
		}
		/**
		 * returns the Function that's been registered 
		 * as the handler for the given tag
		 */
		public function rendererByInputType(type : String) : UIComponent
		{
			var inputTypeHandler : Class = _inputTypeHandlers[type.toLowerCase()];
			if (!inputTypeHandler)
			{
				return null;
			}
			return UIComponent(new inputTypeHandler());
		}
		
		/**
		* returns a new borderrenderer for a given id
		**/
		public function borderRendererById(id : String) : ICSSRenderer
		{
			var rendererClass : Class = _borderRenderers[(id || '').toLowerCase()];
			if (rendererClass == null)
			{
				rendererClass = _defaultBorderRenderer;
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
			var rendererClass:Class = _backgroundRenderers[(id || '').toLowerCase()];
			if (rendererClass == null)
			{
				rendererClass = _defaultBackgroundRenderer;
			}
			var renderer:ICSSRenderer = new rendererClass();
			renderer.setId(id);
			return renderer;
		}
		
		public function tooltipRendererById(id : String) : AbstractTooltip
		{
			if (id == null)
			{
				return new _defaultTooltipRenderer();
			}
			var renderer:Class = _tooltipRenderers[id.toLowerCase()];
			if (renderer == null)
			{
				renderer = _defaultTooltipRenderer;
			}
			return new renderer();
		}
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected function registerDefaultRenderers() : Boolean
		{
			_defaultBorderRenderer = DefaultBorderRenderer;
			_defaultBackgroundRenderer = DefaultBackgroundRenderer;
			_defaultTooltipRenderer = DefaultTooltipRenderer;
			
			registerTagRenderer('p', Label);
			registerTagRenderer('h1', Label);
			registerTagRenderer('h2', Label);
			registerTagRenderer('h3', Label);
			registerTagRenderer('h4', Label);
			registerTagRenderer('h5', Label);
			registerTagRenderer('h6', Label);
			registerTagRenderer('div', UIComponent);
			registerTagRenderer('hr', UIComponent);
			registerTagRenderer('img', Image);
			
			return true;
		}
	}
}