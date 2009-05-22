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

package reprise.utils
{ 
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import reprise.utils.GeomUtil;
	
	public class GfxUtil 
	{
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		/**
		 * draws a rect in the given context
		 * TODO: change interface to Rectangle
		 */
		public static function drawRect(
			mc:Sprite, x:Number, y:Number, w:Number, h:Number):void
		{
			mc.graphics.drawRect(x, y, w, h);
		}
		
		/**
		 * draws a circle in the given context
		 */
		public static function drawCircle(
			mc:Sprite, x:Number, y:Number, radius:Number) : void
		{
			//TODO: verify this change
			mc.graphics.drawCircle(x, y, radius);
//			var kDegreesToRadians:Number = Math.PI / 180;
//			var theta:Number = 45 * kDegreesToRadians;
//			var cr:Number = radius / Math.cos(theta / 2);
//			var angle:Number = 0;
//			var cangle:Number = 0 - theta/2;
//			mc.graphics.moveTo(x + radius, y);
//			for (var i:Number = 0; i < 8; i++) 
//			{
//				angle += theta;
//				cangle += theta;
//				var endX:Number = radius * Math.cos (angle);
//				var endY:Number = radius * Math.sin (angle);
//				var cX:Number = cr * Math.cos (cangle);
//				var cY:Number = cr * Math.sin (cangle);
//				mc.graphics.curveTo(x + cX, y + cY, x + endX, y + endY);
//			}
		}
		
		// drawRoundRect
		// x - x position of  fill
		// y - y position of  fill
		// w - width of  fill
		// h  - height of  fill
		// r - corner radius of fill :: number or object {br:#,bl:#,tl:#,tr:#}
		public static function drawRoundRect(mc:Sprite, 
			x:Number, y:Number, w:Number, h:Number, radius:Array) : void
		{
			var rbr : Number, rbl : Number, rtl : Number, rtr : Number, r : Number;
			var a : Number;
			var s : Number;
					
			// mimic css behaviour here
			switch (radius.length)
			{
				case 1:
				{
					rbr = rbl = rtl = rtr = radius[0];
					break;
				}
				case 2:
				{
					rtl = rbr = radius[0];
					rtr = rbl = radius[1];
					break;
				}
				case 3:
				{
					rtl = radius[0];
					rtr = rbr = radius[1];
					rbl = radius[2];
					break;
				}
				case 4:
				{
					rtl = radius[0];
					rtr = radius[1];
					rbr = radius[2];
					rbl = radius[3];
					break;
				}
				default:
				{
					log('w Wrong number of parameters (radius) in drawRoundRect!');
					return;
				}
			}
			mc.graphics.drawRoundRectComplex(x, y, w, h, rtl, rtr, rbl, rbr);
		}	
		
		
		public static function drawStar(mc : Sprite, x : Number, y : Number, 
			numSides : int, innerRadius : Number, outerRadius : Number, 
			startAngle : Number = NaN) : void
		{
			var step : Number = (2 * Math.PI) / numSides;
			var angle : Number;
			var count : int = 0;
		
			if (isNaN(startAngle))
			{
				startAngle = -step + Math.PI / 2;
			}
			else
			{
				startAngle *= (Math.PI / 180);
			}
		
			x += outerRadius;
			y += outerRadius;
		
			for (var i : int = 0; i < numSides; i++)
			{
				angle = (step * count++) + startAngle;
				if (i == 0)
				{
					mc.graphics.moveTo(Math.cos(startAngle) * innerRadius + x, Math.sin(startAngle) * innerRadius + y);
				}
				else
				{
					mc.graphics.lineTo(Math.cos(angle) * innerRadius + x, Math.sin(angle) * innerRadius + y);
				}
				angle += step / 2;
				mc.graphics.lineTo(Math.cos(angle) * outerRadius + x, Math.sin(angle) * outerRadius + y);
			}
			mc.graphics.lineTo(Math.cos(startAngle) * innerRadius + x, Math.sin(startAngle) * innerRadius + y);
		}
		
		
		
		/**
		 * draws a dashed line from point a to point b
		 */
		public static function drawDashedLine (mc:Sprite, 
			startX:Number, startY:Number, endX:Number, endY:Number, 
			dashLength:Number, gapLength:Number) : void
		{
			// init vars
			var seglength:Number;
			var dX:Number;
			var dY:Number;
			var segs:Number;
			var cx:Number;
			var cy:Number;
			
			// calculate the legnth of a segment
			seglength = dashLength + gapLength;
			// calculate the length of the dashed line
			dX = endX - startX;
			dY = endY - startY;
			var lineLength:Number = Math.sqrt((dX * dX) + (dY * dY));
			// calculate the number of segments needed
			segs = Math.floor(Math.abs(lineLength / seglength));
			// get the angle of the line in radians
			var lineAngle:Number = Math.atan2(dY, dX);
			var lineAngleCos:Number = Math.cos(lineAngle);
			var lineAngleSin:Number = Math.sin(lineAngle);
			// start the line here
			cx = startX;
			cy = startY;
			// add these to cx, cy to get next seg start
			dX = lineAngleCos * seglength;
			dY = lineAngleSin * seglength;
			// loop through each seg
			if (segs)
			{
				while (segs--)
				{
					mc.graphics.moveTo(cx,cy);
					mc.graphics.lineTo(cx + lineAngleCos * dashLength, 
						cy + lineAngleSin * dashLength);
					cx += dX;
					cy += dY;
				}
				// handle last segment as it is likely to be partial
				mc.graphics.moveTo(cx, cy);
				lineLength = 
					Math.sqrt((endX-cx) * (endX-cx) + (endY-cy) * (endY-cy));
				if(lineLength > dashLength)
				{
					// segment ends in the gap, so draw a full dash
					mc.graphics.lineTo(
						cx+lineAngleCos*dashLength,cy+lineAngleSin*dashLength);
				}
				else if(lineLength>0) {
					// segment is shorter than dash so only draw what is needed
					mc.graphics.lineTo(
						cx+lineAngleCos*lineLength,cy+lineAngleSin*lineLength);
				}
				// move the pen to the end position
				mc.graphics.moveTo(endX,endY);
			}
		}
		
		/**
		 * scales the given bitmap using the given rect as a scale9grid.
		 * 
		 * @param source The source BitmapData object
		 * @param rect The scale9grid
		 * @param scale The values by which to scale the source, where 1 = 100%
		 * 
		 * @return a new BitmapData object containing the scale bitmap
		 */
		public static function scale9Bitmap(
			source:BitmapData, target:BitmapData, rect:Rectangle) : void
		{
			var bordersTL:Point = new Point(rect.x, rect.y);
			var bordersBR:Point = new Point((source.width - rect.x - rect.width), 
				(source.height - rect.y - rect.height));
			var innerScale:Point = new Point(
				(target.width - rect.x - bordersBR.x) / rect.width,
				(target.height - rect.y - bordersBR.y) / rect.height);
			
			var tmp:BitmapData;
			var tmp2:BitmapData;
			var mat:Matrix;
			
			//corners
			target.copyPixels(source, 
				new Rectangle(0, 0, rect.x, rect.y), new Point(0, 0), 
				null, null, true);
			target.copyPixels(source, 
				new Rectangle(rect.right, 0, bordersBR.x, rect.y), 
				new Point(target.width - bordersBR.x , 0), null, null, true);
			target.copyPixels(source, 
				new Rectangle(rect.right, rect.bottom, bordersBR.x, bordersBR.y), 
				new Point(target.width - bordersBR.x, target.height - bordersBR.y), 
				null, null, true);
			target.copyPixels(source, 
				new Rectangle(0, rect.bottom, rect.x, bordersBR.y), 
				new Point(0, target.height - bordersBR.y), null, null, true);
			
			//borders
			copyScaledPixels(source, target, 
				new Rectangle(bordersTL.x, 0, rect.width, bordersTL.y), 
				new Point(rect.x, 0), new Point(innerScale.x, 1));
			copyScaledPixels(source, target, 
				new Rectangle(rect.right, bordersTL.y, bordersBR.x, rect.height), 
				new Point(target.width - bordersBR.x, bordersTL.y), 
				new Point(1, innerScale.y));
			copyScaledPixels(source, target, 
				new Rectangle(bordersTL.x, rect.bottom, rect.width, bordersBR.y), 
				new Point(rect.x, target.height - bordersBR.y), 
				new Point(innerScale.x, 1));
			copyScaledPixels(source, target, 
				new Rectangle(0, bordersTL.y, bordersTL.x, rect.height), 
				new Point(0, rect.y), new Point(1, innerScale.y));
			
			//center
			copyScaledPixels(source, target, rect, bordersTL, innerScale);
		}
		
		public static function copyScaledPixels(source:BitmapData, 
			target:BitmapData, sourceRect:Rectangle, destPoint:Point, 
			scale:Point, smooth:Boolean = false) : void
		{
			var tmp:BitmapData = new BitmapData(
				sourceRect.width, sourceRect.height, source.transparent, 0x0);
			tmp.copyPixels(source, sourceRect, new Point(0, 0));
			var tmp2:BitmapData = new BitmapData(sourceRect.width * scale.x, 
				sourceRect.height * scale.y, source.transparent, 0x0);
			var mat:Matrix = new Matrix();
			mat.scale(scale.x, scale.y);
			tmp2.draw(tmp, mat, null, null, null, smooth);
			target.copyPixels(tmp2, tmp2.rect, destPoint, null, null, true);
		}
		
		public static function drawWedge(graphics:Graphics, x:Number, y:Number, startAngle:Number, 
			arc:Number, radius:Number, yRadius:Number = -1):void
		{
			if (yRadius == -1) 
			{
				yRadius = radius;
			}
			graphics.moveTo(x, y);
			// Init vars
			var segAngle:Number, theta:Number, angle:Number, angleMid:Number, segs:Number, 
				ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number;

			if (Math.abs(arc) > 360) 
			{
				arc = 360;
			}
			segs = Math.ceil(Math.abs(arc)/45);
			segAngle = arc/segs;
			theta = -(segAngle/180)*Math.PI;
			angle = -(startAngle/180)*Math.PI;
			if (segs > 0) 
			{
				ax = x+Math.cos(startAngle/180*Math.PI)*radius;
				ay = y+Math.sin(-startAngle/180*Math.PI)*yRadius;
				graphics.lineTo(ax, ay);
				for (var i:Number = 0; i<segs; i++) 
				{
					angle += theta;
					angleMid = angle-(theta/2);
					bx = x+Math.cos(angle)*radius;
					by = y+Math.sin(angle)*yRadius;
					cx = x+Math.cos(angleMid)*(radius/Math.cos(theta/2));
					cy = y+Math.sin(angleMid)*(yRadius/Math.cos(theta/2));
					graphics.curveTo(cx, cy, bx, by);
				}
				graphics.lineTo(x, y);
			}
		}
		
		public static function copyPixelsTiled(
			source:BitmapData, target:BitmapData, 
			sourceRect:Rectangle, destRect:Rectangle) : void
		{
			var insertPoint:Point = destRect.topLeft.clone();
			do
			{
				var copyRect:Rectangle = source.rect.clone();
				if (insertPoint.y + copyRect.height > destRect.height)
				{
					copyRect.height -= 
						(copyRect.height + insertPoint.y - destRect.bottom);
				}
				do
				{
					if (insertPoint.x + copyRect.width > destRect.right)
					{
						copyRect.width -= 
							(copyRect.width + insertPoint.x - destRect.right);
					}
					target.copyPixels(source, copyRect, 
						insertPoint, null, null, true);
					insertPoint.offset(source.width, 0);
				}
				while (insertPoint.x < destRect.width);
				insertPoint.offset(0, source.height);
				insertPoint.x = destRect.topLeft.x;
			}
			while (insertPoint.y < destRect.height);
		}
		
		public static function pixelateBitmap(
			source:BitmapData, pixelSize:Number, fillcolor:Number) : BitmapData
		{
			var pixelator:BitmapData = new BitmapData(source.width / pixelSize, 
				source.height / pixelSize, true, fillcolor);
			var scaleMatrix:Matrix = new Matrix();
			scaleMatrix.scale(1 / pixelSize, 1 / pixelSize);
			pixelator.draw(source, scaleMatrix);
	
			var pixelatedBitmap:BitmapData = 
				new BitmapData(source.width, source.height, true, fillcolor);
			scaleMatrix = new Matrix();
			scaleMatrix.scale(pixelSize, pixelSize);
			pixelatedBitmap.draw(pixelator, scaleMatrix);
			
			return pixelatedBitmap;
		}
		
		
		public static function bitmapDataInRect(source:BitmapData, rect:Rectangle) : BitmapData
		{
			var resultBitmap : BitmapData = new BitmapData(rect.width, rect.height);
			resultBitmap.copyPixels(source, rect, new Point(0, 0));
			return resultBitmap;
		}
		
		public static function segmentedBitmapsOfScale9RectInRectWithSize(
			source:BitmapData, scale9Rect:Rectangle) : Object
		{
			var rects : Object = segmentedRectsOfScale9RectInRectWithSize(
				scale9Rect, source.width, source.height);
			var bitmaps : Object = {};
			var key : String;
			var rect : Rectangle;
			for (key in rects)
			{
				rect = Rectangle(rects[key]);
				var bitmap : BitmapData = new BitmapData(rect.width, rect.height, true, 0);
				bitmap.copyPixels(source, rect, new Point(0, 0));
				bitmaps[key] = bitmap;
			}
			return bitmaps;
		}
		
		public static function segmentedRectsOfScale9RectInRectWithSize(
			scale9Rect:Rectangle, width:Number, height:Number) : Object
		{
			var rects : Object = {};
			rects.tl = new Rectangle(0, 0, scale9Rect.left, scale9Rect.top);
			rects.t = new Rectangle(scale9Rect.left, 0, scale9Rect.width, scale9Rect.top);
			rects.tr = new Rectangle(scale9Rect.right, 0, width - scale9Rect.right, scale9Rect.top);
			rects.r = new Rectangle(scale9Rect.right, scale9Rect.top, 
				width - scale9Rect.right, scale9Rect.height);
			rects.br = new Rectangle(scale9Rect.right, scale9Rect.bottom, 
				width - scale9Rect.right, height - scale9Rect.bottom);
			rects.b = new Rectangle(scale9Rect.left, scale9Rect.bottom, 
				scale9Rect.width, height - scale9Rect.bottom);
			rects.bl = new Rectangle(0, scale9Rect.bottom, 
				scale9Rect.left, height - scale9Rect.bottom);
			rects.l = new Rectangle(0, scale9Rect.top, scale9Rect.left, scale9Rect.height);
			rects.c = new Rectangle(scale9Rect.left, scale9Rect.top, 
				scale9Rect.width, scale9Rect.height);
					
			return rects;
		}
		
		public static function bitmapDataScaledToRect(bmp:BitmapData, rect:Rectangle, 
			keepRatio:Boolean = true, allowUpScale:Boolean = false):BitmapData
		{
			var sourceRect:Rectangle = new Rectangle(0, 0, bmp.width, bmp.height);
			GeomUtil.scaleRectToRect(sourceRect, rect, keepRatio, allowUpScale);
			var mat:Matrix = new Matrix();
			mat.scale(sourceRect.width / bmp.width, sourceRect.height / bmp.height);
			var scaledBmp:BitmapData = new BitmapData(sourceRect.width, sourceRect.height, true, 0x0);
			scaledBmp.draw(bmp, mat, null, null, null, true);
			return scaledBmp;
		}
		
			
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		/**
		 * protected constructor to prevent static class from being instantiated
		 */
		public function GfxUtil() {
		}
		
	}
}