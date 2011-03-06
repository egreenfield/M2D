package
{
	import M2D.Actor;
	import M2D.Asset;
	import M2D.BatchTexture;
	import M2D.BitmapWorld;
	import M2D.CellAnimation;
	import M2D.Clock;
	import M2D.DOWorld;
	import M2D.IClockListener;
	import M2D.ParticleInstance;
	import M2D.ParticleSymbol;
	import M2D.World;
	import M2D.WorldBase;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	
	import mx.utils.NameUtil;
	
	[SWF(width="800", height="1050", frameRate="60", backgroundColor="0xFFFFFF")]
	public class MHPTest extends Sprite implements IClockListener
	{
		public var tf:TextField;
		public static const smoothWindow:int = 100;
		public static const actorWidth:int = 40;
		public static const actorHeight:int = 40;
		
		private var world:World;
		private var ps:Array = [];
		
		[Embed(source="assets/smiley.png")]
		public var smiley:Class;
		
		[Embed(source="assets/smileyRect.png")]
		public var smileyRect:Class;
		
		[Embed(source="assets/flash.png")]
		public var flashBubble:Class;
		
		[Embed(source="assets/knightRun.png")]
		public var knight:Class;
		
		[Embed(source="assets/glow.png")]
		public var dot:Class;
		
		[Embed(source="assets/air.jpg")]
		public var air:Class;
		
		public var viewWidth:Number = 800;
		public var viewHeight:Number = 1050;
		
		public function MHPTest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			_clock = new Clock(60);
			_clock.addListener(this);
			
			
			world = new World();
			world.backgroundColor = 0xeee8aa;
			clock.addListener(world);
			world.initContext(stage,this,0,new Rectangle(0,0,viewWidth,viewHeight));
			
			var kTexture:BatchTexture = world.assetMgr.createTextureFromDisplayObject(new air());
			var particleSymbol:ParticleSymbol = world.particleLibrary.createSymbol();
			
			
			particleSymbol.texture = kTexture;
			particleSymbol.birthDelay = .5;
			particleSymbol.lifespan = 2000;
			//particleSymbol.gravityY = 0;
	//		particleSymbol.maxParticles = 1000;
			

			var maxLiving:Number = Math.ceil(particleSymbol.lifespan/particleSymbol.birthDelay);
			var numGenerators:Number = 20;
			trace("Max symbols per generator:",maxLiving);
			trace("total #:",maxLiving*numGenerators);
			var particle:ParticleInstance
			
			for(var i:int = 0;i<numGenerators;i++) {
				
				particle = particleSymbol.createInstance();
				ps.push(particle);
				particle.x = Math.random()*400+ 400 - 200;
				particle.y = Math.random() * 400+ 500 - 200;			
				particle.clock = _clock;
				particle.rotation = Math.random() * 360 ;
				particle.start();
			}

			/*
			
			particle = particleSymbol.createInstance();			
			particle.x = 400;
			particle.y = 525;			
			particle.clock = _clock;
			particle.start();

			particle = particleSymbol.createInstance();			
			particle.x = 200;
			particle.y = 525;			
			particle.clock = _clock;
			particle.start();

			particle = particleSymbol.createInstance();			
			particle.x = 600;
			particle.y = 525;			
			particle.clock = _clock;
			particle.start();

			particle = particleSymbol.createInstance();			
			particle.x = 200;
			particle.y = 237;			
			particle.clock = _clock;
			particle.start();

			particle = particleSymbol.createInstance();			
			particle.x = 600;
			particle.y = 237;			
			particle.clock = _clock;
			particle.start();

			particle = particleSymbol.createInstance();			
			particle.x = 400;
			particle.y = 237;			
			particle.clock = _clock;
			particle.start();
			
			
			particle = particleSymbol.createInstance();			
			particle.x = 200;
			particle.y = 762;			
			particle.clock = _clock;
			particle.start();

			particle = particleSymbol.createInstance();			
			particle.x = 400;
			particle.y = 762;			
			particle.clock = _clock;
			particle.start();

			particle = particleSymbol.createInstance();			
			particle.x = 600;
			particle.y = 762;			
			particle.clock = _clock;
			particle.start();
*/
			tf = new TextField();
			//			tf.width = viewWidth;
			//			tf.height = viewHeight;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.width = 300;
			tf.background = true;
			tf.border = true;
			addChild(tf);

			tf.addEventListener(MouseEvent.CLICK,clickHandler);
			_clock.start();
			
		}
		
		public function clickHandler(e:MouseEvent):void
		{
			if(_clock.paused)
				_clock.unpause();
			else
				_clock.pause();
		}
		
		public var previousTime:Number = 0;
		public var mpf:Smoother = new Smoother(smoothWindow);
		public var fps:Smoother = new Smoother(smoothWindow);
		public var asProcessing:Smoother = new Smoother(smoothWindow);
		public var drawTri:Smoother = new Smoother(smoothWindow);

		private var _clock:Clock;
		
		public function get clock():Clock
		{
			return _clock;
		}
		
		public function set clock(value:Clock):void
		{
			_clock = value;
		}
		
		public function tick():void
		{
			for each(var p:* in ps)
			{
				p.rotation += .5;//Math.random()*3;
			}
			
			var t:Number = clock.currentTime;
			var delta:Number = t - previousTime;
			fps.sample((1/delta)*1000);
			mpf.sample(delta);
			
			previousTime = t;
			var drawTriTime:Number = (world is World)? World(world).timeInDrawTriangles:0;
			var numCalls:Number = (world is World)? World(world).numDrawTrianglesCallsPerFrame:0;
			reportTime(clock.processingTime,drawTriTime,numCalls);
		}
		
		private var lastUpdate:Number = getTimer();
		public function reportTime(asProcessingTime:Number,drawTriTime:Number,batchCount:Number):void
		{
			asProcessing.sample(asProcessingTime);
			drawTri.sample(drawTriTime);
			var t:Number = getTimer();
			if(t-lastUpdate > 1000)
				lastUpdate= t;
			else
				return;
			tf.text = 
				"\nnumber of actors: " + actorWidth*actorHeight + 
				"\nnumber of draw calls: " + batchCount + 
				"\nfps: " + fps.average + 
				"\nmilli/frame: " + mpf.average + 
				"\ntotal AS processing: " + asProcessing.average + 
				"\ntotal AS processing (without draw calls): " + (asProcessing.average - drawTri.average) + 
				"\nAS processing/draw call:" + (asProcessing.average - drawTri.average)/batchCount +
				"\ntotal ms spent in DrawTriangles: " + drawTri.average +
				"\nms/drawTriangles call: " + drawTri.average/batchCount +
				"";
		}		
	}
}