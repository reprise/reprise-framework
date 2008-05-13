package com.airtightinteractive.easing
{ 
	public class Bezier
	{
		// Cubic Bezier tween from b to b+c, influenced by p1 & p2
		// t: current time, b: beginning value, c: total change, d: duration
		// p1, p2: Bezier control point positions
		static public function tweenCubicBez(
			t:Number, b:Number, c:Number, d:Number,p1:Number,p2:Number) : Number 
		{
			return ((t/=d)*t*c + 3*(1-t)*(t*(p2-b) + (1-t)*(p1-b)))*t + b;
		}	
	}
}