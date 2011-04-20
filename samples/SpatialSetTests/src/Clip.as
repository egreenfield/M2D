package {
	
	import M2D.sprites.Actor;
	import M2D.worlds.BatchTexture;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import spatial.IKineticObject;
	import spatial.ISpatialListener;
	import spatial.ISpatialObject;
	import spatial.ISpatialObjectProxy;
	
	public class Clip implements IKineticObject
	{
		public var actor:Actor
		
		public function Clip(actor:Actor) 
		{
			this.actor = actor;
			super();
		}
				
		public function set alpha (value:Number):void 
		{
			actor.alpha = value;
		}
		
		public function get alpha ():Number 
		{
			return actor.alpha;
		}
		
		public function set x (value:Number):void 
		{
			actor.x = value;
		}
		
		public function get x():Number
		{
			return actor.x;
		}
		
		public function set y (value:Number):void 
		{
			actor.y = value;
		}
		
		public function get y():Number
		{
			return actor.y;
		}
		
		public function set width (value:Number):void 
		{
			actor.width = value;
		}
		
		public function get width():Number
		{
			return actor.width;
		}
		
		public function set height (value:Number):void 
		{
			actor.height = value;
		}
		
		public function get height():Number
		{
			return actor.height;
		}
		
		private var _proxy:ISpatialObjectProxy;
		
		public function set proxy(value:ISpatialObjectProxy):void 
		{
			_proxy = value;
		}
		
		public function get proxy():ISpatialObjectProxy 
		{
			return _proxy;
		}
		
		public function set depth (value:Number):void 
		{
			actor.depth = value;
			notifyDepthChanged();
		}
		
		public function get depth ():Number 
		{
			return actor.depth;
		}
		
		public function get boundingRect ():Rectangle
		{
			if (_boundingRectDirty)
			{
				_boundingRect.x = (actor.x - actor.regX) * actor.scaleX;
				_boundingRect.y = (actor.y - actor.regY) * actor.scaleY;
				_boundingRect.width = actor.width * actor.scaleX;
				_boundingRect.height = actor.height * actor.scaleY;
				_boundingRectDirty = false;
			}
			return _boundingRect;
		}
		
		private var _boundingRadius:Number;
		private var _boundingRect:Rectangle = new Rectangle();
		private var _boundingRadiusDirty:Boolean = true;
		private var _boundingRectDirty:Boolean = true;
		
		public function get boundingRadius():Number
		{
			if (_boundingRadiusDirty)
			{
				var bounds:Rectangle = boundingRect;
				var regX:Number = actor.regX * actor.scaleX;
				var regY:Number = actor.regY * actor.scaleY;
				_boundingRadius = Math.max(regX, bounds.width - regX);
				_boundingRadius = Math.max(_boundingRadius, regY);
				_boundingRadius = Math.max(_boundingRadius, bounds.height - regY);
				_boundingRadiusDirty = false;
			}
			return _boundingRadius;
		}
		
		public function set registration (value:Point):void 
		{
			actor.regX = value.x;
			actor.regY = value.y;
		}
		
		public function get registration ():Point 
		{
			return new Point(actor.regX, actor.regY);
		}	
		
		public function set rotation (value:Number):void 
		{
			actor.rotation = value;
		}
		
		public function get rotation ():Number 
		{
			return actor.rotation;
		}
		
		public function set scale (value:Point):void 
		{
			actor.scaleX = value.x;
			actor.scaleY = value.y;
			notifyBoundsChanged();
		}
		
		public function get scale():Point
		{
			return new Point(actor.scaleX, actor.scaleY);
		}
		
		public function intersectsPoint(x:Number, y:Number, sampleTexture:Boolean=false):Boolean
		{
			var pt:Point = new Point(x - actor.x , y - actor.y);
			var rx:Number = isNaN(actor.regX) ? actor.width / 2 : actor.regX;
			var ry:Number = isNaN(actor.regY) ? actor.height / 2 : actor.regY;
			var m:Matrix = actor.get2DMatrix();
			m.invert();
			pt = m.deltaTransformPoint(pt);
			var bounds:Rectangle = new Rectangle(0, 0, actor.width, actor.height);
			var result:Boolean = bounds.contains(pt.x + rx, pt.y + ry);
			
			if (result && sampleTexture)
			{
				var xf:Vector.<Number> = actor.getBlitXForm();
				var bd:BitmapData = actor.asset.texture.data;
				if (bd)
				{
					var x:Number = pt.x + rx + xf[10] * actor.asset.texture.data.width;
					var y:Number = pt.y + ry + xf[11] * actor.asset.texture.data.height;
					result = bd.hitTest(new Point(0,0), 0x01, new Point(x,y));	
				}
			}
			
			return result;
		}
		
		public function intersectsRect(x:Number, y:Number, width:Number, height:Number):Boolean
		{
			return new Rectangle(x, y, width, height).intersects(boundingRect);
		}
		
		private var listeners:Vector.<ISpatialListener>;
		
		public function addSpatialListener(value:ISpatialListener):void
		{
			if (!listeners)
				listeners = new Vector.<ISpatialListener>();
			listeners.push(value);
		}
		
		public function removeSpatialListener(value:ISpatialListener):void
		{
			if (listeners)	
			{
				var index:int = listeners.indexOf(value);
				if (index >= 0)
					listeners.splice(index, 1);
			}
		}
		
		protected function notifyBoundsChanged():void
		{
			if (listeners)
			{
				for (var i:int=0; i < listeners.length; i++)
				{
					listeners[0].boundsChanged(proxy);
				}
			}
		}
		
		protected function notifyPositionChanged():void
		{
			if (listeners)
			{
				for (var i:int=0; i < listeners.length; i++)
				{
					listeners[0].positionChanged(proxy);
				}
			}
		}
		
		protected function notifyDepthChanged():void
		{
			if (listeners)
			{
				for (var i:int=0; i < listeners.length; i++)
				{
					listeners[0].depthChanged(proxy);
				}
			}
		}
		
	}
}