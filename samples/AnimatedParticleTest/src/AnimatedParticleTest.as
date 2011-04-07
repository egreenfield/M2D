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
	import M2D.particles.ParticleData;
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
	
	[SWF(width="1400", height="1050", frameRate="60", backgroundColor="0x000000")]
	public class AnimatedParticleTest extends Sprite implements IClockListener
	{
		public var tf:TextField;
		public static const smoothWindow:int = 100;
		
		private var world:M2D.worlds.World;
		private var ps:Array = [];
		
		[Embed(source="assets/explosion.png")]
		public var explosionPng:Class;
		
		public var viewWidth:Number;
		public var viewHeight:Number;
		
		public var particleSymbol:ParticleSymbol; 
		public function AnimatedParticleTest()
		{
			viewWidth = 1400;
			viewHeight = 1050;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			_clock = new M2D.time.Clock(60);
			_clock.addListener(this);
			
			
			world = new World();
			world.backgroundColor = 0x000000;
			clock.addListener(world);
			world.initContext(stage,this,0,new Rectangle(0,0,viewWidth,viewHeight));
			
			var tex:BatchTexture = world.assetMgr.createTextureFromDisplayObject(new explosionPng());
			var explosion:Asset = world.library.createAsset(tex);
			explosion.cellColumnCount = 5;
			explosion.cellRowCount = 5;
			
			particleSymbol = world.particleLibrary.createSymbol();
			particleSymbol.asset = explosion;
			particleSymbol.birthDelay = 10;
			particleSymbol.lifespan = 1840;
			
			particleSymbol.firstCellInAnimation = 0;
			particleSymbol.numCellsInAnimation = 23;
			particleSymbol.milliPerFrameInAnimation = 80;
			
			particleSymbol.generateInWorldSpace = true;
			particleSymbol.initializeParticleCallback = initParticle;
//			particleSymbol.gravityY *= .5;
			

			
			var maxLiving:Number = Math.ceil(particleSymbol.lifespan/particleSymbol.birthDelay);
			trace("Max symbols per generator:",maxLiving);
			trace("total #:",maxLiving);
			var particle:ParticleInstance;
			particle = particleSymbol.createInstance();
			particle.x = viewWidth/2;
			particle.y = viewHeight/2;
			particle.depth = 10 ;

			particle.clock = _clock;
			particle.start();

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
		
		public function initParticle(d:ParticleData):void
		{
			d.location.x = Math.random()*300 - 150;
			d.location.y = Math.random()*300 - 150;
			d.direction = (Math.random()*.5+.5-.25)*-Math.PI;//(birthTime%1000)/1000*2*Math.PI * (Math.random() * .4 + .8);
			d.speed = (Math.random() * 400 + 100)/1000/2;
			d.angularVelocity = (Math.random() * Math.PI*2)  / 1000;
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
			report();
			
		}
		private function report():void
		{
			var t:Number = clock.currentTime;
			var delta:Number = t - previousTime;
			fps.sample((1/delta)*1000);
			mpf.sample(delta);
			
			previousTime = t;
			reportTime(clock.processingTime,0,0);
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
				"\nnumber of particles (avg): " + (particleSymbol.possibleNumLivingParticles ) + 
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