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
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class GeomUtil 
	{
		
		/***************************************************************************
		*							private properties							   *
		***************************************************************************/
		private static const MATRIX_MAPPINGS : Array = ['a', 'c', 'b', 'd', 'tx', 'ty'];
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function GeomUtil()
		{
			throw new Error("You don't instantiate the GeomUtil!");
		}
		
		public static function matrixToCSSMatrixString(matrix : Matrix) : String
		{
			return 'matrix(' + matrix.a + ', ' + matrix.c + ', ' + matrix.b + ', ' + 
				matrix.d + ', ' + matrix.tx + ', ' + matrix.ty + ')';
		}
		
		public static function CSSMatrixParametersToMatrix(matrixParameters : Array) : Matrix
		{
			var mappings : Array = MATRIX_MAPPINGS;
			var matrix : Matrix = new Matrix();
			for (var i : int = matrixParameters.length; i--;)
			{
				matrix[mappings[i]] = parseFloat(matrixParameters[i]);
			}
			return matrix;
		}
		
		public static function scaleRectToRect(sourceRect : Rectangle, targetRect : Rectangle, 
			keepRatio : Boolean = true, allowUpscale:Boolean = false) : void
		{
			if(!keepRatio)
			{
				sourceRect.width = targetRect.width - sourceRect.x;	
				sourceRect.height = targetRect.height - sourceRect.y;	
				return;
			}
			
			var ratio:Number;
			// rect is too small
			if (sourceRect.width <= targetRect.width && sourceRect.height <= targetRect.height)
			{
				if (!allowUpscale)
				{
					return;
				}
				ratio = Math.max(targetRect.width / sourceRect.width, 
					targetRect.height / sourceRect.height);
				sourceRect.width *= ratio;
				sourceRect.height *= ratio;
				return;
			}
			
			// rect is too tall
			if (sourceRect.width <= targetRect.width)
			{
				ratio = targetRect.height / sourceRect.height;
				sourceRect.height = targetRect.height;
				sourceRect.width *= ratio;
			}
			// rect is too wide
			else if (sourceRect.height <= targetRect.height)
			{
				ratio = targetRect.width / sourceRect.width;
				sourceRect.width = targetRect.width;
				sourceRect.height *= ratio;
			}
			// rect is too wide and too tall
			else
			{
				ratio = Math.min(targetRect.width / sourceRect.width, 
					targetRect.height / sourceRect.height);
				sourceRect.width *= ratio;
				sourceRect.height *= ratio;
			}
		}
	}
}