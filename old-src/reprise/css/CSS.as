/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css
{
	import reprise.core.reprise;
	import reprise.css.propertyparsers.RuntimeParser;
	import reprise.data.collection.IndexedArray;
	import reprise.events.CommandEvent;
	import reprise.events.ResourceEvent;
	import reprise.external.AbstractResource;
	import reprise.external.BitmapResource;
	import reprise.external.ResourceLoader;
	import reprise.utils.StringUtil;

	import flash.events.Event;
	import flash.utils.getTimer;
	
	use namespace reprise;

	public class CSS extends AbstractResource
	{
		//----------------------             Public Properties              ----------------------//
		public static const PROPERTY_TYPE_STRING : uint = 1;
		public static const PROPERTY_TYPE_INT : uint = 2;
		public static const PROPERTY_TYPE_FLOAT : uint = 3;
		public static const PROPERTY_TYPE_BOOL : uint = 4;
		public static const PROPERTY_TYPE_URL : uint = 5;
		public static const PROPERTY_TYPE_COLOR : uint = 6;
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var g_idSource : int;
		
		
		protected var _cssFile : CSSImport;
		protected var _loader : ResourceLoader;
		protected var _imagePreloadingResource : ResourceLoader;
		protected var _importQueue : Array;
		protected var _cssSegments : IndexedArray;
		protected var _declarationList : CSSDeclarationList;
		protected var _cssVariables : Object;
		
		protected var _baseURL : String;
		protected var _runtimeParserRegistered : Boolean;
		
		protected var _cleanupTime : int;
		protected var _parseTime : int;
		protected var _importsLoaded : int;
		protected var _importsTotal : int;
		private var _stylesheetURLs : Array;

		
		//----------------------               Public Methods               ----------------------//
		public function CSS(url : String = null)
		{
			_id = g_idSource++;
			
			_loader = new ResourceLoader();
			_cssVariables = {};
			
			if (url)
			{
				_url = url;
			}
			_loader.addEventListener(Event.COMPLETE, loader_complete);
		}
		
		public override function execute(...rest) : void
		{
			if (_url == null)
			{
				throw new Error('You didn\'t specify an URL for your ' + 
					'CSS resource! Make sure you do this before calling execute!');
				return;
			}
			
			if (!_runtimeParserRegistered)
			{
				CSSDeclaration.registerPropertyCollection(RuntimeParser);
				_runtimeParserRegistered = true;
			}
			
			_didFinishLoading = false;
			_isCancelled = false;
			_parseTime = 0;
			_cleanupTime = 0;
			_importsLoaded = 0;
			_importsTotal = 1;
			_declarationList = new CSSDeclarationList();
			_stylesheetURLs = [];
			_importQueue = [];
			_cssSegments = new IndexedArray();
			setURL(_url);
			_cssFile.setURL(CSSParsingHelper.resolvePathAgainstPath(url(), baseURL()));
			_stylesheetURLs.push(_cssFile.url());
			_loader.addResource(_cssFile);
			_loader.execute();
		}
		
		public override function didSucceed():Boolean
		{
			// provisionally
			//TODO: return sane value
			return true;
		}
		
		public override function cancel() : void
		{
			log('w cancel for CSS is not implemented yet!');
			_isCancelled = true;
			dispatchEvent(new ResourceEvent(Event.CANCEL));
		}
		
		public override function isExecuting():Boolean
		{
			// @FIXME
			return false;
		}
		
		public function getStyleForSelectorPath(sp : String) : CSSDeclaration
		{
			return getStyleForEscapedSelectorPath(escapeSelectorPath(sp));
		}
		reprise function getStyleForEscapedSelectorPath(sp : String) : CSSDeclaration
		{
			if (!_declarationList)
			{
				return new CSSDeclaration();
			}
			return _declarationList.getStyleForSelectorsPath(sp);
		}

		public function stylesheetURLs() : Array
		{
			return _stylesheetURLs;
		}

		/**
		 * Escapes a selectorPath and thus prepares it for being processed by the 
		 * css implementation.
		 * 
		 * Use this method of you want to prepare a string once and use it multiple 
		 * times later on.
		 * 
		 * <b>Note:</b>
		 * In order to allow for the preparation of strings that are created by 
		 * concatenating strings that have already been escaped with ones that 
		 * haven't, the escaping process starts after the last escape character, 
		 * i.e. the last '@'.
		 */
		public static function escapeSelectorPath(sp : String) : String
		{
			var stringParts : Array = sp.split('@');
			var input : String = String(stringParts.pop());
			input = input.split(' ').join('@ @'). //escape whitespace
			split('#').join('@@#'). //escape id chars
			split('.').join('@@.'). //escape class chars
			split(':').join('@@:'); //escape pseudo class chars
			
			//add leading escape char
			if (input.charAt(0) != '@')
			{
				input = '@' + input;
			}
			//else remove double leading escape char
			else if (input.charAt(1) == '@')
			{
				input = input.substr(1);
			}
			
			//add trailing escape char
			if (input.charAt(input.length - 1) != '@')
			{
				input += '@';
			}
			
			stringParts.push(input);
			return stringParts.join('@');
		}
		
		public function baseURL() : String
		{
			return _baseURL;
		}
	
		public function setBaseURL(val:String) : void
		{
			_baseURL = val;
		}
				
		/**
		* FileResource facade
		**/
		public override function setURL(src : String) : void
		{
			if (!_cssSegments)
			{
				_cssSegments = new IndexedArray();
			}
			_url = src;
			_cssFile = cssImportWithURL(src);
			_cssSegments[0] = _cssFile;
		}	
		public override function content() : *
		{
			return _declarationList;
		}
		public override function bytesLoaded() : int
		{
			//TODO: Check if we shouldn't return a better status here
			return _importsLoaded;
		}
		public override function bytesTotal() : int
		{
			//TODO: Check if we shouldn't return a better status here
			return _importsTotal;
		}
		
		public function resolveImport(cssImport:CSSImport) : void
		{
			var index:int = _cssSegments.getIndex(cssImport);
			_cssSegments[index] = cssImport.data();
			parseImportsInCSSSegmentWithIndex(index, cssImport.url());
			_importsLoaded++;
			dispatchEvent(new ResourceEvent(ResourceEvent.PROGRESS));
		}
		
		public function parseCSSStringWithBaseURL(str:String, url:String) : void
		{
			url = url || '/';
			var isLoading : Boolean = _importsLoaded < _importsTotal;
			_cssSegments.push(str);
			
			parseImportsInCSSSegmentWithIndex(_cssSegments.length - 1, url);
			
			if (isLoading)
			{
				return;
			}
			
			if (_importQueue.length)
			{
				dequeueImports();
				return;
			}
			
			var result : Boolean = parseCSSSegment(_cssSegments[0]);
			if (!result)
			{
				log('e Error! Couldn\'t parse css string!');
			}
		}
		
		public function addCSSVariableWithNameAndValue(name:String, val:String) : void
		{
			if (_cssVariables[name] != null)
			{
				log('w Warning! CSS Variable with name ' + name + ' is already defined! (' +
					_cssVariables[name] + ' -> ' + val + ')');
				return;
			}
			_cssVariables[name] = val;
		}
		
		public function addCSSVariablesFromObject(obj:Object) : void
		{
			for (var key : String in obj)
			{
				addCSSVariableWithNameAndValue(key, obj[key]);
			}
		}
	
		public function registerProperty(
			name : String, type : uint, inheritable : Boolean = false) : void
		{
			RuntimeParser.registerProperty(name, type, inheritable);
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected function parseCSSVariables() : void
		{
			for (var i : int = 0; i < _cssSegments.length; i++)
			{
				if (_cssSegments[i] is CSSImport)
				{
					log('w CSS import not loaded: ' + CSSImport(_cssSegments[i]).url());
					_cssSegments.splice(i, 1);
					i--;
					continue;
				}
				var seg : CSSSegment = CSSSegment(_cssSegments[i]);
				var parts : Array = seg.content().split('@define ');
		
				for (var j : int = 1; j < parts.length; j++)
				{
					var part : String = parts[j];
					var lbPos : int = part.indexOf(';\n');
					var scPos : int = part.indexOf(';');
					var cutPos : int = scPos == lbPos ? scPos + 1 : scPos;
					
					var varStr : String = part.substring(0, scPos);
					
					var wsPos : int = part.indexOf(' ');
					var varName : String = varStr.substring(0, wsPos);
					var varCnt : String = varStr.substring(wsPos + 1, scPos);
					
					addCSSVariableWithNameAndValue(varName, varCnt);
					parts[j] = part.substr(cutPos + 1);
				}
				seg.setContent(parts.join(''));
			}
		}
		
		protected function replaceCSSVariables() : void
		{
			var i : int = _cssSegments.length;
			while (i--)
			{
				var seg : CSSSegment = CSSSegment(_cssSegments[i]);
				var cnt : String = seg.content();
				for (var varName : String in _cssVariables)
				{
					var varCnt : String = _cssVariables[varName];
					cnt = cnt.split('${' + varName + '}').join(varCnt);
				}
				seg.setContent(cnt);			
			}
		}
		
		protected function parseImportsInCSSSegmentWithIndex(index:int, baseURL:String) : void
		{
			var cssString : String = cleanupCSS(_cssSegments[index]);
			var segments : Array = cssString.split('@import');
			var parsedSegment : CSSSegment;		
			var additionalSegments : Array = [];
	
			parsedSegment = new CSSSegment();
			parsedSegment.setContent(segments[0]);
			parsedSegment.setURL(baseURL);
			_cssSegments[index] = parsedSegment;
			
			for (var i : int = 1; i < segments.length; i++)
			{
				var url : String;
				var pos : int;
				var cssImport : CSSImport;
				var segment : String;
				var segmentContent : String;
	
				segment = segments[i];
				pos = segment.indexOf(';');
				
				url = CSSParsingHelper.parseURL(segment.substring(0, pos), baseURL);
				_stylesheetURLs.push(url);
				cssImport = cssImportWithURL(url);
				_importQueue.push(cssImport);
				_importsTotal++;
				additionalSegments.push(cssImport);
				
				segmentContent = segment.substr(pos + 1);
				if (!StringUtil.isWhitespace(segmentContent))
				{
					parsedSegment = new CSSSegment();
					parsedSegment.setContent(segmentContent);
					parsedSegment.setURL(baseURL);
					additionalSegments.push(parsedSegment);
				}
			}
			
			if (additionalSegments.length)
			{
				_cssSegments.splice.apply(
					_cssSegments, ([index + 1, 0]).concat(additionalSegments));
			}
		}
	
		protected function dequeueImports() : void
		{
			for (var i : int = 0; i < _importQueue.length; i++)
			{
				_loader.addResource(_importQueue[i]);
			}
			_importQueue = [];
			_loader.execute();
		}
		
		protected function cssImportWithURL(url:String) : CSSImport
		{
			var cssImport : CSSImport = new CSSImport(this);
			cssImport.setTimeout(timeout());
			cssImport.setRetryTimes(retryTimes());
			cssImport.setForceReload(forceReload());
			cssImport.setURL(url);
			return cssImport;
		}
		
		protected override function notifyComplete(success:Boolean) : void
		{
			_didFinishLoading = true;
			dispatchEvent(new CommandEvent(Event.COMPLETE, success));
		}
		
		protected function loader_complete(event:CommandEvent) : void
		{
			if (!event.success)
			{
				log('e CSS "' + url() + '" could not be loaded');
				return;
			}
			
			if (_importQueue.length)
			{
				dequeueImports();
				return;
			}
			
			parseCSS();
		}
	
		protected function parseCSS() : void
		{
			var success : Boolean;
	
			parseCSSVariables();
			replaceCSSVariables();
			
			for (var i : int = 0; i < _cssSegments.length; i++)
			{
				var segment : CSSSegment = _cssSegments[i];
				success = parseCSSSegment(segment);
				if (!success)
				{			
					log('f Error parsing css file "' + segment.url() + 
						'". Make sure that all ' +
						'your used variables are defined (if any).');
					break;
				}
			}
			_cssSegments = new IndexedArray();
			
			var stats : String = '----------------- CSS Stats -----------------\n' +
				' time spent cleaning up strings: ' + _cleanupTime + ' ms\n' +
				' time spent parsing: ' + _parseTime + ' ms\n' +
				'---------------------------------------------';
			log('d ' + stats);
			
			if (!_imagePreloadingResource)
			{
				dispatchEvent(new CommandEvent(Event.COMPLETE, success));
			}
			else
			{
				_imagePreloadingResource.addEventListener(
					Event.COMPLETE, imagePreloader_complete);
				_imagePreloadingResource.execute();
			}
		}
		protected function imagePreloader_complete(event : CommandEvent) : void
		{
			notifyComplete(true);
		}
		
		protected function parseCSSSegment(segment : CSSSegment) : Boolean
		{
			var timestamp : int = getTimer();
			var url : String = segment.url();		
			//split string into class definitions
			var classesArr:Array = segment.content().split("}");
			classesArr.pop();
			
			for (var i : int = 0; i < classesArr.length; i++)
			{
				var cssClassDefArr:Array = classesArr[i].split("{");
				if (cssClassDefArr.length == 2)
				{
					//parse all properties of this class into a declaration
					var declaration : CSSDeclaration = 
						CSSParsingHelper.parseDeclarationString(cssClassDefArr[1], url);
					
					//add assets to preloader queue if necessary
					var preloadProp : CSSProperty = 
						declaration.getStyle('backgroundImagePreload');
					if (preloadProp && preloadProp.valueOf())
					{
						var imageProp : CSSProperty = 
							declaration.getStyle('backgroundImage');
						imageProp && enqueuePreloadableProperty(imageProp);
					}
					
					var classNames:Array = cssClassDefArr[0].split("\n").join(" ").
						split("  ").join(" ").split(", ").join(",").split(",");			
					
					var classNamesLen:int = classNames.length;
					for (var j : int = 0; j < classNamesLen; j++)
					{
						var className:String = classNames[j];
						// --- adding parsed style to declarationlist ---
						_declarationList.addDeclaration(declaration, className);
					}
				}
			}
			_parseTime += getTimer() - timestamp;
			return true;
		}
		
		protected function enqueuePreloadableProperty(prop : CSSProperty) : void
		{
			if (!_imagePreloadingResource)
			{
				_imagePreloadingResource = new ResourceLoader();
			}
			var loader : BitmapResource = 
				new BitmapResource(prop.valueOf() as String, true);
			loader.setCacheBitmap(true);
			loader.setCloneBitmap(false);
			_imagePreloadingResource.addResource(loader);
		}
		
		/**
		* Tidy css in order to get the Flash CSSParser to actually parse it
		**/
		protected function cleanupCSS(cssStr:String) : String
		{
			var timestamp : int = getTimer();		
			// remove all comments to ease parsing
			var arr : Array = cssStr.split( "/*" );
			for ( var i : uint = arr.length; i-- > 1; )
			{
				var block:String = arr[i];
				var commentClosePosition:int = block.indexOf("*/");
				if (commentClosePosition == -1)
				{
					arr[i] = "";
				}
				else
				{
					arr[i] = block.substr(commentClosePosition + 2);
				}
			}
			cssStr = arr.join("");		
			
			//compress string by removing all excess whitespace
			cssStr = cssStr.split("\r\n").join("\n");	// convert windows linebreaks to unix linebreaks
			cssStr = cssStr.split( "\r" ).join( "\n" ); // convert mac linebreaks to unix linebreaks
			
			// remove double linebreaks
			while(cssStr.indexOf("\n\n") > -1)
				cssStr = cssStr.split("\n\n").join("\n");
			
			// convert tabs to spaces	
			cssStr = cssStr.split("\t").join(" ");
			
			// convert double spaces to single spaces
			while(cssStr.indexOf("  ") > -1)
				cssStr = cssStr.split("  ").join(" ");
				
			cssStr = cssStr.split("\n ").join("\n").		// remove spaces at the end of lines
				split(" \n").join("\n").					// remove spaces at the beginning of lines
				split(" {").join("{").						// remove spaces before curly braces
				split("\n{").join("{").						// remove linebreaks before curly braces
				split("}\n").join("}").						// remove linebreaks after curly braces
				//split("} ").join("}").						// remove spaces after curly braces
				split("( ").join("(").						// remove spaces after opening brackets
				split(" )").join(")").						// remove spaces before closing brackets
				split("'").join("").						// remove single quotes
				split("\"").join("").						// remove quotes
				split(" !important").join("!important").	// remove spaces before important tag
				split("> ").join(">").						// remove spaces around child selector
				split(" >").join(">").						// remove spaces around child selector
				split(">").join("> ").						// bring child selector into defined state
				split(" ,").join(",").						// remove spaces before commas
				split(", ").join(",").						// remove spaces after commas
				split(" ;").join(";").						// remove spaces before semicolons
				split("{\n}").join("{}");					// clean empty declarations, because the parser returns nothing otherwise
	
			cssStr = StringUtil.lTrim( cssStr );		
			_cleanupTime += getTimer() - timestamp;
			return cssStr;
		}	
	}
}