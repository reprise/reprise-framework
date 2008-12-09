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
	}
}