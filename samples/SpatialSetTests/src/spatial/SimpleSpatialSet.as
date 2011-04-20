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
	import flash.utils.Dictionary;
	
	/**
	 * Very basic spatial object manager that simply keeps
	 * a list of all managed objects sorted by depth. With the exception
	 * of hit testing (which short circuits after an item is found at 
	 * the largest depth), all query methods are brute force.
	 */
	public class SimpleSpatialSet implements ISpatialSet
	{
		protected var objects:Vector.<ISpatialObject>;
		protected var _worldBounds:Rectangle;
		protected var _sortRequired:Boolean = true;
		
		public function SimpleSpatialSet(worldWidth:uint, worldHeight:uint)
		{
			objects = new Vector.<ISpatialObject>();
			_worldBounds = new Rectangle(0,0,worldWidth, worldHeight);
		}
		
		public function get length():uint
		{
			return objects.length;
		}
		
		public function get worldBounds():Rectangle
		{
			return _worldBounds;
		}
		
		public function add(item:ISpatialObject):void
		{
			objects.push(item);
			_sortRequired = true;
		}
		
		public function remove(item:ISpatialObject):void
		{
			var index:int = objects.indexOf(item);
			if (index >= 0)
				objects.splice(index, 1);
		}
		
		public function queryObjectAtPoint(point:Point, sampleTexture:Boolean = false):ISpatialObject
		{
			depthSort();
			for (var i:int = 0; i < length; i++)
			{
				var object:ISpatialObject = objects[i];
				if (object.intersectsPoint(point.x, point.y, sampleTexture))
				    return object;
			}
			return null;
		}
		
		public function queryObjectsAtPoint(point:Point, out:Vector.<ISpatialObject>, sampleTexture:Boolean = false):int
		{
			var total:int = 0;
			depthSort();
			for (var i:int = 0; i < length; i++)
			{
				var object:ISpatialObject = objects[i];
				if (object.intersectsPoint(point.x, point.y))
				{
					out.push(object);
					total++;
				}	
			}
			return total;
		}
		
		public function queryObjectsInRect(region:Rectangle, out:Vector.<ISpatialObject>):int
		{
			var total:int = 0;
			for (var i:int = 0; i < length; i++)
			{
				var object:ISpatialObject = objects[i];
				if (object.intersectsRect(region.x, region.y, region.width, region.height))
				{
					out.push(object);
					total++;
				}	
			}
			return total;
		}
		
		public function dispose():void
		{
			objects.length = 0; 
		}
		
		protected function depthSort():void
		{
			if (_sortRequired)
			{
				objects = objects.sort(compare);
				_sortRequired = false;
			}
		}
		
		protected function compare(x:ISpatialObject, y:ISpatialObject):Number
		{
			if (x.depth < y.depth)
				return 1;
			else if (x.depth > y.depth)
				return -1;
			else
				return 0;
		}
				
		public function queryAllCollisions(notification:Function):void
		{
			var completed:Dictionary = new Dictionary();
			
			for (var i:int = 0; i < length; i++)
			{
				var current:ISpatialObject = objects[i];
				checkCollisions(current, notification, completed);
				completed[current] = true;
			}
		}
		
		public function queryCollisions(object:ISpatialObject, notification:Function):void
		{
			checkCollisions(object, notification, new Dictionary());
		}
		
		private function checkCollisions(current:ISpatialObject, notification:Function, completed:Dictionary):void
		{
			for (var j:int = 0; j < length; j++)
			{
				var candidate:ISpatialObject = objects[j];
				if (current != candidate && !completed[candidate])
				{
					var dx:Number = current.x - candidate.x;
					var dy:Number = current.y - candidate.y;
					var dist:Number = Math.sqrt(dx * dx + dy * dy);
					
					if (dist <= current.boundingRadius + candidate.boundingRadius)
						notification(current, candidate);
				}
			}	
		}

	}
}