/*
 * FLINT PARTICLE SYSTEM
 * .....................
 * 
 * Author: Richard Lord
 * Copyright (c) Richard Lord 2008-2010
 * http://flintparticles.org
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

package zones
{

	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import zones.Zone2D;

	/**
	 * The PointZone zone defines a zone that contains a single point.
	 */

	public class PointZone implements Zone2D
	{
		private var _point:Point;
		
		/**
		 * The constructor defines a PointZone zone.
		 * 
		 * @param point The point that is the zone.
		 */
		public function PointZone( point:Point = null )
		{
			if( point == null )
			{
				_point = new Point( 0, 0 );
			}
			else
			{
			_point = point;
		}
		}
		
		/**
		 * The point that is the zone.
		 */
		public function get point() : Point
		{
			return _point;
		}

		public function set point( value : Point ) : void
		{
			_point = value;
		}

		/**
		 * The x coordinate of the point that is the zone.
		 */
		public function get x() : Number
		{
			return _point.x;
		}

		public function set x( value : Number ) : void
		{
			_point.x = value;
		}

		/**
		 * The y coordinate of the point that is the zone.
		 */
		public function get y() : Number
		{
			return _point.y;
		}

		public function set y( value : Number ) : void
		{
			_point.y = value;
		}

		/**
		 * The contains method determines whether a point is inside the zone.
		 * This method is used by the initializers and actions that
		 * use the zone. Usually, it need not be called directly by the user.
		 * 
		 * @param x The x coordinate of the location to test for.
		 * @param y The y coordinate of the location to test for.
		 * @return true if point is inside the zone, false if it is outside.
		 */
		public function contains( x:Number, y:Number ):Boolean
		{
			return _point.x == x && _point.y == y;
		}
		
		/**
		 * The getLocation method returns a random point inside the zone.
		 * This method is used by the initializers and actions that
		 * use the zone. Usually, it need not be called directly by the user.
		 * 
		 * @return a random point inside the zone.
		 */
		public function getLocation(p:Vector3D):void
		{
			p.x= _point.x;p.y = _point.y;
		}
		
		/**
		 * The getArea method returns the size of the zone.
		 * This method is used by the MultiZone class. Usually, 
		 * it need not be called directly by the user.
		 * 
		 * @return a random point inside the zone.
		 */
		public function getArea():Number
		{
			// treat as one pixel square
			return 1;
		}

	}
}
