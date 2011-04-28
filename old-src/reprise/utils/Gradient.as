/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.utils { 
	import reprise.css.propertyparsers.Background;
	import reprise.data.AdvancedColor;
	
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	public class Gradient
	{
		
		//----------------------             Public Properties              ----------------------//
		public static const LINEAR:String = Background.GRADIENT_TYPE_LINEAR;
		public static const RADIAL:String = Background.GRADIENT_TYPE_RADIAL;
		
		public static const SPREAD_PAD:String = 'pad';
		public static const SPREAD_REFLECT:String = 'reflect';
		public static const SPREAD_REPEAT:String = 'repeat';
		
		public static const INTERPOLATION_LINEAR:String = 'linearRGB';
		public static const INTERPOLATION_RGB:String = 'RGB';
		
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _fillType:String;
		protected var _colors:Array;
		protected var _alphas:Array;
		protected var _ratios:Array;
		protected var _matrix:Matrix;
		protected var _spreadMethod:String;
		protected var _interpolationMethod:String;
		protected var _focalPointRatio:Number;
		
		protected var _rotation:Number = 90;
		protected var _width:Number;
		protected var _height:Number;
		protected var _origin:Point;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public function Gradient(fillType:String = null, colors:Array = null, alphas:Array = null, 
			ratios:Array = null, matrix:Matrix = null, spreadMethod:String = null, 
			interpolationMethod:String = null, focalPointRatio:Number = 1)
		{
			_fillType = fillType == null ? LINEAR : fillType;
			_colors = colors == null ? [0x0, 0xffffff] : colors;
			_alphas = alphas == null ? [] : alphas;
			_ratios = ratios == null ? [] : ratios;
			_matrix = matrix;
			_spreadMethod = spreadMethod;
			_interpolationMethod = interpolationMethod;
			_focalPointRatio = focalPointRatio;
			_origin = new Point(0, 0);
		}	
		
		public function beginGradientFill(target:Graphics, width:Number = 0, 
			height:Number = 0, rotation:Number = 0) : void
		{
			if (_alphas == null || _alphas.length != _colors.length)
			{
				initDefaultAlphas();
			}
			if (_ratios == null || _ratios.length != _colors.length)
			{
				initDefaultRatios();
			}
			
			var matrix : Matrix = _matrix;
			if (_matrix == null)
			{
				matrix = new Matrix();
				matrix.createGradientBox(width, height, (_rotation / 180) * Math.PI,
					_origin.x, _origin.y);
			}
			target.beginGradientFill(_fillType, _colors, _alphas, _ratios,
				matrix, _spreadMethod, _interpolationMethod, _focalPointRatio);
		}
		
		public function lineGradientStyle(target:Graphics, width:Number = 0, height:Number = 0,
				rotation:Number = 0) : void
		{
			if (_alphas == null || _alphas.length != _colors.length)
			{
				initDefaultAlphas();
			}
			if (_ratios == null || _ratios.length != _colors.length)
			{
				initDefaultRatios();
			}
			
			var matrix : Matrix = _matrix;
			if (_matrix == null)
			{
				matrix = new Matrix();
				matrix.createGradientBox(width, height, (_rotation / 180) * Math.PI,
					_origin.x, _origin.y);
			}
			target.lineGradientStyle(_fillType, _colors, _alphas, _ratios, matrix, _spreadMethod,
				_interpolationMethod, _focalPointRatio);
		}
		
		public function fillType() : String
		{
			return _fillType;
		}
		public function setFillType(val:String) : void
		{
			_fillType = val;
		}
		
		public function colors() : Array
		{
			return _colors;
		}
		public function setColors(val:Array) : void
		{
			var color : Object;
			_colors = [];
			_alphas = [];
			
			for (var i : int = 0; i < val.length; i++)
			{
				color = val[i];
				if (color is AdvancedColor)
				{
					_colors.push(color.rgb());
					_alphas.push(color.opacity());
				}
				else
				{
					_colors.push(color);
					_alphas.push(1);
				}
			}
		}
		
		public function alphas() : Array
		{
			return _alphas;
		}
		public function setAlphas(val:Array) : void
		{
			_alphas = val;
		}
		
		public function ratios() : Array
		{
			return _ratios;
		}
		public function setRatios(val:Array) : void
		{
			_ratios = val;
		}
		
		public function matrix() : Matrix
		{
			return _matrix;
		}
		public function setMatrix(val:Matrix) : void
		{
			_matrix = val;
		}
		
		public function spreadMethod() : String
		{
			return _spreadMethod;
		}
		public function setSpreadMethod(val:String) : void
		{
			_spreadMethod = val;
		}
		
		public function interpolationMethod() : String
		{
			return _interpolationMethod;
		}
		public function setInterpolationMethod(val:String) : void
		{
			_interpolationMethod = val;
		}
		
		public function focalPointRatio() : Number
		{
			return _focalPointRatio;
		}
		public function setFocalPointRatio(val:Number) : void
		{
			_focalPointRatio = val;
		}
		
		public function rotation() : Number
		{
			return _rotation;
		}
		public function setRotation(val:Number) : void
		{
			_rotation = val;
		}
		
		public function width() : Number
		{
			return _width;
		}
		public function setWidth(val:Number) : void
		{
			_width = val;
		}
		
		public function height() : Number
		{
			return _height;
		}
		public function setHeight(val:Number) : void
		{
			_height = val;
		}
		
		public function setOrigin(origin : Point) : void
		{
			_origin = origin;
		}
		public function origin() : Point
		{
			return _origin;
		}
		
		public function clone() : Gradient
		{
			var grad : Gradient = new Gradient(_fillType);
			grad.setColors(_colors.concat());
			grad.setAlphas(_alphas.concat());
			grad.setRatios(_ratios.concat());
			grad.setSpreadMethod(_spreadMethod);
			grad.setInterpolationMethod(_interpolationMethod);
			grad.setFocalPointRatio(_focalPointRatio);
			grad.setWidth(_width);
			grad.setHeight(_height);
			grad.setRotation(_rotation);
			grad.setMatrix(_matrix.clone());
			return grad;
		}
		
		public function equals(grad:Gradient) : Boolean
		{
			return fillType() == grad.fillType() &&
				ArrayUtil.compareArrays(colors(), grad.colors()) &&
				ArrayUtil.compareArrays(alphas(), grad.alphas()) &&
				ArrayUtil.compareArrays(ratios(), grad.ratios()) &&
				spreadMethod() == grad.spreadMethod() &&
				interpolationMethod() == grad.interpolationMethod() &&
				focalPointRatio() == grad.focalPointRatio() &&
				width() == grad.width() &&
				height() == grad.height() &&
				rotation() == grad.rotation() &&
				(matrix() == grad.matrix() || 
					matrix().toString() == grad.matrix().toString());
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected function initDefaultAlphas() : void
		{
			_alphas = [];
			var len:int = _colors.length;
			while (len--)
			{
				_alphas.push(1);
			}
		}
		
		protected function initDefaultRatios() : void
		{
			_ratios = [];
			var len:int = _colors.length;
			var step:Number = 0xff / (len - 1);
			var ratio : Number = 0;
			while (len--)
			{
				_ratios.push(ratio);
				ratio += step;
			}
		}
	}
}