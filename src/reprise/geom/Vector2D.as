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

package reprise.geom 
{	
	import reprise.utils.MathUtil;

	public class Vector2D
	{
		/*******************************************************************************************
		*								public properties										   *
		*******************************************************************************************/
		public var x : Number;
		public var y : Number;
			
		
		/*******************************************************************************************
		*								public methods											   *
		*******************************************************************************************/
		public function Vector2D(x : Number, y : Number)
		{
			this.x = x;
			this.y = y;
		}
		
		public function plus(v : Vector2D) : void
		{
			x += v.x;
			y += v.y;
		}
		
		public function plusNew(v : Vector2D) : Vector2D
		{
			return new Vector2D(x + v.x, y + v.y);
		}
		
		public function minus(v : Vector2D) : void
		{
			x -= v.x;
			y -= v.y;
		}
		
		public function minusNew(v : Vector2D) : Vector2D
		{
			return new Vector2D(x - v.x, y - v.y);
		}
		
		public function negate() : void
		{
			x = -x;
			y = -y;
		}
		
		public function negateNew() : Vector2D
		{
			return new Vector2D(-x, -y);		
		}
		
		public function scale(s : Number) : void
		{
			x *= s;
			y *= s;
		}
		
		public function scaleNew(s : Number) : Vector2D
		{
			return new Vector2D(x * s, y * s);
		}
		
		public function getLength() : Number
		{
			return Math.sqrt(x * x + y * y);
		}
		
		public function setLength(len : Number) : void
		{
			var r : Number = getLength();
			if (r) scale(len / r);
			else x = len;
		}
		
		public function angle() : Number
		{
			return MathUtil.atan(x, y);
		}
		
		public function radians() : Number
		{
			return Math.atan2(y, x);
		}
		
		public function setAngle(angle : Number) : void
		{
			var r : Number = getLength();
			x = r * MathUtil.cos(angle);
			y = r * MathUtil.sin(angle);
		}
		
		public function rotate(angle : Number) : void
		{
			var ca : Number = MathUtil.cos(angle);
			var sa : Number = MathUtil.sin(angle);
			var rx : Number = x * ca - y * sa;
			var ry : Number = x * sa + y * ca;
			x = rx;
			y = ry;
		}
		
		public function rotateNew(angle : Number) : Vector2D
		{
			var v : Vector2D = clone();
			v.rotate(angle);
			return v;
		}
		
		public function crossProduct(v : Vector2D) : Number
		{
			return (x * v.x + y * v.y);
		}
		
		public function normal() : Vector2D
		{
			return new Vector2D(-y, x);
		}
		
		public function isPerpTo(v : Vector2D) : Boolean
		{
			return (crossProduct(v) == 0);
		}
		
		public function angleBetween(v : Vector2D) : Number
		{
			var dp : Number = crossProduct(v);
			var cosAngle : Number = dp / (getLength() * v.getLength());
			return MathUtil.acos(cosAngle);
		}
		
		public function radiansBetween(v : Vector2D) : Number
		{
			var dp : Number = crossProduct(v);
			var cosAngle : Number = dp / (getLength() * v.getLength());
			return Math.acos(cosAngle);
		}
		
		public function equals(v : Vector2D) : Boolean
		{
			return (x == v.x && y == v.y);
		}
		
		public function clone() : Vector2D
		{
			return new Vector2D(x, y);
		}
		
		public function reset(x : Number, y : Number) : void
		{
			this.x = x;
			this.y = y;
		}
		
		public function toString() : String
		{
			return "[class 'Vector' x:" + x + ", y:" + y + ", angle: " + angle() + "]";
		}
	}
}