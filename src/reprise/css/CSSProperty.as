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
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const UNIT_PIXEL : String = 'px';
		public static const UNIT_EM : String = 'em';
		public static const UNIT_PERCENT : String = '%';
		
		public static const IMPORTANT_FLAG : String = '!important';
		public static const INHERIT_FLAG : String = 'inherit';
		public static const AUTO_FLAG : String = 'auto';
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_id : int = 0;
		
		protected var m_important : Boolean = false;
		protected var m_isRelativeValue : Boolean = false;
		protected var m_inheritsValue : Boolean = false;
	                                    
		protected var m_specifiedValue : Object = null;
		protected var m_computedValue : Object = null;
		
		protected var m_isCalculation : Boolean;
		protected var m_calculation : AbstractCSSCalculation;
		protected var m_calculationResultsCache : Object;
		
		protected var m_unit : String = null;
		
		protected var m_cssFile : String;
	
		protected var m_id : int;
		protected var m_isWeak : Boolean;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSSProperty()
		{
			m_id = g_id++;
		}
		
			
		public function important() : Boolean
		{
			return m_important;
		}
	
		reprise function setImportant(val:Boolean) : void
		{
			m_important = val;
		}
		
		public function unit() : String
		{
			return m_unit;
		}
		
		reprise function setUnit(unitStr:String) : void
		{
			if (unitStr == 'px' || unitStr == 'em')
			{
				m_isRelativeValue = false;
			}
			else if (unitStr == '%')
			{
				setIsRelativeValue(true);
			}
			
			m_unit = unitStr;
		}
		
		public function isRelativeValue() : Boolean
		{
			return m_isRelativeValue;
		}
		
		public function setIsWeak(isWeak : Boolean) : void
		{
			m_isWeak = isWeak;
		}
		
		public function isWeak() : Boolean
		{
			return m_isWeak;
		}
		
		reprise function setIsRelativeValue( bFlag : Boolean ) : void
		{
			m_isRelativeValue = bFlag;
			m_calculationResultsCache = {};
			if (m_specifiedValue)
			{
				setSpecifiedValue(m_specifiedValue);
			}
		}
		
		public function isCalculation() : Boolean
		{
			return m_isCalculation;
		}
	
		reprise function setIsCalculation(value : Boolean) : void
		{
			m_isCalculation = value;
			if (value)
			{
				m_calculationResultsCache = {};
				m_isRelativeValue = true;
				if (m_specifiedValue)
				{
					preprocessCalculation(m_specifiedValue);
				}
			}
		}
		
		reprise function setInheritsValue( bFlag : Boolean ) : void
		{
			m_inheritsValue = bFlag;
		}
		
		public function inheritsValue() : Boolean
		{
			return m_inheritsValue;
		}
		
		public function isAuto() : Boolean
		{
			return m_specifiedValue == 'auto';
		}
		
		public function specifiedValue() : *
		{
			return m_specifiedValue;
		}
	
		reprise function setSpecifiedValue(value : *) : void
		{
			m_specifiedValue = value;
			if (value == 'auto')
			{
				m_computedValue = 0;
			}
			else if (m_isRelativeValue)
			{
				if (m_isCalculation)
				{
					preprocessCalculation(value);
				}
				else
				{
					m_calculation = new CSSCalculationPercentage(value.toString());
				}
			}
			else if (m_unit == 'em')
			{
				m_computedValue = value * 16; //TODO: this has to be changed to make em's relative
			}
			else
			{
				m_computedValue = null;
			}
		}
		
		reprise function setCSSFile(cssFile : String) : void
		{
			m_cssFile = cssFile;
		}
		
		public function cssFile() : String
		{
			return m_cssFile;
		}
		
		public function toString() : String
		{
			var str:String = "property {\n";
			str += "\tspecified Value : " + m_specifiedValue + "\n";
			str += "\tcomputed Value : " + m_computedValue + "\n";
			str += "\tunit : " + m_unit + "\n";
			str += "\timportant : " + m_important + "\n";
			str += "\tweak : " + m_isWeak + "\n";
			return str;
		}	
		
		public function valueOf() : Object
		{
			if (m_computedValue != null)
			{
				return m_computedValue;
			}
			return m_specifiedValue;
		}
		
		public function resolveRelativeValueTo(
			reference : Number, context : ICSSCalculationContext = null) : Number
		{
			if (!m_isRelativeValue)
			{
				return m_specifiedValue is Number && m_specifiedValue || 0;
			}
			if (m_calculationResultsCache[reference+m_specifiedValue.toString()])
			{
				return m_calculationResultsCache[reference+m_specifiedValue.toString()];
			}
			return m_calculationResultsCache[reference+m_specifiedValue.toString()] = 
				resolveCalculation(reference, context);
		}
		
		public function clone(deep : Boolean = false) : Cloneable
		{
			var prop : CSSProperty = new CSSProperty();
			prop.m_important = m_important;
			prop.m_isWeak = m_isWeak;
			prop.m_unit = m_unit;
			prop.m_inheritsValue = m_inheritsValue;
			prop.m_isRelativeValue = m_isRelativeValue;
			if (m_isRelativeValue)
			{
				prop.m_calculationResultsCache = {};
			}
			prop.m_cssFile = m_cssFile;
			
			if (deep)
			{
				if (m_specifiedValue is Cloneable)
				{
					prop.m_specifiedValue = Cloneable(m_specifiedValue).clone(true);
					if (m_computedValue)
					{
						prop.m_computedValue = Cloneable(m_computedValue).clone(true);
					}
				}
				else if (m_specifiedValue is Array)
				{
					var i : int;
					var specValue : Array = (m_specifiedValue as Array).concat();
					if (specValue[i] is Cloneable)
					{
						i = specValue.length;
						while (i--)
						{
							specValue[i] = Cloneable(specValue[i]).clone(true);
						}
					}
					prop.m_specifiedValue = specValue;
					if (m_computedValue)
					{
						var compValue : Array = (m_computedValue as Array).concat();
						if (compValue[i] is Cloneable)
						{
							i = compValue.length;
							while (i--)
							{
								compValue[i] = Cloneable(compValue[i]).clone(true);
							}
						}
						prop.m_computedValue = compValue;
					}
				}
				else
				{
					prop.m_specifiedValue = m_specifiedValue;
					prop.m_computedValue = m_computedValue;
				}
			}
			else
			{
				prop.m_specifiedValue = m_specifiedValue;
				prop.m_computedValue = m_computedValue;
			}
			return prop;
		}
	
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function preprocessCalculation(val : Object) : void
		{
			var expression : String = val.substring(5, val.length - 1);
			m_calculation = CSSCalculationGroup.
				PrepareCalculation(String(expression));
		}
		
		protected function resolveCalculation(
			reference : Number, context : ICSSCalculationContext = null) : Number
		{
			return m_calculation.resolve(reference, context);
		}
	}
}