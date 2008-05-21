/*
 * HTML Parser By John Resig (ejohn.org)
 * http://ejohn.org/files/htmlparser.js
 * Original code by Erik Arvidsson, Mozilla Public License
 * http://erik.eae.net/simplehtmlparser/simplehtmlparser.js
 * Ported to AS3 by Till Schneidereit (blog.tillschneidereit.de)
 *
 * // Use like so:
 * HTMLParser(htmlString, {
 *     start: function(tag, attrs, unary) {},
 *     end: function(tag) {},
 *     chars: function(text) {},
 *     comment: function(text) {}
 * });
 *
 * // or to get an XML string:
 * HTMLtoXML(htmlString);
 *
 */
package reprise.utils
{
	public class HTMLParser
	{
		// Regular Expressions for parsing tags and attributes
		protected static const startTag : RegExp = 
			/^<(\w+)((?:\s+\w+(?:\s*=\s*(?:(?:"[^"]*")|(?:'[^']*')|[^>\s]+))?)*)\s*(\/?)>/;
		protected static const endTag : RegExp = /^<\/(\w+)[^>]*>/;
		protected static const attr : RegExp = 
			/(\w+)(?:\s*=\s*(?:(?:"((?:\\.|[^"])*)")|(?:'((?:\\.|[^'])*)')|([^>\s]+)))?/g;
		
		// Empty Elements - HTML 4.01
		protected static const empty : Object = makeMap(
			"area,base,basefont,br,col,frame,hr,img,input,isindex,link,meta,param,embed");
		
		// Block Elements - HTML 4.01
		protected static const block : Object = makeMap(
			"address,applet,blockquote,button,center,dd,del,dir,div,dl,dt,fieldset," + 
			"form,frameset,hr,iframe,ins,isindex,li,map,menu,noframes,noscript,object," + 
			"ol,p,pre,script,table,tbody,td,tfoot,th,thead,tr,ul");
		
		// Inline Elements - HTML 4.01
		protected static const inline : Object = makeMap(
			"a,abbr,acronym,applet,b,basefont,bdo,big,br,button,cite,code,del,dfn,em," + 
			"font,i,iframe,img,input,ins,kbd,label,map,object,q,s,samp,script,select," + 
			"small,span,strike,strong,sub,sup,textarea,tt,u,var");
		
		// Elements that you can, intentionally, leave open
		// (and which close themselves)
		protected static const closeSelf : Object = makeMap(
			"colgroup,dd,dt,li,options,p,td,tfoot,th,thead,tr");
		
		// Attributes that have their values filled in disabled="disabled"
		protected static const fillAttrs : Object = makeMap(
			"checked,compact,declare,defer,disabled,ismap,multiple,nohref,noresize," + 
			"noshade,nowrap,readonly,selected");
		
		// Special Elements (can contain anything)
		protected static const special : Object = makeMap("script,style");
		
		
		public static function HTMLtoXML(html : String) : String
		{
			var results : String = "";
			
			parse(html, {
				start: function(tag : String, attrs : Array, unary : Boolean) : void
				{
					results += "<" + tag;
			
					for ( var i : int = 0; i < attrs.length; i++ )
					{
						results += " " + attrs[i].name + '="' + attrs[i].escaped + '"';
					}
			
					results += (unary ? "/" : "") + ">";
				},
				end: function(tag : String) : void
				{
					results += "</" + tag + ">";
				},
				chars: function(text : String) : void
				{
					results += text;
				},
				comment: function(text : String) : void
				{
					results += "<!--" + text + "-->";
				}
			});
			
			return results;
		}
		
		public static function parse(html : String, handler : Object) : void
		{
			var index : int;
			var chars : Boolean;
			var match : Array;
			var stack : Array = [];
			var last : String = html;
			var text : String;
			stack.last = function() : Object
			{
				return this[ this.length - 1 ];
			}
	
			while (html)
			{
				chars = true;
	
				// Make sure we're not in a script or style element
				if ( !stack.last() || !special[ stack.last() ] )
				{
					// Comment
					if ( html.indexOf("<!--") == 0 )
					{
						index = html.indexOf("-->");
		
						if ( index >= 0 )
						{
							if ( handler.comment )
							{
								handler.comment( html.substring( 4, index ) );
							}
							html = html.substring( index + 3 );
							chars = false;
						}
		
					// end tag
					}
					else if ( html.indexOf("</") == 0 )
					{
						match = html.match( endTag );
		
						if ( match )
						{
							html = html.substring( match[0].length );
							match[0].replace( endTag, parseEndTag );
							chars = false;
						}
		
					// start tag
					}
					else if ( html.indexOf("<") == 0 )
					{
						match = html.match( startTag );
		
						if ( match )
						{
							html = html.substring( match[0].length );
							match[0].replace( startTag, parseStartTag );
							chars = false;
						}
					}
	
					if ( chars )
					{
						index = html.indexOf("<");
						
						text = index < 0 ? html : html.substring( 0, index );
						html = index < 0 ? "" : html.substring( index );
						
						if ( handler.chars )
						{
							handler.chars( text );
						}
					}
	
				}
				else
				{
					html = html.replace(new RegExp("(.*)<\/" + stack.last() + "[^>]*>"), 
						function(all : String, text : String) : String
						{
							text = text.replace(/<!--(.*?)-->/g, "$1").
								replace(/<!\[CDATA\[(.*?)]]>/g, "$1");
		
							if (handler.chars)
							{
								handler.chars( text );
							}
		
							return "";
						});
	
					parseEndTag( "", stack.last() );
				}
	
				if ( html == last )
					throw "Parse Error: " + html;
				last = html;
			}
			
			// Clean up any remaining tags
			parseEndTag();
	
			function parseStartTag(tag : String, tagName : String, rest : String, 
				unaryStr : String, index : int, match : String) : void
			{
				if ( block[ tagName ] )
				{
					while ( stack.last() && inline[ stack.last() ] )
					{
						parseEndTag( "", stack.last() );
					}
				}
	
				if ( closeSelf[ tagName ] && stack.last() == tagName )
				{
					parseEndTag( "", tagName );
				}
	
				var unary : Boolean = empty[ tagName ] || Boolean(unary);
	
				if ( !unary )
				{
					stack.push( tagName );
				}
				
				if ( handler.start )
				{
					var attrs : Array = [];
		
					rest.replace(attr, function(match : String, name : String) : void
					{
						var value : String = arguments[2] ? arguments[2] :
							arguments[3] ? arguments[3] :
							arguments[4] ? arguments[4] :
							fillAttrs[name] ? name : "";
						
						attrs.push(
						{
							name: name,
							value: value,
							escaped: value.replace(/(^|[^\\])"/g, '$1\\\"') //"
						});
					});
		
					if ( handler.start )
					{
						handler.start( tagName, attrs, unary );
					}
				}
			}
	
			function parseEndTag(tag : String = '', tagName : String = '', ...rest) : void
			{
				var pos : int;
				// If no tag name is provided, clean shop
				if (!tagName)
				{
					pos = 0;
				}
					
				// Find the closest opened tag of the same type
				else
				{
					pos = stack.length;
					while(pos--)
					{
						if (stack[pos] == tagName)
						{
							break;
						}
					}
				}
				
				if (pos >= 0)
				{
					// Close all the open elements, up the stack
					var i : int = stack.length;
					while(--i >= pos)
					{
						if (handler.end)
						{
							handler.end(stack[i]);
						}
					}
					
					// Remove the open elements from the stack
					stack.length = pos;
				}
			}
		};
		
		protected static function makeMap(str : String) : Object
		{
			var obj : Object = {};
			var items : Array = str.split(",");
			for (var i : int = 0; i < items.length; i++)
			{
				obj[items[i]] = true;
			}
			return obj;
		}
	}
}