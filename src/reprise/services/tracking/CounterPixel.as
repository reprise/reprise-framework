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

package reprise.services.tracking
{ 
	/**
	 * @author Till Schneidereit
	 * 
	 * Code only implementation of the counterpixel system.
	 * 
	 * Usage:
	 * To be compatible with the old counterpixel component, the class uses
	 * _root.tld or _level0.tld to configure its domain. It's possible to
	 * override the result of this automatic configuration using 
	 * {@link CounterPixel#setDomain}
	 * 
	 * Additionally, you can use {@link CounterPixel#setBasePath} to define a path
	 * segment that gets prepended to each CounterPixel string.
	 * Example: If all your CounterPixels start with 
	 * "specials/nbc_superspecial/" you could use
	 * CounterPixel.getInstance().setBasePath("specials/nbc_superspecial/").
	 * 
	 * If you want to use CounterPixels for another brand than nivea, use
	 * {@link CounterPixel#setBrandName} to set the brand
	 * 
	 * If you enable debugging with {@link CounterPixel#setDebug}, the 
	 * CounterPixels are traced as well.
	 */
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;		
	public class CounterPixel implements ITrackingService
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var COUNTER_SCRIPT_PATH : String = "/cgi-bin/PageImp.exe?";
		
		protected static var g_instance : CounterPixel;
		
		protected var m_brand : String = "nivea";
		protected var m_domain : String;
		protected var m_TLD : String;
		protected var m_debug : Boolean = false;
	
		protected var m_basePath : String = "";
		protected var m_stage : Stage;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		/**
		 * @return singleton instance of CounterPixelWrapper
		 */
		public static function getInstance() : CounterPixel
		{
			if (!g_instance)
			{
				g_instance = new CounterPixel();
			}
			return g_instance;
		}
		
		public function CounterPixel()
		{
		}
		public function setStage(stage : Stage) : void
		{
			m_stage = stage;
			init();
		}
		
		public function track (trackingId : String) : void
		{
			callPixel(trackingId);
		}
		
		/**
		 * calls a counterpixel with the given name
		 */
		public function callPixel(pixel:String) : void
		{
			if (!m_stage)
			{
				throw new Error('you need to give the CounterPixel ' + 
					'a Stage reference before invoking callPixel');
			}
			pixel = m_basePath + pixel;
			pixel = removeSlash(pixel);
			pixel = removeSpaces(pixel);
			pixel = parseVars(pixel);
			
			if(!pixel.length)
			{
				return;
			}
			
			var firstPart:String = String(pixel.split( "/" )[0]).toLowerCase();
			if(firstPart == m_brand.toLowerCase())
			{
				trace("\n******************************************************************************************************\nWARNING!\nThis Counterpixel semms to be wrong. Please make sure that \"Brand\" is not a part of \"Pixel\"!\n******************************************************************************************************\n:" + pixel);
			}
			
			var pixel1:String = getHost(0) + COUNTER_SCRIPT_PATH + "/" + m_brand + "/" + m_domain + "/" + pixel;
			var pixel2:String = getHost(1) + COUNTER_SCRIPT_PATH + "/" + m_brand + "/" + m_domain + "/" + pixel;

			if(m_stage.loaderInfo.loaderURL.substr(0,7).toLowerCase() != "file://")
			{
				var loader : URLLoader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, pixelLoader_complete);
				loader.addEventListener(IOErrorEvent.IO_ERROR, pixelLoader_ioError);
				loader.load(new URLRequest(pixel1));
				loader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, pixelLoader_complete);
				loader.addEventListener(IOErrorEvent.IO_ERROR, pixelLoader_ioError);
				loader.load(new URLRequest(pixel2));
			}
			
			if(m_debug)
			{
				log("d COUNTERPIXEL 1: " + pixel1);
				log("d COUNTERPIXEL 2: " + pixel2);
			}
		}
		
		/**
		 * starts and stops debugging of the counterpixels
		 */
		public function setDebug(debug:Boolean) : void
		{
			m_debug = debug;
		}
		/**
		 * starts and stops debugging of the counterpixels
		 */
		public function getDebug() : Boolean
		{
			return m_debug;
		}
		
		/**
		 * sets the brandname to use for the counterpixels
		 */
		public function setBrandName(brandName:String) : void
		{
			m_brand = brandName;
		}
		/**
		 * @return the brandname used for the counterpixels
		 */
		public function getBrandName() : String
		{
			return m_brand;
		}
		
		/**
		 * sets the domain to use for the counterpixels
		 */
		public function setDomain(domain:String) : void
		{
			m_domain = domain;
		}
		/**
		 * @return the domain used for the counterpixels
		 */
		public function getDomain() : String
		{
			return m_domain;
		}
		
		/**
		 * sets the TLD to use for the counterpixels
		 */
		public function setTLD(tld:String) : void
		{
			m_TLD = tld;
		}
		/**
		 * @return the TLD used for the counterpixels
		 */
		public function getTLD() : String
		{
			return m_TLD;
		}
		
		/**
		* setter for the basePath property
		*/
		public function setBasePath (value:String) : void
		{
			m_basePath = value;
		}
		/**
		* getter for the basePath property
		*/
		public function getBasePath() : String
		{
			return m_basePath;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
	    protected function init() : void
	    {
			Security.allowDomain(getHost(0));
			Security.allowDomain(getHost(1));
			
			var parameters : Object = m_stage.loaderInfo.parameters;
			
			if (!m_domain)
			{
				if (m_TLD)
				{
					m_domain = m_TLD;
				}
				else if (parameters.tld)
				{
					m_domain = parameters.tld;
				}
				else if (parameters.language_short_id)
				{
					m_domain = parameters.language_short_id;
				}
				else if (parameters.hostname && parameters.hostname.indexOf('nivea.') != -1)
				{
					m_domain = parameters.hostname.split('nivea.').pop();
				}
				
				if(!m_domain || !m_domain.length)
				{
					m_domain = 'com';
				}
			}
			
			if (!m_TLD)
			{
				m_TLD = m_domain;
			}
		}
		
		protected function pixelLoader_complete(e:Event):void
		{
			URLLoader(e.target).removeEventListener(Event.COMPLETE, pixelLoader_complete);
			URLLoader(e.target).removeEventListener(
				IOErrorEvent.IO_ERROR, pixelLoader_ioError);
		}
		
		protected function pixelLoader_ioError(e:IOErrorEvent):void
		{
			log('e woops. something went wrong while loading counterpixel');
		}
		
		
		protected function parseVars(s:String) : String
		{
			var tmp:String	= s;
			while( (tmp.indexOf('<') != -1) && (tmp.indexOf('>') != -1) )
			{
				var begin:Number = tmp.lastIndexOf( '<' );
				var end:Number = tmp.lastIndexOf( '>' );
				var varname:String = tmp.substr( begin + 1, end - begin - 1 );
				//@FIXME
				var x:String;// = _root[varname];
				if( x == null )
				{
					x	= "";
				}
				tmp = tmp.split("<" + varname + ">").join(x);
			}
			return tmp;
		}
		protected function removeSlash(s:String) : String
		{
			while( s.charAt(0) == "/" )
			{
				s = s.substr(1);
			}
			return s;
		}
		
		protected function removeSpaces(s:String) : String
		{
			while(s.charAt(0) == " ")
			{
				s = s.substr(1);
			}
			
			while(s.substr(s.length - 1) == " ")
			{
				s	= s.substr(0, s.length - 1);
			}
			return s;
		}
		protected function getHost(pixelNumber: Number) : String
		{
			var pixelStr:String = 'counterpixel';
			if( pixelNumber > 0 )
			{
				pixelStr += pixelNumber.toString();
			}
			return 'http://' + pixelStr + '.nivea.' + m_TLD;
		}
	}
}