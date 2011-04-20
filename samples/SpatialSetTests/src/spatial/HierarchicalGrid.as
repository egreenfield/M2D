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
	
	import spatial.ISpatialObject;
	
	/**
	 * Basic (reference) hierarchical hash-grid implementation. This approach 
	 * is much faster than say, a quad tree when the size or position of the
	 * managed spatial objects are changing over time.
	 * 
	 * Based on implementations described in:
	 * 
	 * Hierarchical Hash Grids for Coarse Collision Detection - Schornbaum - 2009
	 * Realtime Collision Detection - Ericson - 2005
	 */
	public class HierarchicalGrid implements ISpatialSet, ISpatialListener
	{				
		protected var hashTable:Vector.<GridNode>;
		protected var objectsAtLevel:Vector.<uint>;
		protected var occupiedLevelsMask:uint;
		
		protected var minCellSize:int;
		protected var maxLevels:int;
		protected var generation:uint;
		
		protected static const BOUNDS_TO_CELL_RATIO:Number = 2.0;
		protected static const LEVEL_RATIO:Number = 2.0;
		protected static const HASH_SIZE:uint = 1024;
		
		private static const LARGE_PRIME_1:int = 0x8da6b343;
		private static const LARGE_PRIME_2:int = 0xd8163841;
		private static const LARGE_PRIME_3:int = 0xcb1ab31f;
			
		/**
		 * Constructor
		 */	
		public function HierarchicalGrid(worldWidth:uint, worldHeight:uint, minObjectSize:int=32)
		{
			minCellSize = minObjectSize;
			_worldBounds = new Rectangle(0, 0, worldWidth, worldHeight);
			initGrid(worldWidth, worldHeight);
		}
					
		/**
		 * Adds a spatial object to the grid-level most appropriate for this
		 * item's bounds. The cell at the given level is chosen based on position
		 * of the candidate item.
		 */
		public function add(item:ISpatialObject):void
		{
			var diameter:Number = 2 * item.boundingRadius;
			var size:Number = minCellSize;
			
			// Find most appropriate level for our item bounds.
			for (var level:Number = 0; size * BOUNDS_TO_CELL_RATIO < diameter; level++)  
				size *= LEVEL_RATIO;

			// Create a grid node for our item and add to appropriate cell (hash
			// bucket) based on its position and level.
			var proxy:GridNode = new GridNode();
			proxy.object = item;
			proxy.level = level;
			item.proxy = proxy;
			addToBucket(proxy, size, level);
		
			// Listen for updates if this object is marked as 'kinetic'.
			if (item is IKineticObject)
				IKineticObject(item).addSpatialListener(this);
			
			_length++;
		}
		
		/**
		 * Remove the item from the its current grid level and cell.
		 */
		public function remove(item:ISpatialObject):void
		{
			var proxy:GridNode = item.proxy as GridNode;
			if (proxy)
			{
				_length--;
				
				if (item is IKineticObject)
					IKineticObject(item).removeSpatialListener(this);
								
				removeFromBucket(proxy);
			}
		}
		
		/**
		 * Finds object (with greatest depth) that intersects the given point.  
		 * If sampleTexture is true, per-pixel hit testing is performed once 
		 * candidates are narrowed down.
		 */
		public function queryObjectAtPoint(point:Point, sampleTexture:Boolean = false):ISpatialObject
		{
			return queryNodesAtPoint(point, null, sampleTexture);
		}
		
		/**
		 * Finds all objects that intersect the given point.  
		 * If sampleTexture is true, per-pixel hit testing is performed once 
		 * candidates are narrowed down.
		 */
		public function queryObjectsAtPoint(point:Point, out:Vector.<ISpatialObject>, sampleTexture:Boolean = false):int
		{
			var initialLength:int = out.length;
			queryNodesAtPoint(point, out, sampleTexture);
			return out.length - initialLength;
		}
		
		/**
		 * Finds all objects that intersect the given rectangle.  
		 */
		public function queryObjectsInRect(region:Rectangle, out:Vector.<ISpatialObject>):int
		{
			return queryNodesInRect(region, out);
		}
		
		/**
		 * Find all spatial objects that currently intersect with the specified object.
		 * Intersecting pairs are reported via the provided notification function.
		 * Basic bounding radius test are performed for each, more detailed analysis
		 * can be done by the callee once notified (texture comparison or consideration
		 * of velocity, etc.
		 */		
		public function queryCollisions(object:ISpatialObject, notification:Function):void
		{
			generation++;
			return collisionTest(object, notification);
		}
		
		/**
		 * Find all spatial objects that intersect with each other.
		 * Intersecting pairs are reported via the provided notification function.
		 * Basic bounding radius test are performed for each, more detailed analysis
		 * can be done by the callee once notified (texture comparison or consideration
		 * of velocity, etc.
		 */	
		public function queryAllCollisions(notification:Function):void
		{
			generation++;
			for (var l:int = 0 ; l < this.maxLevels; l++)
			{
				var size:int = Math.pow(LEVEL_RATIO, l) * minCellSize;
				var cellW:int = _worldBounds.width / size;
				var cellH:int = _worldBounds.height / size;
				for (var x:int = 0; x < cellW; x++)
				{
					for (var y:int = 0; y < cellH; y++)
					{
						var bucket:int = computeBucket(x, y, l);
						var node:GridNode = hashTable[bucket];
						while (node)
						{
							var current:ISpatialObject = node.object;
							if (node.generation != generation)
							{
								collisionTest(current, notification);
								node.generation = generation;
							}	
							node = node.next;
						}
					}
				}
			}
		}
		
		/**
		 * Invoked to free all resources associated with our grid hierarchy and hash.  Once invoked
		 * the data structure will cease to function as intended.
		 */
		public function dispose():void
		{
			hashTable = null;
			objectsAtLevel = null;
			occupiedLevelsMask = 0;
		}
				
		/**
		 * Creates a vector to serve as our cell hash and a secondary
		 * vector containing the count of objects hosted by each level of the
		 * grid.  The grid itself stores progressively larger objects in each
		 * level starting at minCellSize and increasing per level by 
		 * LEVEL_RATIO.
		 */		
		protected function initGrid(worldWidth:Number, worldHeight:Number):void
		{
			maxLevels = Math.log(Math.max(worldWidth*2, worldHeight*2) / minCellSize)/Math.LN2 + 1;
			hashTable = new Vector.<GridNode>(HASH_SIZE);
			objectsAtLevel = new Vector.<uint>(maxLevels);
			occupiedLevelsMask = 0;
		}
		
		/**
		 * Maps an input x, y, and z to an appropriate hash bucket (table index).
		 */
		protected function computeBucket(x:int, y:int, z:int):uint
		{
			var index:int = (LARGE_PRIME_1 * x + LARGE_PRIME_2 * y + LARGE_PRIME_3 * z) % HASH_SIZE;
			return (index < 0) ? index += HASH_SIZE : index;
		}
		
		/**
		 * Returns total number of objects being managed by this spatial set.
		 */
		protected var _length:uint = 0;
		public function get length():uint
		{
			return _length;
		}
		
		/**
		 * Returns bounds of grid in world space.
		 */
		protected var _worldBounds:Rectangle;
		public function get worldBounds():Rectangle
		{
			return _worldBounds;
		}
		
		/**
		 * Adds the specified node to the appropriate cell's node list.
		 */
		protected function addToBucket(gridNode:GridNode, size:Number, level:int):void
		{
			var item:ISpatialObject = gridNode.object;
			var idx:int = computeBucket(item.x/size, item.y/size, level);
			gridNode.bucket = idx;
			gridNode.next = hashTable[idx];
			hashTable[idx] = gridNode;
			
			objectsAtLevel[level]++;
			occupiedLevelsMask |= (1 << level);
		}
		
		/**
		 * Removes the specified node from its cell's node list.
		 */
		protected function removeFromBucket(gridNode:GridNode):void
		{
			var current:GridNode = hashTable[gridNode.bucket];
			
			if (--objectsAtLevel[gridNode.level] == 0)
				occupiedLevelsMask &= ~(1 << gridNode.level);
			
			if (gridNode == current)
			{
				hashTable[gridNode.bucket] = gridNode.next;
				return;
			}
			
			while (current)
			{
				var node:GridNode = current;
				current = current.next;
				if (current == gridNode)
				{
					node.next = current.next;
					return;
				}
			}
		}
								
		/**
		 * For a given spatial object, query all surround cells at or near the location of
		 * the specified object.
		 */	
		protected function collisionTest(object:ISpatialObject, notification:Function):void
		{
			var size:Number = minCellSize;
			var occupiedMask:uint = occupiedLevelsMask;
			
			var candidate:ISpatialObject = null;
			
			var br:Number = object.boundingRadius;
			var xx:Number = object.x;
			var yy:Number = object.y;

			for (var level:int = 0; level < maxLevels; size *= LEVEL_RATIO, occupiedMask >>=1, level++)
			{
				if (occupiedMask == 0) break;
				if ((occupiedMask & 1) == 0) continue;
				
				var xCell:int = object.x / size;
				var yCell:int = object.y / size;
				var bnd:int = 1;//Math.ceil(object.boundingRadius / size);

				var x1:int = xCell > 0 ? xCell - bnd : 0;
				var x2:int = xCell + bnd;
				var y1:int = yCell > 0 ? yCell - bnd : 0;
				var y2:int = yCell + bnd;
				
				for (var x:int = x1; x <= x2; x++)
				{
					for (var y:int = y1; y <= y2; y++)
					{
						var bucket:int = computeBucket(x, y, level);
						var node:GridNode = hashTable[bucket];
						while (node)
						{
							var current:ISpatialObject = node.object;
							if (current != object && node.generation != generation)
							{
								// Simple bounding circle intersect test.
								var dx:Number = xx - current.x;
								var dy:Number = yy - current.y;
								var dist:Number = Math.sqrt(dx * dx + dy * dy);
								
								if (dist <= br + current.boundingRadius)
									notification(object, current);
							}	
							node = node.next;
						}
					}
				}
			}
		}
		
		/**
		 * Tests each level of our grid hierarchy for nodes that intersect the provided 
		 * point.  When a single node is requested (out vector is null), we return node
		 * with highest depth.
		 */
		protected function queryNodesAtPoint(point:Point, out:Vector.<ISpatialObject>, sampleTexture:Boolean = false):ISpatialObject
		{
			var size:Number = minCellSize;
			var occupiedMask:uint = occupiedLevelsMask;
			
			var candidate:ISpatialObject = null;
			var candidateDepth:int = -1;
			
			for (var level:int = 0; level < maxLevels; size *= LEVEL_RATIO, occupiedMask >>=1, level++)
			{
				if (occupiedMask == 0) break;
				if ((occupiedMask & 1) == 0) continue;
				
				var xCell:int = point.x / size;
				var yCell:int = point.y / size;
				
				var x1:int = xCell > 0 ? xCell - 1 : xCell;
				var x2:int = xCell + 1;
				var y1:int = yCell > 0 ? yCell - 1 : yCell;
				var y2:int = yCell + 1;
				
				for (var x:int = x1; x <= x2; x++)
				{
					for (var y:int = y1; y <= y2; y++)
					{
						var current:GridNode = hashTable[computeBucket(x, y, level)];
						while (current)
						{
							var object:ISpatialObject = current.object;
							if (((object.depth > candidateDepth) || out != null) && 
								object.intersectsPoint(point.x, point.y, sampleTexture))
							{
								candidate = object;
								candidateDepth = object.depth;
								
								if (out) 
									out.push(candidate);
							}
							current = current.next;
						}
					}
				}
			}
			
			return candidate;
		}
		
		/**
		 * Finds all nodes at all grid levels that intersect the provided rectangular region.
		 */
		protected function queryNodesInRect(rect:Rectangle, out:Vector.<ISpatialObject>):int
		{
			var size:Number = minCellSize;
			var occupiedMask:uint = occupiedLevelsMask;
			var count:uint = 0;
			
			for (var level:int = 0; level < maxLevels; size *= LEVEL_RATIO, occupiedMask >>=1, level++)
			{
				if (occupiedMask == 0) break;
				if ((occupiedMask & 1) == 0) continue;
				
				var x1Cell:int = rect.left / size;
				var x2Cell:int = rect.right / size;
				var y1Cell:int = rect.top / size;
				var y2Cell:int = rect.bottom / size;
				
				var x1:int = x1Cell > 0 ? x1Cell - 1 : 0;
				var x2:int = x2Cell + 1;
				var y1:int = y1Cell > 0 ? y1Cell - 1 : 0;
				var y2:int = y2Cell + 1;
				
				for (var x:int = x1; x <= x2; x++)
				{
					for (var y:int = y1; y <= y2; y++)
					{
						var current:GridNode = hashTable[computeBucket(x, y, level)];
						while (current)
						{
							var object:ISpatialObject = current.object;
							if (object.intersectsRect(rect.x, rect.y, rect.width, rect.height))
							{
								out.push(object);
								count++;
							}
							current = current.next;
						}
					}
				}
			}
			
			return count;
		}

		/**
		 * A spatial object position has changed. We simply re-hash our spatial object 
		 * since the level won't have changed.
		 */	
		public function positionChanged(proxy:ISpatialObjectProxy):void
		{
		    var node:GridNode = proxy as GridNode;
			removeFromBucket(node);
			var size:Number = Math.pow(LEVEL_RATIO, node.level) * minCellSize;
			addToBucket(node, size, node.level);
		}

		/**
		 * A spatial object bounds has changed. We need to possibly find a new grid 
		 * level for this instance so remove from hash, recompute level and size, 
		 * then re-add.
		 */
		public function boundsChanged(proxy:ISpatialObjectProxy):void
		{
			var node:GridNode = proxy as GridNode;
			removeFromBucket(node);
			
			var diameter:Number = 2 * node.object.boundingRadius;
			var size:Number = minCellSize;
			for (var level:Number = 0; size * BOUNDS_TO_CELL_RATIO < diameter; level++)  
				size *= LEVEL_RATIO;
			
			addToBucket(node, size, level);
		}
		
		/**
		 * A spatial object depth has changed. Do nothing...
		 */
		public function depthChanged(proxy:ISpatialObjectProxy):void
		{

		}
	}	
}

import spatial.ISpatialObject;
import spatial.ISpatialObjectProxy;
 
/**
 * Represents a single grid node. All nodes at a given grid level and cell are 
 * stored as a linked list.
 */
class GridNode implements ISpatialObjectProxy
{
	public function GridNode() { }
	public var bucket:int;
	public var level:int;
	public var generation:uint;
	public var next:GridNode;
	
	private var _spatialObject:ISpatialObject;
	public function set object(value:ISpatialObject):void { _spatialObject = value; }
	public function get object():ISpatialObject { return _spatialObject; }
}



