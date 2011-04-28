/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css
{
	import reprise.core.reprise;	
	import reprise.core.Cloneable;
	import reprise.css.math.AbstractCSSCalculation;
	import reprise.css.math.CSSCalculationGroup;
	import reprise.css.math.CSSCalculationPercentage;
	import reprise.css.math.ICSSCalculationContext;
	
	use namespace reprise;
	 
	// @see http://www.w3.org/TR/REC-CSS2/cascade.html
	public class CSSProperty implements Cloneable
	{
		//----------------------             Public Properties              ----------------------//
		public static const UNIT_PIXEL : String = 'px';
		public static const UNIT_EM : String = 'em';
		public static const UNIT_PERCENT : String = '%';
		
		public static const IMPORTANT_FLAG : String = '!important';
		public static const INHERIT_FLAG : String = 'inherit';
		public static const AUTO_FLAG : String = 'auto';
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected static var g_id : int = 0;
		
		protected var _important : Boolean = false;
		protected var _isRelativeValue : Boolean = false;
		protected var _inheritsValue : Boolean = false;
	                                    
		protected var _specifiedValue : Object = null;
		protected var _computedValue : Object = null;
		
		protected var _isCalculation : Boolean;
		protected var _calculation : AbstractCSSCalculation;
		protected var _calculationResultsCache : Object;
		
		protected var _unit : String = null;
		
		protected var _cssFile : String;
	
		protected var _id : int;
		protected var _isWeak : Boolean;

		
		//----------------------               Public Methods               ----------------------//
		public function CSSProperty()
		{
			_id = g_id++;
		}
		
			
		public function important() : Boolean
		{
			return _important;
		}
	
		reprise function setImportant(val:Boolean) : void
		{
			_important = val;
		}
		
		public function unit() : String
		{
			return _unit;
		}
		
		reprise function setUnit(unitStr:String) : void
		{
			if (unitStr == 'px' || unitStr == 'em')
			{
				_isRelativeValue = false;
			}
			else if (unitStr == '%')
			{
				setIsRelativeValue(true);
			}
			
			_unit = unitStr;
		}
		
		public function isRelativeValue() : Boolean
		{
			return _isRelativeValue;
		}
		
		public function setIsWeak(isWeak : Boolean) : void
		{
			_isWeak = isWeak;
		}
		
		public function isWeak() : Boolean
		{
			return _isWeak;
		}
		
		reprise function setIsRelativeValue( bFlag : Boolean ) : void
		{
			_isRelativeValue = bFlag;
			_calculationResultsCache = {};
			if (_specifiedValue)
			{
				setSpecifiedValue(_specifiedValue);
			}
		}
		
		public function isCalculation() : Boolean
		{
			return _isCalculation;
		}
	
		reprise function setIsCalculation(value : Boolean) : void
		{
			_isCalculation = value;
			if (value)
			{
				_calculationResultsCache = {};
				_isRelativeValue = true;
				if (_specifiedValue)
				{
					preprocessCalculation(_specifiedValue);
				}
			}
		}
		
		reprise function setInheritsValue( bFlag : Boolean ) : void
		{
			_inheritsValue = bFlag;
		}
		
		public function inheritsValue() : Boolean
		{
			return _inheritsValue;
		}
		
		public function isAuto() : Boolean
		{
			return _specifiedValue == 'auto';
		}
		
		public function specifiedValue() : *
		{
			return _specifiedValue;
		}
	
		reprise function setSpecifiedValue(value : *) : void
		{
			_specifiedValue = value;
			if (_specifiedValue == 150)
			{
				_specifiedValue;
			}
			if (value == 'auto')
			{
				_computedValue = 0;
			}
			else if (_isRelativeValue)
			{
				if (_isCalculation)
				{
					preprocessCalculation(value);
				}
				else
				{
					_calculation = new CSSCalculationPercentage(value.toString());
				}
			}
			else if (_unit == 'em')
			{
				_computedValue = value * 16; //TODO: this has to be changed to make em's relative
			}
			else
			{
				_computedValue = null;
			}
		}
		
		reprise function setCSSFile(cssFile : String) : void
		{
			_cssFile = cssFile;
		}
		
		public function cssFile() : String
		{
			return _cssFile;
		}
		
		public function toString() : String
		{
			var str:String = "property {\n";
			str += "\tspecified Value : " + _specifiedValue + "\n";
			str += "\tcomputed Value : " + _computedValue + "\n";
			str += "\tunit : " + _unit + "\n";
			str += "\timportant : " + _important + "\n";
			str += "\tweak : " + _isWeak + "\n";
			return str;
		}	
		
		public function valueOf() : Object
		{
			if (_computedValue != null)
			{
				return _computedValue;
			}
			return _specifiedValue;
		}
		
		public function resolveRelativeValueTo(
			reference : Number, context : ICSSCalculationContext = null) : Number
		{
			if (!_isRelativeValue)
			{
				return _specifiedValue is Number && _specifiedValue || 0;
			}
			if (_calculationResultsCache[reference+_specifiedValue.toString()])
			{
				return _calculationResultsCache[reference+_specifiedValue.toString()];
			}
			return _calculationResultsCache[reference+_specifiedValue.toString()] =
				resolveCalculation(reference, context);
		}
		
		public function clone(deep : Boolean = false) : Cloneable
		{
			var prop : CSSProperty = new CSSProperty();
			prop._important = _important;
			prop._isWeak = _isWeak;
			prop._unit = _unit;
			prop._inheritsValue = _inheritsValue;
			prop._isRelativeValue = _isRelativeValue;
			if (_isRelativeValue)
			{
				prop._calculationResultsCache = _calculationResultsCache;
				prop._calculation = _calculation;
			}
			prop._cssFile = _cssFile;
			
			if (deep)
			{
				if (_specifiedValue is Cloneable)
				{
					prop._specifiedValue = Cloneable(_specifiedValue).clone(true);
					if (_computedValue)
					{
						prop._computedValue = Cloneable(_computedValue).clone(true);
					}
				}
				else if (_specifiedValue is Array)
				{
					var i : int;
					var specValue : Array = (_specifiedValue as Array).concat();
					if (specValue[i] is Cloneable)
					{
						i = specValue.length;
						while (i--)
						{
							specValue[i] = Cloneable(specValue[i]).clone(true);
						}
					}
					prop._specifiedValue = specValue;
					if (_computedValue)
					{
						var compValue : Array = (_computedValue as Array).concat();
						if (compValue[i] is Cloneable)
						{
							i = compValue.length;
							while (i--)
							{
								compValue[i] = Cloneable(compValue[i]).clone(true);
							}
						}
						prop._computedValue = compValue;
					}
				}
				else
				{
					prop._specifiedValue = _specifiedValue;
					prop._computedValue = _computedValue;
				}
			}
			else
			{
				prop._specifiedValue = _specifiedValue;
				prop._computedValue = _computedValue;
			}
			return prop;
		}
	
		//----------------------         Private / Protected Methods        ----------------------//
		protected function preprocessCalculation(val : Object) : void
		{
			var expression : String = val.substring(5, val.length - 1);
			_calculation = CSSCalculationGroup.
				PrepareCalculation(String(expression));
		}
		
		protected function resolveCalculation(
			reference : Number, context : ICSSCalculationContext = null) : Number
		{
			return _calculation.resolve(reference, context);
		}
	}
}