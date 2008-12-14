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

package reprise.ui.renderers
{
	import reprise.commands.CompositeCommand;	
	import reprise.commands.MovieClipController;	
	
	import flash.display.MovieClip; 
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import reprise.css.CSSProperty;
	import reprise.css.propertyparsers.Background;
	import reprise.css.propertyparsers.Filters;
	import reprise.data.AdvancedColor;
	import reprise.events.ResourceEvent;
	import reprise.external.AbstractResource;
	import reprise.external.BitmapResource;
	import reprise.external.ImageResource;
	import reprise.utils.GfxUtil;
	import reprise.utils.Gradient;
	public class DefaultBackgroundRenderer extends AbstractCSSRenderer
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_backgroundImageContainer : Sprite;
		protected var m_activeBackgroundAnimationContainer : Sprite;
		protected var m_inactiveBackgroundAnimationContainer : Sprite;
		protected var m_backgroundMask : Sprite;
		
		protected var m_backgroundImage : BitmapData = null;
		protected var m_backgroundImageLoader : AbstractResource;
		
		protected var m_lastBackgroundImageType : String;
		protected var m_lastBackgroundImageURL : String;
		protected var m_animationControls : CompositeCommand;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function DefaultBackgroundRenderer() {}
	
		
		public override function draw() : void
		{
			var hasAnyContent:Boolean = false;
			
			var color:AdvancedColor = m_styles.backgroundColor;
			var hasBackgroundGradient:Boolean = (m_styles.backgroundGradientType == 
				Background.GRADIENT_TYPE_LINEAR || m_styles.backgroundGradientType == 
				Background.GRADIENT_TYPE_RADIAL) && m_styles.backgroundGradientColors;
			
			//TODO: investigate optimization strategies to prevent unneeded redraws
			//clear background
			m_display.graphics.clear();
			
			// draw plain background color
			if (color != null && color.alpha() >= 0 && !hasBackgroundGradient)
			{
				hasAnyContent = true;
				m_display.graphics.beginFill(color.rgb(), color.opacity());
				GfxUtil.drawRect(m_display, 0, 0, m_width, m_height);
				m_display.graphics.endFill();
			}
			// draw background gradient
			else if (hasBackgroundGradient)
			{
				hasAnyContent = true;
				var grad : Gradient = new Gradient(m_styles.backgroundGradientType);
				grad.setColors(m_styles.backgroundGradientColors);
				if (m_styles.backgroundGradientRatios)
				{
					grad.setRatios(m_styles.backgroundGradientRatios);
				}
				if (m_styles.backgroundGradientRotation != null)
				{
					grad.setRotation(m_styles.backgroundGradientRotation);
				}
				
				grad.beginGradientFill(m_display.graphics, m_width, m_height);
				GfxUtil.drawRect(m_display, 0, 0, m_width, m_height);
				m_display.graphics.endFill();
			}
			
			// load a background image
			if (m_styles.backgroundImage != null && 
				m_styles.backgroundImage != Background.IMAGE_NONE)
			{
				hasAnyContent = true;
				loadBackgroundImage();
			}
			// stop any loading of prior background images
			else
			{
				if (m_backgroundImageLoader && m_backgroundImageLoader.isExecuting())
				{
					m_backgroundImageLoader.cancel();
				}
				clearBackgroundImage();	
			}
				
			// apply dropshadow
			if (m_styles.backgroundShadowColor != null)
			{
				hasAnyContent = true;
				var dropShadow : DropShadowFilter = Filters.
					dropShadowFilterFromStyleObjectForName(m_styles, 'background');
				m_display.filters = [dropShadow];
			}
			
			// draw mask if neccessary
			if (hasAnyContent)
			{
				drawBackgroundMask();
			}
			else
			{
				m_display.mask = null;
			}
		}
		
		public override function destroy() : void
		{
			m_backgroundImageLoader && m_backgroundImageLoader.cancel();
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function clearBackgroundImage() : void
		{
			if (m_backgroundImageContainer != null)
			{
				//TODO: find out parent and call directly
				m_backgroundImageContainer.parent.removeChild(m_backgroundImageContainer);
				m_backgroundImageContainer = null;
				m_activeBackgroundAnimationContainer = null;
				m_inactiveBackgroundAnimationContainer = null;
			}
			if (m_backgroundImage != null)
			{
				m_backgroundImage.dispose();
				m_backgroundImage = null;
			}
		}
		
		protected function loadBackgroundImage() : void
		{
			if (!m_styles.backgroundImageType || 
				m_styles.backgroundImageType != 'animation')
			{
				// cancel background animation loader since we don't need it
				if (m_backgroundImageLoader && m_backgroundImageLoader is ImageResource && 
					m_backgroundImageLoader.isExecuting())
				{
					m_backgroundImageLoader.cancel();
				}
				
				// if we're already loading the right bitmap, do nothing			
				if (m_backgroundImageLoader && 
					m_backgroundImageLoader is BitmapResource && 
					m_backgroundImageLoader.url() == m_styles.backgroundImage)
				{
					if (!m_backgroundImageLoader.isExecuting())
					{
						// we force redrawing here, due to the fact that our size or 
						// the image position could have changed
						//TODO: verify that this really calls bitmapLoader_complete
						m_backgroundImageLoader.dispatchEvent(
							new ResourceEvent(Event.COMPLETE, true));
					}
					return;
				}
				
				if (m_backgroundImageLoader && m_backgroundImageLoader.isExecuting())
				{
					m_backgroundImageLoader.cancel();
				}
				
				m_backgroundImageLoader = new BitmapResource();
				m_backgroundImageLoader.setURL(m_styles.backgroundImage);
				BitmapResource(m_backgroundImageLoader).setCacheBitmap(true);
				BitmapResource(m_backgroundImageLoader).setCloneBitmap(false);
				m_backgroundImageLoader.addEventListener(
					Event.COMPLETE, bitmapLoader_complete);
				m_backgroundImageLoader.execute();
				return;
			}
			
			// if we're loading a background image, cancel it, since we don't need it
			if (m_backgroundImageLoader && m_backgroundImageLoader.isExecuting() && 
				m_backgroundImageLoader is BitmapResource)
			{
				m_backgroundImageLoader.cancel();
				m_backgroundImageLoader.removeEventListener(
					Event.COMPLETE, bitmapLoader_complete);
				m_backgroundImageLoader = null;
			}
			
			// if we're already loading the right animation, do nothing
			if (m_backgroundImageLoader && 
				m_backgroundImageLoader.url() == m_styles.backgroundImage && 
				m_backgroundImageLoader is ImageResource)
			{
				if (!m_backgroundImageLoader.isExecuting())
				{
					// we force redrawing here, due to the fact that our size or 
					// the image position could have changed
					//TODO: verify that this really calls imageLoader_complete
					m_backgroundImageLoader.dispatchEvent(
						new ResourceEvent(Event.COMPLETE, true));
				}
				return;
			}
			
			if (!m_backgroundImageContainer)
			{
				m_backgroundImageContainer = Sprite(m_display.addChildAt(
					new Sprite(), 0));
				m_backgroundImageContainer.name = 'm_backgroundImageContainer';
			}
			
			m_inactiveBackgroundAnimationContainer = m_activeBackgroundAnimationContainer;
			m_activeBackgroundAnimationContainer = Sprite(
				m_backgroundImageContainer.addChild(new Sprite()));
			m_activeBackgroundAnimationContainer.name = 'm_backgroundAnimation';
	
			m_backgroundImageLoader = new ImageResource();
			m_backgroundImageLoader.setURL(m_styles.backgroundImage);
			m_backgroundImageLoader.addEventListener(
				Event.COMPLETE, imageLoader_complete);
			m_backgroundImageLoader.execute();
		}
		
		protected function drawBackgroundMask() : void
		{
			var radii : Array = [];
			var hasRoundBorder : Boolean = false;
			var order : Array = ['borderTopLeftRadius', 'borderTopRightRadius', 
				'borderBottomRightRadius', 'borderBottomLeftRadius'];
			
			var borderTopWidthHalf : Number = (m_styles['borderTopWidth'] || 0) / 2;
			var i : Number;
			var radiusItem : Number;
			for (i = 0; i < order.length; i++)
			{
				if (!(m_styles[order[i]] is Number))
				{
					radiusItem = 0;
				}
				else
				{
					radiusItem = m_styles[order[i]];
				}
				if (radiusItem != 0)
				{
					radiusItem += borderTopWidthHalf;
					hasRoundBorder = true;
				}
				radii.push(radiusItem);
			}
	
			if (!hasRoundBorder)
			{
				m_display.mask = null;
				GfxUtil.drawRect(m_display, 0, 0, m_width, m_height);
			}
			else
			{
				if (!m_backgroundMask)
				{
					m_backgroundMask = new Sprite();
					m_display.addChild(m_backgroundMask);
					m_backgroundMask.name = 'mask';
//					m_backgroundMask.visible = false;
				}
				m_display.mask = m_backgroundMask;
				m_backgroundMask.graphics.clear();
				m_backgroundMask.graphics.beginFill(0x00ffff, 20);
//				m_backgroundMask.graphics.lineStyle(
//					0, 0, 0.5, 
//					false, 'normal', 'square', 'miter', 2);
				GfxUtil.drawRoundRect(
					m_backgroundMask, 0, 0, m_width, m_height, radii);
			}
		}
		
		
		protected function bitmapLoader_complete(e : ResourceEvent) : void
		{
			clearBackgroundImage();
			
			if (!e.success || m_styles.backgroundImage == null || 
				m_styles.backgroundImage == Background.IMAGE_NONE)
			{
				return;
			}
			
			if (!m_backgroundImageLoader.content() is BitmapData)
			{
				return;
			}
			var newBackgroundImage : BitmapData = 
				BitmapData(m_backgroundImageLoader.content());
			var imgWidth : Number = newBackgroundImage.width;
			var imgHeight : Number = newBackgroundImage.height;
			// prevent infinite loops
			if (imgWidth < 1 || imgHeight < 1)
			{
				return;
			}
			
			if (!m_backgroundImageContainer)
			{
				m_backgroundImageContainer = Sprite(m_display.addChildAt(
					new Sprite(), 0));
				m_backgroundImageContainer.name = 'm_backgroundImageContainer';
			}
	
			
			var backgroundRepeat : String = m_styles.backgroundRepeat;
			var origin : Point = new Point(
				m_styles.backgroundPositionX | 0, m_styles.backgroundPositionY | 0);
			var xProperty : CSSProperty = 
				m_complexStyles.getStyle('backgroundPositionX');
			if (xProperty && xProperty.isRelativeValue())
			{
				origin.x = 
					Math.round(xProperty.resolveRelativeValueTo(m_width - imgWidth));
			}
			var yProperty : CSSProperty = 
				m_complexStyles.getStyle('backgroundPositionY');
			if (yProperty && yProperty.isRelativeValue())
			{
				origin.y = 
					Math.round(yProperty.resolveRelativeValueTo(m_height - imgHeight));
			}
	
			var scale9Rect : Rectangle = constructScale9Rect(imgWidth, imgHeight);
			if (scale9Rect != null)
			{
				if (m_styles.backgroundScale9Type == Background.SCALE9_TYPE_REPEAT)
				{
					drawScale9RepeatedBackground(newBackgroundImage, scale9Rect);
					return;
				}
					
				var scale9Bitmap : BitmapData = new BitmapData(m_width, m_height, true, 0);
				GfxUtil.scale9Bitmap(newBackgroundImage, scale9Bitmap, scale9Rect);
				backgroundRepeat = Background.REPEAT_NO_REPEAT;
				origin = new Point(0, 0);
				newBackgroundImage = scale9Bitmap;
				imgWidth = m_width;
				imgHeight = m_height;
			}
	
			
			var rect : Rectangle = new Rectangle(0, 0, m_width, m_height);
			var offset : Matrix = new Matrix();
			offset.translate(origin.x, origin.y);
					
			switch (backgroundRepeat)
			{
				case Background.REPEAT_REPEAT_XY:
				case undefined:
				{
					// we're all set
					break;
				}
				case Background.REPEAT_REPEAT_X:
				{
					rect.top = origin.y;
					rect.height = imgHeight;
					break;
				}
				case Background.REPEAT_REPEAT_Y:
				{
					rect.left = origin.x;
					rect.width = imgWidth;
					break;
				}
				case Background.REPEAT_NO_REPEAT:
				{
					rect.topLeft = origin;
					rect.size = new Point(imgWidth, imgHeight);
					break;
				}
			}
	
			rect.top = Math.max(0, rect.top);
			rect.left = Math.max(0, rect.left);
			rect.right = Math.min(m_width, rect.right);
			rect.bottom = Math.min(m_height, rect.bottom);
			
			var smooth:Boolean = m_styles.backgroundImageAliasing != 
				Background.IMAGE_ALIASING_ALIAS;
			m_backgroundImageContainer.graphics.beginBitmapFill(
				newBackgroundImage, offset, true, smooth);
			GfxUtil.drawRect(m_backgroundImageContainer, 
				rect.left, rect.top, rect.width, rect.height);
			m_backgroundImageContainer.graphics.endFill();
		}
		
		protected function drawScale9RepeatedBackground(sourceImage : BitmapData, 
			scale9Rect : Rectangle, repeat : Boolean = false) : void
		{
			var imgWidth : Number = sourceImage.width;
			var imgHeight : Number = sourceImage.height;
			
			var bitmaps : Object = GfxUtil.segmentedBitmapsOfScale9RectInRectWithSize(
				sourceImage, scale9Rect);
			var offset : Matrix = new Matrix();
			var smooth:Boolean = m_styles.backgroundImageAliasing != 
				Background.IMAGE_ALIASING_ALIAS;
			
			// TL
			offset.translate(0, 0);
			m_backgroundImageContainer.graphics.beginBitmapFill(
				bitmaps.tl, offset, false, smooth);
			GfxUtil.drawRect(m_backgroundImageContainer, 
				offset.tx, offset.ty, bitmaps.tl.width, bitmaps.tl.height);
			// T
			offset.tx = bitmaps.tl.width;
			offset.ty = 0;
			m_backgroundImageContainer.graphics.beginBitmapFill(
				bitmaps.t, offset, true, smooth);
			GfxUtil.drawRect(m_backgroundImageContainer, offset.tx, offset.ty, 
				m_width - bitmaps.tl.width - bitmaps.tr.width, bitmaps.t.height);
			// TR
			offset.tx = m_width - bitmaps.tr.width;
			offset.ty = 0;
			m_backgroundImageContainer.graphics.beginBitmapFill(
				bitmaps.tr, offset, false, smooth);
			GfxUtil.drawRect(m_backgroundImageContainer, offset.tx, offset.ty, 
				bitmaps.tr.width, bitmaps.tr.height);
			// R
			offset.tx = m_width - bitmaps.r.width;
			offset.ty = bitmaps.tr.height;
			m_backgroundImageContainer.graphics.beginBitmapFill(
				bitmaps.r, offset, true, smooth);
			GfxUtil.drawRect(m_backgroundImageContainer, offset.tx, offset.ty, 
				bitmaps.r.width, m_height - bitmaps.tr.height - bitmaps.br.height);
			// BR
			offset.tx = m_width - bitmaps.br.width;
			offset.ty = m_height - bitmaps.br.height;
			m_backgroundImageContainer.graphics.beginBitmapFill(
				bitmaps.br, offset, false, smooth);
			GfxUtil.drawRect(m_backgroundImageContainer, offset.tx, offset.ty, 
				bitmaps.br.width, bitmaps.br.height);
			// B
			offset.tx = bitmaps.bl.width;
			offset.ty = m_height - bitmaps.b.height;
			m_backgroundImageContainer.graphics.beginBitmapFill(
				bitmaps.b, offset, true, smooth);
			GfxUtil.drawRect(m_backgroundImageContainer, offset.tx, offset.ty, 
				m_width - bitmaps.bl.width - bitmaps.br.width, bitmaps.b.height);
			// BL
			offset.tx = 0;
			offset.ty = m_height - bitmaps.bl.height;
			m_backgroundImageContainer.graphics.beginBitmapFill(
				bitmaps.bl, offset, false, smooth);
			GfxUtil.drawRect(m_backgroundImageContainer, offset.tx, offset.ty, 
				bitmaps.bl.width, bitmaps.bl.height);
			// L
			offset.tx = 0;
			offset.ty = bitmaps.tl.height;
			m_backgroundImageContainer.graphics.beginBitmapFill(
				bitmaps.l, offset, true, smooth);
			GfxUtil.drawRect(m_backgroundImageContainer, offset.tx, offset.ty, 
				bitmaps.l.width, m_height - bitmaps.tl.height - bitmaps.bl.height);
			// C
			offset.tx = bitmaps.tl.width;
			offset.ty = bitmaps.tl.height;
			m_backgroundImageContainer.graphics.beginBitmapFill(
				bitmaps.c, offset, true, smooth);
			GfxUtil.drawRect(m_backgroundImageContainer, offset.tx, offset.ty, 
				m_width - bitmaps.l.width - bitmaps.r.width, 
				m_height - bitmaps.t.height - bitmaps.b.height);
			m_backgroundImageContainer.graphics.endFill();
		}
		
		protected function imageLoader_complete(e : ResourceEvent = null) : void
		{
			if (!e.success || m_styles.backgroundImage == null || 
				m_styles.backgroundImage == Background.IMAGE_NONE)
			{
				clearBackgroundImage();
				return;
			}
			
			if (m_inactiveBackgroundAnimationContainer)
			{
				m_inactiveBackgroundAnimationContainer.parent.removeChild(
					m_inactiveBackgroundAnimationContainer);
				m_inactiveBackgroundAnimationContainer = null;
			}
			
			var imgContainer : Sprite = m_activeBackgroundAnimationContainer;
			imgContainer.addChild(m_backgroundImageLoader.content());
			
			if (m_backgroundImageLoader.content() is MovieClip && 
				m_styles.backgroundAnimationControl)
			{
				applyAnimationControls();
			}
			
			var imgWidth : Number = imgContainer.width;
			var imgHeight : Number = imgContainer.height;
					
			var scale9Rect : Rectangle = constructScale9Rect(imgWidth, imgHeight);
			if (scale9Rect != null)
			{
				imgContainer.x = imgContainer.y = 0;
				imgContainer.scale9Grid = scale9Rect;
				imgContainer.width = m_width;
				imgContainer.height = m_height;
				m_backgroundImageContainer.graphics.clear();
				return;
			}
	
			imgContainer.scale9Grid = null;
			imgContainer.scaleX = imgContainer.scaleY = 1;
			var origin : Point = new Point(
				m_styles.backgroundPositionX | 0, m_styles.backgroundPositionY | 0);
			var xProperty : CSSProperty = 
				m_complexStyles.getStyle('backgroundPositionX');
			if (xProperty && xProperty.isRelativeValue())
			{
				origin.x = Math.round(
					xProperty.resolveRelativeValueTo(m_width - imgWidth));
			}
			var yProperty : CSSProperty = 
				m_complexStyles.getStyle('backgroundPositionY');
			if (yProperty && yProperty.isRelativeValue())
			{
				origin.y = Math.round(
					yProperty.resolveRelativeValueTo(m_height - imgHeight));
			}
			
			imgContainer.x = origin.x;
			imgContainer.y = origin.y;
			m_backgroundImageContainer.graphics.clear();
		}
		
		protected function applyAnimationControls() : void
		{
			if (m_animationControls)
			{
				m_animationControls.cancel();
			}
			m_animationControls = new CompositeCommand();
			var controls : Array = m_styles.backgroundAnimationControl;
			var animation : MovieClip = m_backgroundImageLoader.content();
			for (var i : int = 0; i < controls.length; i++)
			{
				var operation : Object = controls[i];
				var mcController : MovieClipController = 
					new MovieClipController(animation);
				mcController.setOperation(operation.type, operation.parameters);
				m_animationControls.addCommand(mcController);
			}
			m_animationControls.execute();
		}

		protected function constructScale9Rect(
			imgWidth : Number, imgHeight : Number) : Rectangle
		{
			if (m_styles.backgroundScale9Type == null || 
				m_styles.backgroundScale9Type == Background.SCALE9_TYPE_NONE ||
				m_styles.backgroundScale9RectTop == null ||
				m_styles.backgroundScale9RectRight == null ||
				m_styles.backgroundScale9RectBottom == null ||
				m_styles.backgroundScale9RectLeft == null)
			{
				return null;
			}
			
			var scale9Rect : Rectangle = new Rectangle();
			scale9Rect.top = m_styles.backgroundScale9RectTop;
			scale9Rect.left = m_styles.backgroundScale9RectLeft;
			scale9Rect.width = imgWidth - m_styles.backgroundScale9RectRight - 
				m_styles.backgroundScale9RectLeft;
			scale9Rect.height = imgHeight - m_styles.backgroundScale9RectTop - 
				m_styles.backgroundScale9RectBottom;
	
			return scale9Rect;
		}
	}
}