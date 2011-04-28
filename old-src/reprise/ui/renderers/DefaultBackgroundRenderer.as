/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.ui.renderers
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import reprise.commands.CompositeCommand;
	import reprise.css.CSSProperty;
	import reprise.css.propertyparsers.Background;
	import reprise.css.propertyparsers.Filters;
	import reprise.css.transitions.CSSMovieClipController;
	import reprise.data.AdvancedColor;
	import reprise.events.ResourceEvent;
	import reprise.external.AbstractResource;
	import reprise.external.BitmapResource;
	import reprise.external.ImageResource;
	import reprise.utils.GfxUtil;
	import reprise.utils.Gradient;

	public class DefaultBackgroundRenderer extends AbstractCSSRenderer
	{//----------------------       Private / Protected Properties       ----------------------//
		protected var _backgroundImageContainer : Sprite;
		protected var _activeBackgroundAnimationContainer : Sprite;
		protected var _inactiveBackgroundAnimationContainer : Sprite;
		protected var _backgroundMask : Sprite;
		
		protected var _backgroundImage : BitmapData = null;
		protected var _backgroundImageLoader : AbstractResource;
		
		protected var _lastBackgroundImageType : String;
		protected var _lastBackgroundImageURL : String;
		protected var _animationControls : CompositeCommand;

		
		//----------------------               Public Methods               ----------------------//
		public function DefaultBackgroundRenderer() {}
	
		
		public override function draw() : void
		{
			var hasAnyContent:Boolean = false;
			
			var color:AdvancedColor = _styles.backgroundColor;
			var hasBackgroundGradient:Boolean = (_styles.backgroundGradientType ==
				Background.GRADIENT_TYPE_LINEAR || _styles.backgroundGradientType ==
				Background.GRADIENT_TYPE_RADIAL) && _styles.backgroundGradientColors;
			
			//TODO: investigate optimization strategies to prevent unneeded redraws
			//clear background
			_display.graphics.clear();
			
			// draw plain background color
			if (color != null && color.alpha() >= 0 && !hasBackgroundGradient)
			{
				hasAnyContent = true;
				_display.graphics.beginFill(color.rgb(), color.opacity());
				GfxUtil.drawRect(_display, 0, 0, _width, _height);
				_display.graphics.endFill();
			}
			// draw background gradient
			else if (hasBackgroundGradient)
			{
				hasAnyContent = true;
				var grad : Gradient = new Gradient(_styles.backgroundGradientType);
				grad.setColors(_styles.backgroundGradientColors);
				if (_styles.backgroundGradientRatios)
				{
					grad.setRatios(_styles.backgroundGradientRatios);
				}
				if (_styles.backgroundGradientRotation != 0)
				{
					grad.setRotation(_styles.backgroundGradientRotation);
				}
				
				grad.beginGradientFill(_display.graphics, _width, _height);
				GfxUtil.drawRect(_display, 0, 0, _width, _height);
				_display.graphics.endFill();
			}
			
			// load a background image
			if (_styles.backgroundImage != Background.IMAGE_NONE)
			{
				hasAnyContent = true;
				loadBackgroundImage();
			}
			// stop any loading of prior background images
			else
			{
				if (_backgroundImageLoader && _backgroundImageLoader.isExecuting())
				{
					_backgroundImageLoader.cancel();
				}
				_backgroundImageLoader = null;
				clearBackgroundImage();	
			}
				
			// apply dropshadow
			if (_styles.backgroundShadowColor != null)
			{
				hasAnyContent = true;
				var dropShadow : DropShadowFilter = Filters.
					dropShadowFilterFromStyleObjectForName(_styles, 'background');
				_display.filters = [dropShadow];
			}
			else
				_display.filters = [];
			
			// draw mask if neccessary
			if (hasAnyContent)
			{
				drawBackgroundMask();
			}
			else
			{
				_display.mask = null;
			}
		}
		
		public override function destroy() : void
		{
			_backgroundImageLoader && _backgroundImageLoader.cancel();
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected function clearBackgroundImage() : void
		{
			if (_backgroundImageContainer != null)
			{
				//TODO: find out parent and call directly
				_backgroundImageContainer.parent.removeChild(_backgroundImageContainer);
				_backgroundImageContainer = null;
				_activeBackgroundAnimationContainer = null;
				_inactiveBackgroundAnimationContainer = null;
			}
			if (_backgroundImage != null)
			{
				_backgroundImage.dispose();
				_backgroundImage = null;
			}
		}
		
		protected function loadBackgroundImage() : void
		{
			if (!_styles.backgroundImageType ||
				_styles.backgroundImageType != 'animation')
			{
				// cancel background animation loader since we don't need it
				if (_backgroundImageLoader && _backgroundImageLoader is ImageResource &&
					_backgroundImageLoader.isExecuting())
				{
					_backgroundImageLoader.cancel();
				}
				
				// if we're already loading the right bitmap, do nothing			
				if (_backgroundImageLoader &&
					_backgroundImageLoader is BitmapResource &&
					_backgroundImageLoader.url() == _styles.backgroundImage)
				{
					if (!_backgroundImageLoader.isExecuting())
					{
						// we force redrawing here, due to the fact that our size or 
						// the image position could have changed
						//TODO: verify that this really calls bitmapLoader_complete
						// @till: that is ugly. if you want to make sure that bitmapLoader_complete
						// is called you should call it directly. furthermore since 
						// bitmapLoader_complete is normally called via an event, the functionality
						// of that method should be extracted and then called directly instead!
						_backgroundImageLoader.dispatchEvent(
							new ResourceEvent(Event.COMPLETE, true));
					}
					return;
				}
				
				if (_backgroundImageLoader && _backgroundImageLoader.isExecuting())
				{
					_backgroundImageLoader.cancel();
				}
				
				_backgroundImageLoader = new BitmapResource();
				_backgroundImageLoader.setURL(_styles.backgroundImage);
				BitmapResource(_backgroundImageLoader).setCacheBitmap(true);
				BitmapResource(_backgroundImageLoader).setCloneBitmap(false);
				_backgroundImageLoader.addEventListener(
					Event.COMPLETE, bitmapLoader_complete);
				_backgroundImageLoader.execute();
				return;
			}
			
			// if we're loading a background image, cancel it, since we don't need it
			if (_backgroundImageLoader && _backgroundImageLoader.isExecuting() &&
				_backgroundImageLoader is BitmapResource)
			{
				_backgroundImageLoader.cancel();
				_backgroundImageLoader.removeEventListener(
					Event.COMPLETE, bitmapLoader_complete);
				_backgroundImageLoader = null;
			}
			
			if (!_backgroundImageContainer)
			{
				_backgroundImageContainer = Sprite(_display.addChildAt(
					new Sprite(), 0));
				_backgroundImageContainer.name = '_backgroundImageContainer';
			}
			
			// if we're already loading the right animation, do nothing
			if (_backgroundImageLoader &&
				_backgroundImageLoader.url() == _styles.backgroundImage &&
				_backgroundImageLoader is ImageResource)
			{
				if (_backgroundImageLoader.didFinishLoading() && _backgroundImageLoader.didSucceed())
				{
					// we force redrawing here, due to the fact that our size or 
					// the image position could have changed
					//TODO: verify that this really calls imageLoader_complete
					_backgroundImageLoader.dispatchEvent(
						new ResourceEvent(Event.COMPLETE, true));
				}
				return;
			}
			
			if (!_backgroundImageContainer)
			{
				_backgroundImageContainer = Sprite(_display.addChildAt(
					new Sprite(), 0));
				_backgroundImageContainer.name = '_backgroundImageContainer';
			}
			
			_inactiveBackgroundAnimationContainer = _activeBackgroundAnimationContainer;
			_activeBackgroundAnimationContainer = Sprite(
				_backgroundImageContainer.addChild(new Sprite()));
			_activeBackgroundAnimationContainer.name = '_backgroundAnimation';
	
			_backgroundImageLoader = new ImageResource();
			_backgroundImageLoader.setURL(_styles.backgroundImage);
			_backgroundImageLoader.addEventListener(
				Event.COMPLETE, imageLoader_complete);
			_backgroundImageLoader.execute();
		}
		
		protected function drawBackgroundMask() : void
		{
			var radii : Array = [];
			var hasRoundBorder : Boolean = false;
			var order : Array = ['borderTopLeftRadius', 'borderTopRightRadius', 
				'borderBottomRightRadius', 'borderBottomLeftRadius'];
			
			var borderTopWidthHalf : Number = (_styles['borderTopWidth'] || 0) / 2;
			var radiusItem : Number;
			for (var i : int = 0; i < order.length; i++)
			{
				if (!(_styles[order[i]] is Number))
				{
					radiusItem = 0;
				}
				else
				{
					radiusItem = _styles[order[i]];
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
				_display.mask = null;
				GfxUtil.drawRect(_display, 0, 0, _width, _height);
			}
			else
			{
				if (!_backgroundMask)
				{
					_backgroundMask = new Sprite();
					_display.addChild(_backgroundMask);
					_backgroundMask.name = 'mask';
//					_backgroundMask.visible = false;
				}
				_display.mask = _backgroundMask;
				_backgroundMask.graphics.clear();
				_backgroundMask.graphics.beginFill(0x00ffff, 20);
//				_backgroundMask.graphics.lineStyle(
//					0, 0, 0.5, 
//					false, 'normal', 'square', 'miter', 2);
				GfxUtil.drawRoundRect(
					_backgroundMask, 0, 0, _width, _height, radii);
			}
		}
		
		
		protected function bitmapLoader_complete(e : ResourceEvent) : void
		{
			clearBackgroundImage();
			
			if (!e.success || _styles.backgroundImage == null ||
				_styles.backgroundImage == Background.IMAGE_NONE ||
				!_backgroundImageLoader.content())
			{
				return;
			}
			
			if (!_backgroundImageLoader.content() is BitmapData)
			{
				return;
			}
			var newBackgroundImage : BitmapData = 
				BitmapData(_backgroundImageLoader.content());
			var imgWidth : Number = newBackgroundImage.width;
			var imgHeight : Number = newBackgroundImage.height;
			// prevent infinite loops
			if (imgWidth < 1 || imgHeight < 1)
			{
				return;
			}
			
			if (!_backgroundImageContainer)
			{
				_backgroundImageContainer = Sprite(_display.addChildAt(
					new Sprite(), 0));
				_backgroundImageContainer.name = '_backgroundImageContainer';
			}
	
			
			var backgroundRepeat : String = _styles.backgroundRepeat;
			var origin : Point = new Point(
				_styles.backgroundPositionX | 0, _styles.backgroundPositionY | 0);
			var xProperty : CSSProperty = 
				_complexStyles.getStyle('backgroundPositionX');
			if (xProperty && xProperty.isRelativeValue())
			{
				origin.x = 
					Math.round(xProperty.resolveRelativeValueTo(_width - imgWidth));
			}
			var yProperty : CSSProperty = 
				_complexStyles.getStyle('backgroundPositionY');
			if (yProperty && yProperty.isRelativeValue())
			{
				origin.y = 
					Math.round(yProperty.resolveRelativeValueTo(_height - imgHeight));
			}
	
			var scale9Rect : Rectangle = constructScale9Rect(imgWidth, imgHeight);
			if (scale9Rect != null)
			{
				if (_styles.backgroundScale9Type == Background.SCALE9_TYPE_REPEAT)
				{
					drawScale9RepeatedBackground(newBackgroundImage, scale9Rect);
					return;
				}
					
				var scale9Bitmap : BitmapData = new BitmapData(_width, _height, true, 0);
				GfxUtil.scale9Bitmap(newBackgroundImage, scale9Bitmap, scale9Rect);
				backgroundRepeat = Background.REPEAT_NO_REPEAT;
				origin = new Point(0, 0);
				newBackgroundImage = scale9Bitmap;
				imgWidth = _width;
				imgHeight = _height;
			}
	
			
			var rect : Rectangle = new Rectangle(0, 0, _width, _height);
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
			rect.right = Math.min(_width, rect.right);
			rect.bottom = Math.min(_height, rect.bottom);
			
			var smooth:Boolean = _styles.backgroundImageAliasing !=
				Background.IMAGE_ALIASING_ALIAS;
			_backgroundImageContainer.graphics.beginBitmapFill(
				newBackgroundImage, offset, true, smooth);
			GfxUtil.drawRect(_backgroundImageContainer,
				rect.left, rect.top, rect.width, rect.height);
			_backgroundImageContainer.graphics.endFill();
		}
		
		protected function drawScale9RepeatedBackground(sourceImage : BitmapData, 
			scale9Rect : Rectangle, repeat : Boolean = false) : void
		{
			var bitmaps : Object = GfxUtil.segmentedBitmapsOfScale9RectInRectWithSize(
				sourceImage, scale9Rect);
			var offset : Matrix = new Matrix();
			var smooth:Boolean = _styles.backgroundImageAliasing !=
				Background.IMAGE_ALIASING_ALIAS;
			
			// TL
			offset.translate(0, 0);
			_backgroundImageContainer.graphics.beginBitmapFill(
				bitmaps.tl, offset, false, smooth);
			GfxUtil.drawRect(_backgroundImageContainer,
				offset.tx, offset.ty, bitmaps.tl.width, bitmaps.tl.height);
			// T
			offset.tx = bitmaps.tl.width;
			offset.ty = 0;
			_backgroundImageContainer.graphics.beginBitmapFill(
				bitmaps.t, offset, true, smooth);
			GfxUtil.drawRect(_backgroundImageContainer, offset.tx, offset.ty,
				_width - bitmaps.tl.width - bitmaps.tr.width, bitmaps.t.height);
			// TR
			offset.tx = _width - bitmaps.tr.width;
			offset.ty = 0;
			_backgroundImageContainer.graphics.beginBitmapFill(
				bitmaps.tr, offset, false, smooth);
			GfxUtil.drawRect(_backgroundImageContainer, offset.tx, offset.ty,
				bitmaps.tr.width, bitmaps.tr.height);
			// R
			offset.tx = _width - bitmaps.r.width;
			offset.ty = bitmaps.tr.height;
			_backgroundImageContainer.graphics.beginBitmapFill(
				bitmaps.r, offset, true, smooth);
			GfxUtil.drawRect(_backgroundImageContainer, offset.tx, offset.ty,
				bitmaps.r.width, _height - bitmaps.tr.height - bitmaps.br.height);
			// BR
			offset.tx = _width - bitmaps.br.width;
			offset.ty = _height - bitmaps.br.height;
			_backgroundImageContainer.graphics.beginBitmapFill(
				bitmaps.br, offset, false, smooth);
			GfxUtil.drawRect(_backgroundImageContainer, offset.tx, offset.ty,
				bitmaps.br.width, bitmaps.br.height);
			// B
			offset.tx = bitmaps.bl.width;
			offset.ty = _height - bitmaps.b.height;
			_backgroundImageContainer.graphics.beginBitmapFill(
				bitmaps.b, offset, true, smooth);
			GfxUtil.drawRect(_backgroundImageContainer, offset.tx, offset.ty,
				_width - bitmaps.bl.width - bitmaps.br.width, bitmaps.b.height);
			// BL
			offset.tx = 0;
			offset.ty = _height - bitmaps.bl.height;
			_backgroundImageContainer.graphics.beginBitmapFill(
				bitmaps.bl, offset, false, smooth);
			GfxUtil.drawRect(_backgroundImageContainer, offset.tx, offset.ty,
				bitmaps.bl.width, bitmaps.bl.height);
			// L
			offset.tx = 0;
			offset.ty = bitmaps.tl.height;
			_backgroundImageContainer.graphics.beginBitmapFill(
				bitmaps.l, offset, true, smooth);
			GfxUtil.drawRect(_backgroundImageContainer, offset.tx, offset.ty,
				bitmaps.l.width, _height - bitmaps.tl.height - bitmaps.bl.height);
			// C
			offset.tx = bitmaps.tl.width;
			offset.ty = bitmaps.tl.height;
			_backgroundImageContainer.graphics.beginBitmapFill(
				bitmaps.c, offset, true, smooth);
			GfxUtil.drawRect(_backgroundImageContainer, offset.tx, offset.ty,
				_width - bitmaps.l.width - bitmaps.r.width,
				_height - bitmaps.t.height - bitmaps.b.height);
			_backgroundImageContainer.graphics.endFill();
		}
		
		protected function imageLoader_complete(e : ResourceEvent = null) : void
		{
			if (!e.success || _styles.backgroundImage == null ||
				_styles.backgroundImage == Background.IMAGE_NONE)
			{
				clearBackgroundImage();
				return;
			}
			
			if (_inactiveBackgroundAnimationContainer)
			{
				_inactiveBackgroundAnimationContainer.parent.removeChild(
					_inactiveBackgroundAnimationContainer);
				_inactiveBackgroundAnimationContainer = null;
			}
			var imgContainer : Sprite = _activeBackgroundAnimationContainer;
			imgContainer.addChild(_backgroundImageLoader.content());

			if (_backgroundImageLoader.content() is MovieClip &&
				_styles.backgroundAnimationControl)
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
				imgContainer.width = _width;
				imgContainer.height = _height;
				_backgroundImageContainer.graphics.clear();
				return;
			}
	
			imgContainer.scale9Grid = null;
			imgContainer.scaleX = imgContainer.scaleY = 1;
			var origin : Point = new Point(
				_styles.backgroundPositionX | 0, _styles.backgroundPositionY | 0);
			var xProperty : CSSProperty = 
				_complexStyles.getStyle('backgroundPositionX');
			if (xProperty && xProperty.isRelativeValue())
			{
				origin.x = Math.round(
					xProperty.resolveRelativeValueTo(_width - imgWidth));
			}
			var yProperty : CSSProperty = 
				_complexStyles.getStyle('backgroundPositionY');
			if (yProperty && yProperty.isRelativeValue())
			{
				origin.y = Math.round(
					yProperty.resolveRelativeValueTo(_height - imgHeight));
			}
			
			imgContainer.x = origin.x;
			imgContainer.y = origin.y;
			_backgroundImageContainer.graphics.clear();
		}
		
		protected function applyAnimationControls() : void
		{
			if (_animationControls)
			{
				_animationControls.cancel();
			}
			_animationControls = new CompositeCommand();
			var controls : Array = _styles.backgroundAnimationControl;
			var animation : MovieClip = _backgroundImageLoader.content();
			for (var i : int = 0; i < controls.length; i++)
			{
				var operation : Object = controls[i];
				var mcController : CSSMovieClipController = 
					new CSSMovieClipController(animation);
				mcController.setOperation(operation.type, operation.parameters);
				_animationControls.addCommand(mcController);
			}
			_animationControls.execute();
		}

		protected function constructScale9Rect(
			imgWidth : Number, imgHeight : Number) : Rectangle
		{
			if (_styles.backgroundScale9Type == null ||
				_styles.backgroundScale9Type == Background.SCALE9_TYPE_NONE ||
				_styles.backgroundScale9RectTop == null ||
				_styles.backgroundScale9RectRight == null ||
				_styles.backgroundScale9RectBottom == null ||
				_styles.backgroundScale9RectLeft == null)
			{
				return null;
			}
			
			var scale9Rect : Rectangle = new Rectangle();
			scale9Rect.top = _styles.backgroundScale9RectTop;
			scale9Rect.left = _styles.backgroundScale9RectLeft;
			scale9Rect.width = imgWidth - _styles.backgroundScale9RectRight -
				_styles.backgroundScale9RectLeft;
			scale9Rect.height = imgHeight - _styles.backgroundScale9RectTop -
				_styles.backgroundScale9RectBottom;
	
			return scale9Rect;
		}
	}
}