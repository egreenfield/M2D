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
	import M2D.core.IBlitOp;
	import M2D.worlds.RenderTask;
	
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	public class Actor
	{
		public var x:Number = 0;
		public var y:Number = 0;
		public var scaleX:Number = 1;
		public var scaleY:Number = 1;
		
		public var width:Number 
		public var height:Number
		public var rotation:Number = 0;
		private var cosR:Number;
		public var sinR:Number;
		
		public var sourceRCDirty:Boolean = true;
		
		public var regX:Number;
		public var regY:Number;

		private var xf:Vector.<Number> = Vector.<Number>([1,0,0,0, 0,1,0,1, 0,0,0,0]);

		private var _prevX:Number;
		private var _prevY:Number;
		private var _prevRotation:Number;
		private var _prevScaleX:Number;
		private var _prevScaleY:Number;
				
		private var _active:Boolean = false;
		
		
		private var _cell:int = 0;
		
		
		public var task:RenderTask;
		
		public function get depth():Number { return xf[3];}
		public function get alpha():Number 
		{ 
			return xf[7];
		}
		
		private function hasTransparency():Boolean { return xf[7] < 1 || _asset.hasAlphaChannel}
		public function set depth(v:Number):void 
		{
			xf[3] = v;
			updateKey();
			invalidateRenderSort(hasTransparency());
		}
		public function set alpha(v:Number):void 
		{
			if(xf[7] == v)
				return;
			invalidateRenderSort(xf[7] == 1);
			xf[7] = v;
			updateKey();
		}

		
		private function invalidateRenderSort(required:Boolean):void
		{
			_asset.library.world.invalidateRenderSort(required);
		}
		
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
			task = new RenderTask();
			task.data = this;
		}
		public function update():void
		{
			
		}
		
		
		public function getBlitXForm():Vector.<Number>
		{
			if(rotation != _prevRotation || scaleX != _prevScaleX || scaleY != _prevScaleY)	
			{
				
				if(rotation != _prevRotation)
				{
					var ar:Number = -rotation*Math.PI/180;
					var c:Number = cosR = Math.cos(ar);
					var s:Number = sinR = Math.sin(ar);					
				}
				else
				{
					c = cosR;
					s = sinR;
				}
			
				var csy:Number = c*scaleY;
				var csx:Number = c*scaleX;
				
				var nrx:Number = -regX;
				var nry:Number = -regY;
				var nssx:Number = -s*scaleX;
				var ssy:Number = s*scaleY;
				
				xf[0] = csx*width;
				xf[1] = ssy*height;
				xf[2] = csx*nrx + ssy*nry + x;			

				xf[4] = nssx*width;
				xf[5] = csy*height;
				xf[6] = nssx*nrx + csy*nry + y;			

				_prevX = x;
				_prevY = y;
				_prevRotation = rotation;
				_prevScaleX = scaleX;
				_prevScaleY = scaleY;
						
			} else if (x != _prevX || y != _prevY)
			{
				xf[2] += x-_prevX;
				xf[6] += y-_prevY;
				_prevX = x;
				_prevY = y;
			}
			return xf;
		}

		private function updateSourceRC():void
		{
			var width:Number = width/_asset.texture.width;
			var height:Number = height/_asset.texture.height;
			xf[8] = width;
			xf[9] = height;
			xf[10] = _asset.offsetLeft/_asset.texture.width + width * (_cell % _asset.cellColumnCount);
			xf[11]  = _asset.offsetTop/_asset.texture.height + height * Math.floor(_cell / _asset.cellColumnCount);
			sourceRCDirty = false;			
		}
		
		
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
			regX = _asset.width/_asset.cellColumnCount/2;
			regY = _asset.height/_asset.cellRowCount/2;
			width = _asset.width/_asset.cellColumnCount; 
			height = _asset.height/_asset.cellRowCount;			
			
			updateSourceRC();
			updateKey();
		}
		public function get asset():Asset
		{
			return _asset;
		}
		
		private function updateKey():void
		{
			var isTransparent:Boolean = asset.hasAlphaChannel||(alpha < 1); 
			task.setKey(((isTransparent)? RenderTask.TRANSPARENT:RenderTask.OPAQUE) | RenderTask.makeRenderCode(asset.library.renderID) | RenderTask.makeMaterialCode(asset.texture.textureID),RenderTask.makeDepthCode(depth,isTransparent));
		}
	}
}