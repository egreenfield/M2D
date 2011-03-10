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
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import zones.FastWeightedArray;
	import zones.Zone2D;

	/**
	 * The BitmapData zone defines a shaped zone based on a BitmapData object.
	 * The zone contains all pixels in the bitmap that are not transparent -
	 * i.e. they have an alpha value greater than zero.
	 */

	public class BitmapDataZone implements Zone2D 
	{
		private var _bitmapData : BitmapData;
		private var _offsetX : Number;
		private var _offsetY : Number;
		private var _scaleX : Number;
		private var _scaleY : Number;
		private var _validPoints : FastWeightedArray;
		
		/**
		 * The constructor creates a BitmapDataZone object.
		 * 
		 * @param bitmapData The bitmapData object that defines the zone.
		 * @param xOffset A horizontal offset to apply to the pixels in the BitmapData object 
		 * to reposition the zone
		 * @param yOffset A vertical offset to apply to the pixels in the BitmapData object 
		 * to reposition the zone
		 * @param scaleX A scale factor to stretch the bitmap horizontally
		 * @param scaleY A scale factor to stretch the bitmap vertically
		 */
		public function BitmapDataZone( bitmapData : BitmapData = null, offsetX : Number = 0, offsetY : Number = 0, scaleX:Number = 1, scaleY:Number = 1 )
		{
			_bitmapData = bitmapData;
			_offsetX = offsetX;
			_offsetY = offsetY;
			_scaleX = scaleX;
			_scaleY = scaleY;
			invalidate();
		}
		
		/**
		 * The bitmapData object that defines the zone.
		 */
		public function get bitmapData() : BitmapData
		{
			return _bitmapData;
		}
		public function set bitmapData( value : BitmapData ) : void
		{
			_bitmapData = value;
			invalidate();
		}

		/**
		 * A horizontal offset to apply to the pixels in the BitmapData object 
		 * to reposition the zone
		 */
		public function get offsetX() : Number
		{
			return _offsetX;
		}
		public function set offsetX( value : Number ) : void
		{
			_offsetX = value;
		}

		/**
		 * A vertical offset to apply to the pixels in the BitmapData object 
		 * to reposition the zone
		 */
		public function get offsetY() : Number
		{
			return _offsetY;
		}
		public function set offsetY( value : Number ) : void
		{
			_offsetY = value;
		}

		/**
		 * A scale factor to stretch the bitmap horizontally
		 */
		public function get scaleX() : Number
		{
			return _scaleX;
		}
		public function set scaleX( value : Number ) : void
		{
			_scaleX = value;
		}

		/**
		 * A scale factor to stretch the bitmap vertically
		 */
		public function get scaleY() : Number
		{
			return _scaleY;
		}
		public function set scaleY( value : Number ) : void
		{
			_scaleY = value;
		}

		/**
		 * This method forces the zone to revaluate itself. It should be called whenever the 
		 * contents of the BitmapData object change. However, it is an intensive method and 
		 * calling it frequently will likely slow your code down.
		 */
		public function invalidate():void
		{
			if( ! _bitmapData )
			{
				return;
			}
			_validPoints = new FastWeightedArray();
			for( var x : int = 0; x < _bitmapData.width ; ++x )
			{
				for( var y : int = 0; y < _bitmapData.height ; ++y )
				{
					var pixel : uint = _bitmapData.getPixel32( x, y );
					var ratio : Number = ( pixel >> 24 & 0xFF ) / 0xFF;
					if ( ratio != 0 )
					{
						_validPoints.add( new Point( x, y ), ratio );
					}
				}
			}
		}

		/**
		 * The contains method determines whether a point is inside the zone.
		 * 
		 * @param point The location to test for.
		 * @return true if point is inside the zone, false if it is outside.
		 */
		public function contains( x : Number, y : Number ) : Boolean
		{
			if( x >= _offsetX && x <= _offsetX + _bitmapData.width * scaleX
				&& y >= _offsetY && y <= _offsetY + _bitmapData.height * scaleY )
			{
				var pixel : uint = _bitmapData.getPixel32( Math.round( ( x - _offsetX ) / _scaleX ), Math.round( ( y - _offsetY ) / _scaleY ) );
				return ( pixel >> 24 & 0xFF ) != 0;
			}
			return false;
		}

		/**
		 * The getLocation method returns a random point inside the zone.
		 * 
		 * @return a random point inside the zone.
		 */
		public function getLocation(p : Vector3D):void
		{
			var pa:Point = _validPoints.getRandomValue();
			p.x = pa.x * _scaleX + _offsetX;
			p.y = pa.y * _scaleY + _offsetY;
		}
		
		/**
		 * The getArea method returns the size of the zone.
		 * It's used by the MultiZone class to manage the balancing between the
		 * different zones.
		 * 
		 * @return the size of the zone.
		 */
		public function getArea() : Number
		{
			return _validPoints.totalRatios * _scaleX * _scaleY;
		}

	}
}
