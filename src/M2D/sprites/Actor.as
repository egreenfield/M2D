package M2D.sprites
{
	import M2D.core.IBlitOp;
	
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	public class Actor implements IBlitOp
	{
		private var _x:Number = 0;
		private var _y:Number = 0;
		public var scaleX:Number = 1;
		public var scaleY:Number = 1;
		public var depth:Number = 0;
		public function get width():Number { return asset.width; }
		public function get height():Number {return asset.height;}
		public var _rotation:Number = 0;

		public var regX:Number;
		public var regY:Number;
		
		private var _active:Boolean = false;
		
		
		public var cell:int = 0;
		
		public function get x():Number { return _x;}
		public function get y():Number { return _y;}
		
		private var _sourceBounds:Rectangle = new Rectangle();
		
		
		public function move(x:Number,y:Number):void
		{
			if(mDirty == false)	
			{
				m.appendTranslation(x- _x,y - _y,0);
			}
			_x = x;
			_y = y;
		}
		public function set x(value:Number):void
		{
			if(mDirty == false)	
			{
				m.appendTranslation(value - _x,0,0);
			}
			_x = value;
		}
		
		public function set y(value:Number):void
		{
			if(mDirty == false)	
			{
				m.appendTranslation(0,value - _y,0);
			}
			_y = value;			
		}
		public function set active(value:Boolean):void
		{
			if(value == _active)
				return;
			
			_active = value;
			asset.library.activate(this,value);
		}
		public function get active():Boolean
		{
			return _active;
		}
		public function set rotation(value:Number):void
		{
			_rotation = value;
			mDirty = true;
		}
		public function get rotation():Number { return _rotation; }
		public function Actor()
		{
			
		}
		public function update():void
		{
			
		}
		
		public function getBlitXForm():Matrix3D
		{
			if(mDirty)	
			{
				var width:Number = asset.width;
				var height:Number = asset.height;
				m.identity();
				m.appendScale(width,height,1);
				m.appendTranslation((isNaN(regX))?  -width/2:regX,(isNaN(regY))?  -height/2:regY,0);
				m.appendScale(scaleX,scaleY,1);
				if(rotation != 0)
					m.appendRotation(_rotation,Vector3D.Z_AXIS);
				m.appendTranslation(_x,_y,-depth/30000);
				mDirty = false;
			}
			return m;
		}

		public function getBlitSourceRC():Rectangle
		{
			var width:Number = asset.width/asset.texture.width/asset.cellColumnCount;
			var height:Number = asset.height/asset.texture.height/asset.cellRowCount;
			sourceRC.left = width * (cell % asset.cellColumnCount);
			sourceRC.top = height * Math.floor(cell / asset.cellColumnCount);
			sourceRC.width = width;
			sourceRC.height = height;
			
			return sourceRC;
		}
		
		private var m:Matrix3D = new Matrix3D();
		private var sourceRC:Rectangle = new Rectangle();
		
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
		
		public var asset:Asset;
	}
}