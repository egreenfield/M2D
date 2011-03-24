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
*/package M2D.sprites
{
	import M2D.core.IBlitOp;
	import M2D.core.RC;
	
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	public class Actor implements IBlitOp
	{
		public var x:Number = 0;
		public var y:Number = 0;
		public var scaleX:Number = 1;
		public var scaleY:Number = 1;
		public var depth:Number = 0;
		public function get width():Number { return _asset.width; }
		public function get height():Number {return _asset.height;}
		public var rotation:Number = 0;
		public var sourceRCDirty:Boolean = true;
		
		public var regX:Number;
		public var regY:Number;
		
		private var _prevX:Number;
		private var _prevY:Number;
		private var _prevRotation:Number;
		private var _prevScaleX:Number;
		private var _prevScaleY:Number;
		
		private var _active:Boolean = false;
		
		
		private var _cell:int = 0;
		
		public function set cell(value:int):void
		{
			if(value != _cell)
				sourceRCDirty = true;
			_cell = value;
			updateSourceRC();
		}
		public function get cell():int
		{
			return _cell;
		}
		private var _sourceBounds:Rectangle = new Rectangle();
		
		
		public function set active(value:Boolean):void
		{
			if(value == _active)
				return;
			
			_active = value;
			_asset.library.activate(this,value);
		}
		public function get active():Boolean
		{
			return _active;
		}
		public function Actor()
		{
			
		}
		public function update():void
		{
			
		}
		
		public var xf:Vector.<Number> = Vector.<Number>([1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0]);
		
		private function updateXF():void
		{
			var width:Number = _asset.width;
			var height:Number = _asset.height;
			m.identity();
			m.appendScale(width,height,1);
			m.appendTranslation((isNaN(regX))?  -width/2:regX,(isNaN(regY))?  -height/2:regY,0);
			m.appendScale(scaleX,scaleY,1);
			if(rotation != 0)
				m.appendRotation(rotation,Vector3D.Z_AXIS);
			m.appendTranslation(x,y,-depth/30000);
			mDirty = false;
	
			
			m.transpose();
			var newXF:Vector.<Number>= m.rawData;
			newXF.push(xf[16],xf[17],xf[18],xf[19]);
			xf = newXF;
			
			_prevX = x;
			_prevY = y;
			_prevRotation = rotation;
			_prevScaleX = scaleX;
			_prevScaleY = scaleY;
			
		}
		
		public function getBlitXForm():Vector.<Number>
		{
			if(mDirty || rotation != _prevRotation || scaleX != _prevScaleX || scaleY != _prevScaleY)	
			{
				updateXF();
						
			} else if (x != _prevX || y != _prevY)
			{
				xf[3] += x-_prevX;
				xf[7] += y-_prevY;
				_prevX = x;
				_prevY = y;
			}
			return xf;
		}

		public function getBlitSourceRC():Vector.<Number>
		{
			if(sourceRCDirty)
			{
				updateSourceRC();
			}
			
			return sourceRC;
		}
		private function updateSourceRC():void
		{
			var width:Number = _asset.width/_asset.texture.width/_asset.cellColumnCount;
			var height:Number = _asset.height/_asset.texture.height/_asset.cellRowCount;
			xf[16] = width;
			xf[17] = height;
			xf[18] = width * (_cell % _asset.cellColumnCount);
			xf[19]  = height * Math.floor(_cell / _asset.cellColumnCount);
			sourceRCDirty = false;			
		}
		
		private var m:Matrix3D = new Matrix3D();
		public var sourceRC:Vector.<Number> = new Vector.<Number>(4);
		
		private var mDirty:Boolean = true;
		public function get2DMatrix():Matrix
		{
			var m:Matrix = new Matrix();
			m.translate((isNaN(regX))?  -width/2:regX,(isNaN(regY))?  -height/2:regY);

			m.scale(scaleX,scaleY);
			if(rotation != 0)
				m.rotate(rotation / 180 * Math.PI);
			m.translate(x,y);
			return m;			
		}
		
		private var _asset:Asset;
		public function set asset(v:Asset):void
		{
			_asset = v;
			
			updateSourceRC();
		}
		public function get asset():Asset
		{
			return _asset;
		}
	}
}