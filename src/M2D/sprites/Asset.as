/*
* M2D 
* .....................
* 
* Author: Ely Greenfield
* Copyright (c) Adobe Systems 2011
* https://github.com/egreenfield/M2D
* 
* 
* Licence Agreement
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
*/
package M2D.sprites
{
	import M2D.worlds.BatchTexture;
	
	public class Asset
	{
		public var width:Number;
		public var height:Number;		
		public var texture:BatchTexture;
		public var library:SymbolLibrary;
		
		public var cellColumnCount:int = 1;
		public var cellRowCount:int = 1;
		
		public var offsetLeft:Number = 0;
		public var offsetTop:Number = 0;
		public var hasAlphaChannel:Boolean = false;
		protected var _frameCount:uint;
		
		public function Asset()
		{
		}
		
		public function createActor():Actor
		{
			var newActor:Actor = new Actor();
			newActor.asset = this;
			newActor.active = true;
			return newActor;
		}		
		
		public function get frameCount():uint
		{
			return isNaN(_frameCount) ? 
				cellColumnCount * cellRowCount : _frameCount;
		}
		
		public function set frameCount(value:uint):void
		{
			_frameCount = value;
		}
	}
}
