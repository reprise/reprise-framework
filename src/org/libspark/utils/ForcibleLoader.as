/*
 * ForcibleLoader
 * 
 * Licensed under the MIT License
 * 
 * Copyright (c) 2007-2009 BeInteractive! (www.be-interactive.org) and
 *                         Spark project  (www.libspark.org)
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 */
package org.libspark.utils
{
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.errors.EOFError;
	
	/**
	 * Loads a SWF file as version 9 format forcibly even if version is under 9.
	 * 
	 * Usage:
	 * <pre>
	 * var loader:Loader = Loader(addChild(new Loader()));
	 * var fLoader:ForcibleLoader = new ForcibleLoader(loader);
	 * fLoader.load(new URLRequest('swf7.swf'));
	 * </pre>
	 * 
	 * @author yossy:beinteractive
	 * @see http://www.be-interactive.org/?itemid=250
	 * @see http://fladdict.net/blog/2007/05/avm2avm1swf.html
	 */
	public class ForcibleLoader
	{
		private var m_request : URLRequest;
		private var m_data : ByteArray;
		private var m_totalSize : int = -1;
		
		
		public function ForcibleLoader(loader:Loader)
		{
			this.loader = loader;
			m_data = new ByteArray();
			m_data.endian = Endian.LITTLE_ENDIAN;
			
			_stream = new URLStream();
			_stream.addEventListener(Event.COMPLETE, completeHandler);
			_stream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			_stream.addEventListener(ProgressEvent.PROGRESS, progressHandler);
		}
		
		private var _loader:Loader;
		private var _stream:URLStream;
		
		public function get loader():Loader
		{
			return _loader;
		}
		
		public function set loader(value:Loader):void
		{
			_loader = value;
		}
		
		public function load(request:URLRequest):void
		{
			_stream.load(request);
			m_request = request;
		}
		
		public function bytesLoaded() : int
		{
			return m_data.length;
		}
		
		public function bytesTotal() : int
		{
			if (m_totalSize == -1 && m_data.length >= 8)
			{
				m_data.position = 4;
				m_totalSize = m_data.readInt();
			}
			return m_totalSize || 0;
		}
		
		private function completeHandler(event:Event):void
		{
			m_data.position = 0;
			_stream.close();
			
			if (isCompressed(m_data)) {
				uncompress(m_data);
			}
			
			var version:uint = uint(m_data[3]);
			
			if (version < 9) {
				updateVersion(m_data, 9);
			}
			if (version > 7) {
				flagSWF9Bit(m_data);
			}
			else {
				insertFileAttributesTag(m_data);
			}
			
			loader.loadBytes(m_data);
		}
		
		private function isCompressed(bytes:ByteArray):Boolean
		{
			return bytes[0] == 0x43;
		}
		
		private function uncompress(bytes:ByteArray):void
		{
			var cBytes:ByteArray = new ByteArray();
			cBytes.writeBytes(bytes, 8);
			bytes.length = 8;
			bytes.position = 8;
			cBytes.uncompress();
			bytes.writeBytes(cBytes);
			bytes[0] = 0x46;
			cBytes.length = 0;
		}
		
		private function getBodyPosition(bytes:ByteArray):uint
		{
			var result:uint = 0;
			
			result += 3; // FWS/CWS
			result += 1; // version(byte)
			result += 4; // length(32bit-uint)
			
			var rectNBits:uint = bytes[result] >>> 3;
			result += (5 + rectNBits * 4) / 8; // stage(rect)
			
			result += 2;
			
			result += 1; // frameRate(byte)
			result += 2; // totalFrames(16bit-uint)
			
			return result;
		}
		
		private function findFileAttributesPosition(offset:uint, bytes:ByteArray):uint
		{
			bytes.position = offset;
			
			try {
				for (;;) {
					var byte:uint = bytes.readShort();
					var tag:uint = byte >>> 6;
					if (tag == 69) {
						return bytes.position - 2;
					}
					var length:uint = byte & 0x3f;
					if (length == 0x3f) {
						length = bytes.readInt();
					}
					bytes.position += length;
				}
			}
			catch (e:EOFError) {
			}
			
			return NaN;
		}
		
		private function flagSWF9Bit(bytes:ByteArray):void
		{
			var pos:uint = findFileAttributesPosition(getBodyPosition(bytes), bytes);
			if (!isNaN(pos)) {
				bytes[pos + 2] |= 0x08;
			}
		}
		
		private function insertFileAttributesTag(bytes:ByteArray):void
		{
			var pos:uint = getBodyPosition(bytes);
			var afterBytes:ByteArray = new ByteArray();
			afterBytes.writeBytes(bytes, pos);
			bytes.length = pos;
			bytes.position = pos;
			bytes.writeByte(0x44);
			bytes.writeByte(0x11);
			bytes.writeByte(0x08);
			bytes.writeByte(0x00);
			bytes.writeByte(0x00);
			bytes.writeByte(0x00);
			bytes.writeBytes(afterBytes);
			afterBytes.length = 0;
		}
		
		private function updateVersion(bytes:ByteArray, version:uint):void
		{
			bytes[3] = version;
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			loader.dispatchEvent(event.clone());
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			loader.dispatchEvent(event.clone());
		}
		
		private function progressHandler(event:ProgressEvent):void
		{
			_stream.readBytes(m_data, m_data.length, _stream.bytesAvailable);
		}
	}
}