package M2D
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
		private var m:Matrix3D = new Matrix3D();
		private var sourceRC:Rectangle = new Rectangle();
		
		private var mDirty:Boolean = true;

		
		public function get x():Number { return _x;}
		public function get y():Number { return _y;}
		
		public function set rotation(value:Number):void
		{
			_rotation = value;
			mDirty = true;
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
			if(mDirty == false)	
			{
				m.appendTranslation(x- _x,y - _y,0);
			}
			_x = x;
			_y = y;
		}
		public function set x(value:Number):void
		{
			_x = value;
		}
		
		public function set y(value:Number):void
		{
			_y = value;			
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
			if(mDirty)	
			{
				m.identity();
				m.appendTranslation((isNaN(regX))?  -width/2:regX,(isNaN(regY))?  -height/2:regY,0);
				m.appendScale(scaleX,scaleY,1);
				if(rotation != 0)
					m.appendRotation(_rotation,Vector3D.Z_AXIS);
				m.appendTranslation(_x,_y,-depth/30000);
				mDirty = false;
			}
			return m;
		}
	}
}