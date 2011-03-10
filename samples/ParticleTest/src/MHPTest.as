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
*/package
{
	import M2D.particles.ParticleInstance;
	import M2D.particles.ParticleSymbol;
	import M2D.sprites.Actor;
	import M2D.sprites.Asset;
	import M2D.time.Clock;
	import M2D.time.IClockListener;
	import M2D.worlds.BatchTexture;
	import M2D.worlds.World;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Mouse;
	import flash.utils.getTimer;
	
	import mx.utils.NameUtil;
	
	import zones.BitmapDataZone;
	import zones.PointZone;
	import zones.RectangleZone;
	import zones.Zone2D;
	
	[SWF(width="1400", height="1050", frameRate="60", backgroundColor="0xFFFFFF")]
	public class MHPTest extends Sprite implements IClockListener
	{
		public var tf:TextField;
		public static const smoothWindow:int = 100;
		
		private var world:M2D.worlds.World;
		private var ps:Array = [];
		
		[Embed(source="assets/smiley.png")]
		public var smiley:Class;
		
		[Embed(source="assets/smileyRect.png")]
		public var smileyRect:Class;
		
		[Embed(source="assets/circle.png")]
		public var flashBubble:Class;
		
		[Embed(source="assets/knightRun.png")]
		public var knight:Class;
		
		[Embed(source="assets/glow.png")]
		public var dot:Class;
		
		[Embed(source="assets/air.jpg")]
		public var air:Class;
		
		public var viewWidth:Number;
		public var viewHeight:Number;
		
		public var particleSymbol:ParticleSymbol; 
		public function MHPTest()
		{
			viewWidth = 1400;
			viewHeight = 1050;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			_clock = new M2D.time.Clock(60);
			_clock.addListener(this);
			
			
			world = new World();
			world.backgroundColor = 0xeee8aa;
			clock.addListener(world);
			world.initContext(stage,this,0,new Rectangle(0,0,viewWidth,viewHeight));
			
			var kTexture:BatchTexture = world.assetMgr.createTextureFromDisplayObject(new air());
			particleSymbol = world.particleLibrary.createSymbol();
			
			
			particleSymbol.texture = kTexture;
			particleSymbol.birthDelay = .05;
			particleSymbol.lifespan = 2000;
			particleSymbol.generateInWorldSpace = true;
			
			var f:Bitmap = new flashBubble();
			
			var bz:BitmapDataZone = new BitmapDataZone(f.bitmapData,0,0,.5,.5);
			particleSymbol.birthZone = bz;//new PointZone(new Point(0,0));//bz//RectangleZone(-200,-200,200,200);
			var flash:BatchTexture = world.assetMgr.createTextureFromDisplayObject(f);
			
//			particleSymbol.gravityX = particleSymbol.gravityY;
			particleSymbol.gravityY *= 2;
	//		particleSymbol.maxParticles = 1000;
			
			var asset:Asset = world.library.createAsset(flash);

			var maxLiving:Number = Math.ceil(particleSymbol.lifespan/particleSymbol.birthDelay);
			var numGenerators:Number = 1;
			trace("Max symbols per generator:",maxLiving);
			trace("total #:",maxLiving*numGenerators);
			var particle:ParticleInstance;
			
			var z:Zone2D = new RectangleZone(-200,-200,200,200);
			for(var i:int = 0;i<numGenerators;i++) {
				

				particle = particleSymbol.createInstance();
				particle.x = Math.random()*viewWidth/2 + viewWidth/4 - viewWidth/4;
				particle.y = Math.random() * 400+ 500 - 200;
				particle.depth = -10 ;

				var ac:Actor = asset.createActor();
				ac.depth = -20;
				ac.scaleX = ac.scaleY = .5;
				ac.regX = ac.regY = 0;
				ac.x = particle.x;
				ac.y = particle.y;
				particle.clock = _clock;
//				particle.rotation = Math.random() * 360 ;
				particle.start();
				ps.push({p:particle,ac:ac});
				
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

			_clock.start();
			tf.addEventListener(MouseEvent.CLICK,clickHandler);
			
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
		
		private var prevX:Number;
		private var prevY:Number;
		public function tick():void
		{
			report();
			
			
			prevX = mouseX;
			prevY = mouseY;
			for each(var p:* in ps)
			{
//				p.rotation += .5;//Math.random()*3;
				//p.x = p.x + (mouseX - p.x)*.1;
				//p.y = p.y + (mouseY - p.y)*.1;
				p.p.x = mouseX;
				p.p.y= mouseY;
				p.ac.x = mouseX;
				p.ac.y= mouseY;
			}

		}
		private function report():void
		{
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
				"\nnumber of particles (avg): " + (particleSymbol.possibleNumLivingParticles * ps.length) + 
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