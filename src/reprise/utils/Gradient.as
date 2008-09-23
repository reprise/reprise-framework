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

package reprise.utils { 
	import reprise.css.propertyparsers.Background;
	import reprise.data.AdvancedColor;
	
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	public class Gradient
	{
		
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const LINEAR:String = Background.GRADIENT_TYPE_LINEAR;
		public static const RADIAL:String = Background.GRADIENT_TYPE_RADIAL;
		
		public static const SPREAD_PAD:String = 'pad';
		public static const SPREAD_REFLECT:String = 'reflect';
		public static const SPREAD_REPEAT:String = 'repeat';
		
		public static const INTERPOLATION_LINEAR:String = 'linearRGB';
		public static const INTERPOLATION_RGB:String = 'RGB';
		
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_fillType:String;
		protected var m_colors:Array;
		protected var m_alphas:Array;
		protected var m_ratios:Array;
		protected var m_matrix:Matrix;
		protected var m_spreadMethod:String;
		protected var m_interpolationMethod:String;
		protected var m_focalPointRatio:Number;
		
		protected var m_rotation:Number = 90;
		protected var m_width:Number;
		protected var m_height:Number;
		protected var m_origin:Point;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function Gradient(fillType:String, colors:Array = null, alphas:Array = null, 
			ratios:Array = null, matrix:Matrix = null, spreadMethod:String = null, 
			interpolationMethod:String = null, focalPointRatio:Number = 1)
		{
			m_fillType = fillType == null ? LINEAR : fillType;
			m_colors = colors == null ? [0x0, 0xffffff] : colors;
			m_alphas = alphas == null ? [] : alphas;
			m_ratios = ratios == null ? [] : ratios; 
			m_matrix = matrix;
			m_spreadMethod = spreadMethod;
			m_interpolationMethod = interpolationMethod;
			m_focalPointRatio = focalPointRatio;
			m_origin = new Point(0, 0);
		}	
		
		public function beginGradientFill(target:Graphics, width:Number = 0, 
			height:Number = 0, rotation:Number = 0) : void
		{
			if (m_alphas == null || m_alphas.length != m_colors.length)
			{
				initDefaultAlphas();
			}
			if (m_ratios == null || m_ratios.length != m_colors.length)
			{
				initDefaultRatios();
			}
			
			var matrix : Matrix = m_matrix;
			if (m_matrix == null)
			{
				matrix = new Matrix();
				matrix.createGradientBox(width, height, (m_rotation / 180) * Math.PI,
					m_origin.x, m_origin.y);
			}
			target.beginGradientFill(m_fillType, m_colors, m_alphas, m_ratios, 
				matrix, m_spreadMethod, m_interpolationMethod, m_focalPointRatio);
		}
		
		public function lineGradientStyle(target:Graphics, width:Number = 0, height:Number = 0,
				rotation:Number = 0) : void
		{
			if (m_alphas == null || m_alphas.length != m_colors.length)
			{
				initDefaultAlphas();
			}
			if (m_ratios == null || m_ratios.length != m_colors.length)
			{
				initDefaultRatios();
			}
			
			var matrix : Matrix = m_matrix;
			if (m_matrix == null)
			{
				matrix = new Matrix();
				matrix.createGradientBox(width, height, (m_rotation / 180) * Math.PI,
					m_origin.x, m_origin.y);
			}
			
			target.lineGradientStyle(m_fillType, m_colors, m_alphas, m_ratios, matrix, m_spreadMethod,
				m_interpolationMethod, m_focalPointRatio);		
		}
		
		public function fillType() : String
		{
			return m_fillType;
		}
		public function setFillType(val:String) : void
		{
			m_fillType = val;
		}
		
		public function colors() : Array
		{
			return m_colors;
		}
		public function setColors(val:Array) : void
		{
			var i : Number;
			var color : Object;
			m_colors = [];
			m_alphas = [];
			
			for (i = 0; i < val.length; i++)
			{
				color = val[i];
				if (color is AdvancedColor)
				{
					m_colors.push(color.rgb());
					m_alphas.push(color.opacity());
				}
				else
				{
					m_colors.push(color);
					m_alphas.push(100);
				}
			}
		}
		
		public function alphas() : Array
		{
			return m_alphas;
		}
		public function setAlphas(val:Array) : void
		{
			m_alphas = val;
		}
		
		public function ratios() : Array
		{
			return m_ratios;
		}
		public function setRatios(val:Array) : void
		{
			m_ratios = val;
		}
		
		public function matrix() : Matrix
		{
			return m_matrix;
		}
		public function setMatrix(val:Matrix) : void
		{
			m_matrix = val;
		}
		
		public function spreadMethod() : String
		{
			return m_spreadMethod;
		}
		public function setSpreadMethod(val:String) : void
		{
			m_spreadMethod = val;
		}
		
		public function interpolationMethod() : String
		{
			return m_interpolationMethod;
		}
		public function setInterpolationMethod(val:String) : void
		{
			m_interpolationMethod = val;
		}
		
		public function focalPointRatio() : Number
		{
			return m_focalPointRatio;
		}
		public function setFocalPointRatio(val:Number) : void
		{
			m_focalPointRatio = val;
		}
		
		public function rotation() : Number
		{
			return m_rotation;
		}
		public function setRotation(val:Number) : void
		{
			m_rotation = val;
		}
		
		public function width() : Number
		{
			return m_width;
		}
		public function setWidth(val:Number) : void
		{
			m_width = val;
		}
		
		public function height() : Number
		{
			return m_height;
		}
		public function setHeight(val:Number) : void
		{
			m_height = val;
		}
		
		public function setOrigin(origin : Point) : void
		{
			m_origin = origin;
		}
		public function origin() : Point
		{
			return m_origin;
		}
		
		public function clone() : Gradient
		{
			var grad : Gradient = new Gradient(m_fillType);
			grad.setColors(m_colors.concat());
			grad.setAlphas(m_alphas.concat());
			grad.setRatios(m_ratios.concat());
			grad.setSpreadMethod(m_spreadMethod);
			grad.setInterpolationMethod(m_interpolationMethod);
			grad.setFocalPointRatio(m_focalPointRatio);
			grad.setWidth(m_width);
			grad.setHeight(m_height);
			grad.setRotation(m_rotation);
			grad.setMatrix(m_matrix.clone());
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
		
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function initDefaultAlphas() : void
		{
			m_alphas = [];
			var len:Number = m_colors.length;
			while (len--)
			{
				m_alphas.push(100);
			}
		}
		
		protected function initDefaultRatios() : void
		{
			m_ratios = [];
			var len:Number = m_colors.length;
			var step:Number = 0xff / (len - 1);
			var ratio : Number = 0;
			while (len--)
			{
				m_ratios.push(ratio);
				ratio += step;
			}
		}
	}
}