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
	
	import M2D.animation.CellAnimation;
	import M2D.sprites.Actor;
	import M2D.sprites.Asset;
	import M2D.time.Clock;
	import M2D.time.IClockListener;
	import M2D.worlds.BatchTexture;
	import M2D.worlds.World;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	
	import mx.utils.NameUtil;
	
	[SWF(width="1200", height="1050", frameRate="60", backgroundColor="0xFFFFFF")]
	public class MHSpriteTest extends Sprite implements IClockListener
	{
		private var actor:Actor;
		public var tf:TextField;
		public static const smoothWindow:int = 100;
		public static const actorWidth:int = 40;
		public static const actorHeight:int = 40;

		private var world:World;

		
		[Embed(source="assets/smiley.png")]
		public var smiley:Class;
		
		[Embed(source="assets/smileyRect.png")]
		public var smileyRect:Class;

		[Embed(source="assets/flash.png")]
		public var flashBubble:Class;
		
		[Embed(source="assets/knightRun.png")]
		public var knight:Class;

		
		public var viewWidth:Number = 1200;
		public var viewHeight:Number = 1050;
		
		public function MHSpriteTest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			_clock = new Clock(60);
			_clock.addListener(this);
			
			
			world = new World();
			world.backgroundColor = 0xFFFFFF;
			clock.addListener(world);
			world.initContext(stage,this,0,new Rectangle(0,0,viewWidth,viewHeight));
	
			var kTexture:BatchTexture = world.assetMgr.createTextureFromDisplayObject(new knight());
			var knightAsset:Asset = world.library.createAsset(kTexture);
			
			knightAsset.cellColumnCount = 10;
			knightAsset.cellRowCount = 8;
			
			var assets:Array = [knightAsset];
			var animations:Array = [new CellAnimation(clock,20,10)];
			animations[0].mpf=1000/20;
			
			var spinner:int = 0;
			
			var cellWidth:Number = viewWidth/actorWidth;
			var cellHeight:Number = viewHeight/actorHeight;
			
			var anim:CellAnimation;
//			for(var j:int = 0;j<actorHeight;j++) {
			for(var i:int = 0;i<7000;i++) {
				actor = assets[spinner].createActor();
				anim= (animations[spinner] == null)?null:animations[spinner].clone();
				if(anim != null)
				{
					anim.actor = actor;
					anim.base = Math.floor(Math.random()*7)*10;
					anim.currentFrame = Math.random()*anim.length + anim.base;
					anim.start();
				}
				spinner = (spinner + 1) % assets.length;
				var s:Number = 1;//Math.random() * 2 + .75;
				actor.scaleX = Math.max(.1,cellWidth/actor.width * s);
				actor.scaleY = Math.max(.1,cellHeight/actor.height * s);
				actor.depth = Math.random() * -1;
				var ca:CirclingActor = new CirclingActor(actor);
				ca.centerX = Math.random() * viewWidth;//cellWidth * (i + .5);
				ca.centerY = Math.random() * viewHeight;//cellHeight * (j +.5);
				ca.radius = Math.random() * cellWidth * .3;
				ca.speed = Math.random() * .4 + .8;
				circles.push(ca);
//				}
			}
			
		
			
			tf = new TextField();
//			tf.width = viewWidth;
//			tf.height = viewHeight;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.width = 300;
			tf.background = true;
			tf.border = true;
			addChild(tf);
			
			_clock.start();
			
		}
		private var circles:Vector.<CirclingActor> = new Vector.<CirclingActor>();
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
		
		public var doneOnce:Boolean = false;
		public function tick():void
		{
//			actor.x = 427+ Math.cos(getTimer()/1000*Math.PI*2)*50;
	//		actor.y = 240 + + Math.sin(getTimer()/1000*Math.PI*2)*50

			if(doneOnce == false)
			{
				for(var i:int = 0;i<circles.length;i++) {
				circles[i].update();
				}
				doneOnce = true;
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