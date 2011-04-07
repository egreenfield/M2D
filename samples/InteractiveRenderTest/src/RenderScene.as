package {
	import M2D.sprites.Actor;
	import M2D.sprites.Asset;
	import M2D.time.Clock;
	import M2D.time.IClockListener;
	import M2D.worlds.BatchTexture;
	import M2D.worlds.World;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class RenderScene extends Sprite implements IClockListener 
	{
		public var world:World;
		protected var _lastUpdate:Number=getTimer();
		protected var _fps:Number;
		protected var _symbols:Vector.<Actor>
		protected var sceneWidth:Number;
		protected var sceneHeight:Number;
		private var depthTotal:Number=0;
		public var onTick:Function=null;
		
		// asset cache
		private var assetsList:Dictionary=new Dictionary();

		public function RenderScene(sceneWidth:Number, sceneHeight:Number) 
		{
			this.sceneWidth=sceneWidth;
			this.sceneHeight=sceneHeight;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		public function init(e:Event=null):void 
		{
			_clock=new Clock(60);
			_clock.addListener(this);
			world=new World();
			world.backgroundColor=0xB0E0E5;
			clock.addListener(world);
			world.initContext(stage, this, 0, new Rectangle(0, 0, sceneWidth, sceneHeight));
			_symbols=new Vector.<Actor>();
			_clock.start();
		}

		public function addAnimatedSprite(img:Class):CoinClip 
		{
			var asset:Asset=getAssetByClass(img);
			if (asset == null) 
			{
				asset = world.assetMgr.createAssetFromDisplayObject(new img(), 3, 10);
				assetsList[img]=asset;
			}
			var symbol:Actor=asset.createActor();
			symbol.depth = 1;
			_symbols.push(symbol);
			return new CoinClip(symbol)
		}

		protected function getAssetByClass(cls:Class):Asset 
		{
			return assetsList[cls];
		}

		protected function getAssetByDisplayObject(d:DisplayObject):Asset 
		{
			return assetsList[d];
		}

		public function tick():void 
		{
			if (onTick != null) {
				onTick.call(this);
			}
			// FPS
			var deltaT:Number=getTimer() - _lastUpdate;
			_lastUpdate=getTimer();
			_fps=Math.round(100 / deltaT) * 10;
		}

		// GETTERS/SETTERS
		public function get fps():Number 
		{
			return _fps;
		}
		public var _clock:Clock;

		public function get clock():Clock 
		{
			return _clock;
		}

		public function set clock(value:Clock):void 
		{
			_clock=value;
		}

		public function get symbols():Vector.<Actor> 
		{
			return _symbols;
		}
	}
}