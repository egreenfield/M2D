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
	 * Interface utilized by spatial object managers (quad trees,
	 * hierarchical grids, etc.).
	 */ 
	public interface ISpatialSet
	{
		function get length():uint;
		function get worldBounds():Rectangle;
		
		function add(item:ISpatialObject):void
		function remove(item:ISpatialObject):void
			
		function queryObjectAtPoint(point:Point, sampleTexture:Boolean=false):ISpatialObject;
		function queryObjectsAtPoint(point:Point, out:Vector.<ISpatialObject>, sampleTexture:Boolean=false):int;
		function queryObjectsInRect(region:Rectangle, out:Vector.<ISpatialObject>):int;
		function queryCollisions(object:ISpatialObject, notification:Function):void;
		function queryAllCollisions(notification:Function):void
		
		function dispose():void
	}
}