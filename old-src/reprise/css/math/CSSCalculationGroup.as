/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

/**
 * @author till
 */
package reprise.css.math
{

	public class CSSCalculationGroup extends AbstractCSSCalculation
	{
		//----------------------             Public Properties              ----------------------//
		public static const OPERATOR_PLUS : String = '+';
		public static const OPERATOR_MINUS : String = '-';
		public static const OPERATOR_MULTIPLY : String = '*';
		public static const OPERATOR_DIVIDE : String = '/';
		public static const OPERATOR_MODULO : String = 'mod';
		//----------------------       Private / Protected Properties       ----------------------//
		protected static var g_operations : Object = initializeOperations();
		//note that we ignore absolute value suffixes (ie, pt and px) for now
		protected static var g_tokenizer : RegExp = 
			/(?<!\w)binding(?=\(\()|(?<=(?<!\w)binding)\(\(\s*[\w_\-.:#\[\] ]+\s*,\s*[\w_]+\s*\)\)|(?<=\d)pt|(?<=\d)px|[()]|mod|[+\-*\/]|(?<!\w)[0-9.][0-9.exEX]*|%/g;
		
		protected var _operand1 : Object;
		protected var _operand2 : Object;
		protected var _operator : String;
		protected var _operation : Function;
		
		//----------------------               Public Methods               ----------------------//
		public static function PrepareCalculation(
			expression : String) : CSSCalculationGroup
		{
			return parse(expression);
		}
	
		public function CSSCalculationGroup(
			operator : String, operand1 : Object, operand2 : Object)
		{
			setOperator(operator);
			_operand1 = operand1;
			_operand2 = operand2;
		}
	
		public function setOperand1(operand : Object) : void
		{
			_operand1 = operand;
		}
		public function setOperand2(operand : Object) : void
		{
			_operand2 = operand;
		}
		public function setOperator(operator : String) : void
		{
			_operator = operator;
			_operation = g_operations[operator];
		}
	
		public override function resolve(
			reference : Number, context : ICSSCalculationContext = null) : Number
		{
			//TODO: we should probably profile this to see if it is efficent enough
			var operand1 : Number = (_operand1 is Number ? _operand1 as Number :
				AbstractCSSCalculation(_operand1).resolve(reference, context));
			var operand2 : Number = (_operand2 is Number ? _operand2 as Number :
				AbstractCSSCalculation(_operand2).resolve(reference, context));
			var result: Number = _operation(operand1, operand2);
			return result;
		}
		public function toString() : String
		{
			return 'CSSCalculationGroup: operator ' + _operator +
				', operand1 (' + _operand1.toString() +
				'), operand2 (' + _operand2.toString() + ')';
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected static function initializeOperations() : Object
		{
			var operations : Object = {};
			operations['+'] = operationPlus;
			operations['-'] = operationMinus;
			operations['*'] = operationMultiply;
			operations['/'] = operationDivide;
			operations['mod'] = operationModulo;
			operations['^'] = operationPow;
			return operations;
		}
		
		protected static function operationPlus(
			operand1 : Number, operand2 : Number) : Number
		{
			return operand1 + operand2;
		}
		protected static function operationMinus(
			operand1 : Number, operand2 : Number) : Number
		{
			return operand1 - operand2;
		}
		protected static function operationMultiply(
			operand1 : Number, operand2 : Number) : Number
		{
			return operand1 * operand2;
		}
		protected static function operationDivide(
			operand1 : Number, operand2 : Number) : Number
		{
			return operand1 / operand2;
		}
		protected static function operationModulo(
			operand1 : Number, operand2 : Number) : Number
		{
			return operand1 % operand2;
		}
		protected static function operationPow(
			operand1 : Number, operand2 : Number) : Number
		{
			return Math.pow(operand1, operand2);
		}
		
		
		
		protected static function parse(expression : String) : CSSCalculationGroup
		{
			var tokens : Array = tokenize(expression);
			var ops : Array = [];
			var vals : Array = [];
			
			while(tokens.length)
			{
				var token : String = String(tokens.shift());
				switch (token)
				{
					case '(' :
					{
						ops.push(token);
						break;
					}
					case ')' :
					{
						while (ops[ops.length - 1] != '(')
						{
							reduce(ops, vals);
						}
						ops.pop();
						break;
					}
					case '^':
					case '*':
					case '/':
					case 'mod':
					case '+':
					case '-':
					{
						if (ops[ops.length-1] != '(')
						{
							reduce(ops, vals);
						}
						ops.push(token);
						break;
					}
					case 'binding':
					{
						token = tokens.shift();
						vals.push(new CSSCalculationBinding(token));
						break;
					}
					default :
					{
						if (tokens[0] == '%')
						{
							vals.push(new CSSCalculationPercentage(token));
							tokens.shift();
						}
						else
						{
							vals.push(parseFloat(token));
							if (tokens[0] == 'px' || tokens[0] == 'pt')
							{
								tokens.shift();
							}
						}
					}
				}
			}
			//TODO: replace this ugly hack by some better means to deal with a 
			//calculation that doesn't contain more than one operand (and no operation)
			if (!(vals[0] is CSSCalculationGroup))
			{
				return new CSSCalculationGroup(
					CSSCalculationGroup.OPERATOR_PLUS, vals[0], 0);
			}
			return vals[0];
		}
		protected static function tokenize(expression : String) : Array
		{
			//clean whitespace
			expression = expression.replace(/\s*([+\-*\^()])\s*/g, '$1'), 
			expression = 
				'(((' + expression.split('(').join('((').split(')').join('))') + ')))';
			var guard : int = 100;
			var tokens : Array = [];
			var result : Array;
			while ((result = g_tokenizer.exec(expression)) && guard--)
			{
				var token : String = result[0];
				switch(token)
				{
					case '^' : 
					case '*' : 
					case '/' : 
					case 'mod' : 
					{
						tokens.push(')');
						tokens.push(token);
						tokens.push('(');
						break;
					}
					case '+' : 
					case '-' :
					{
						tokens.push(')');
						tokens.push(')');
						tokens.push(token);
						tokens.push('(');
						tokens.push('(');
						break;
					}
					case null:
					{
						break;
					}
					default:
					{
						tokens.push(token);
					};
				}
			}
			return tokens;
		}
		
		protected static function reduce(ops : Array, vals : Array) : void
		{
			var val1 : Object = vals[vals.length - 2];
			var val2 : Object = vals[vals.length - 1];
			vals.length -= 2;
			vals.push(new CSSCalculationGroup(String(ops.pop()), val1, val2));
		}
	}
}