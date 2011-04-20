/*
* M2D 
* .....................
* 
* Author: Corey Lucier
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
package spatial 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Interface used to represent a spatial object instance.
	 */ 
	public interface ISpatialObject
	{
		function get boundingRect():Rectangle;
		function get boundingRadius():Number;
				
		function set x(value:Number):void;
	    function get x():Number;
		
		function set y(value:Number):void;
		function get y():Number;
				
		function set height(value:Number):void
		function get height():Number;
		
		function set width(value:Number):void
		function get width():Number;
		
		function set depth(value:Number):void;
		function get depth():Number;
		
		function set registration(value:Point):void;
		function get registration():Point;
			
		function set rotation(value:Number):void;
		function get rotation():Number;
		
		function set scale(value:Point):void;
		function get scale():Point;
		
		function set proxy(value:ISpatialObjectProxy):void;
		function get proxy():ISpatialObjectProxy;
		
		function intersectsPoint(x:Number, y:Number, sampleTexture:Boolean=false):Boolean;
		function intersectsRect(x:Number, y:Number, width:Number, height:Number):Boolean;
	}
}