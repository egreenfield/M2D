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
*/package M2D.worlds
{
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	public class Instance
	{
		public function Instance()
		{
		}
		protected var _x:Number = 0;
		protected var _y:Number = 0;
		public var scaleX:Number = 1;
		public var scaleY:Number = 1;
		public var depth:Number = 0;
		public var _rotation:Number = 0;
		
		public var regX:Number;
		public var regY:Number;
		protected var _active:Boolean = false;
		protected var blitXForm:Matrix3D = new Matrix3D();
		
		private var sourceRC:Rectangle = new Rectangle();
		
		protected var blitXFormDirty:Boolean = true;

		
		public function get x():Number { return _x;}
		public function get y():Number { return _y;}
		
		public function set rotation(value:Number):void
		{
			_rotation = value;
			blitXFormDirty = true;
		}
		public function get rotation():Number { return _rotation; }

		
		public function set active(value:Boolean):void
		{
			if(value == _active)
				return;
			
			_active = value;
		}
		
		public function get active():Boolean
		{
			return _active;
		}
		
		public function move(x:Number,y:Number):void
		{
			if(blitXFormDirty == false)	
			{
				blitXForm.appendTranslation(x- _x,y - _y,0);
			}
			_x = x;
			_y = y;
		}
		public function set x(value:Number):void
		{
			_x = value;
			blitXFormDirty = true;
		}
		
		public function set y(value:Number):void
		{
			_y = value;			
			blitXFormDirty = true;
		}

		public function get width():Number
		{
			return 0;
		}
		public function get height():Number 
		{
			return 0;
		}
		public function getBlitXForm():Matrix3D
		{
			if(blitXFormDirty)	
			{
				blitXForm.identity();
				blitXForm.appendTranslation((isNaN(regX))?  -width/2:regX,(isNaN(regY))?  -height/2:regY,0);
				blitXForm.appendScale(scaleX,scaleY,1);
				if(rotation != 0)
					blitXForm.appendRotation(_rotation,Vector3D.Z_AXIS);
				blitXForm.appendTranslation(_x,_y,-depth/30000);
				blitXFormDirty = false;
			}
			return blitXForm;
		}		
	}
}