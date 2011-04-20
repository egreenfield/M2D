/*
* M2D 
* .....................
* 
* Author: Corey Lucier
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
	
	import M2D.time.Clock;
	import M2D.time.IClockListener;
	import M2D.worlds.World;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	
	import spatial.HierarchicalGrid;
	import spatial.ISpatialObject;
	import spatial.ISpatialSet;
	
	/**
	 * Simple example exercising the HierarchicalGrid spatial manager's queryCollisions
	 * method. Swap the HierarchicalGrid with a SimpleSpatialSet to contrast with a brute
	 * force approach.
	 */ 
	[SWF(width="1200", height="1050", frameRate="60", backgroundColor="0x00AA00")]
	public class CollisionTest extends Sprite implements IClockListener
	{
		public static const ACTOR_COUNT:int = 750;
		public static var world:World;
		public static var viewWidth:Number = 1200;
		public static var viewHeight:Number = 1050;
		public static var queryTime:Number = 0;
		private var actors:Vector.<Projectile> = new Vector.<Projectile>();
		
		private var spatialManager:ISpatialSet = new HierarchicalGrid(viewWidth, viewHeight);
		//private var spatialManager:ISpatialSet = new SimpleSpatialSet(viewWidth, viewHeight);
		
		public function CollisionTest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			world = new World();
			world.backgroundColor = 0x00CC00;
			world.initContext(stage,this,0,new Rectangle(0,0,viewWidth,viewHeight));
			
			_clock = new Clock(60);
			_clock.addListener(this);
			clock.addListener(world);

			createActors();
			createStats();

			_clock.start();
		}
		
		private function createActors():void
		{
			for(var i:int = 0; i < ACTOR_COUNT; i++) 
			{
				var instance:Projectile = new Projectile(clock);
				instance.depth = i * .5;
				actors.push(instance);
				spatialManager.add(instance);
			}
		}
				
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

			var length:int = actors.length;
			
			// Update positions
			for(var i:int = 0; i < length; i++)
			{
				actors[i].alpha = 1;
				actors[i].update();
			}

			var start:Number = getTimer();
			spatialManager.queryAllCollisions(collisionDetected);
			queryTime = getTimer() - start;
			updateStats();
		}
		
		private function collisionDetected(obj1:ISpatialObject, obj2:ISpatialObject):void
		{
			Projectile(obj1).alpha = .5;
			Projectile(obj2).alpha = .5;
		}
		// Stats Housekeeping
		
		public static const smoothWindow:int = 100;
		private var tf:TextField;
		private var previousTime:Number = 0;
		
		private var mpf:Smoother = new Smoother(smoothWindow);
		private var fps:Smoother = new Smoother(smoothWindow);
		private var asProcessing:Smoother = new Smoother(smoothWindow);
		private var lastUpdate:Number = getTimer();
		
		private function createStats():void
		{
			tf = new TextField();
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.background = true;
			tf.border = true;
			addChild(tf);
		}
		
		private function updateStats():void
		{
			var t:Number = clock.currentTime;
			var delta:Number = t - previousTime;
			fps.sample((1/delta) * 1000);
			mpf.sample(delta);
			previousTime = t;
			reportTime(clock.processingTime);
		}
		
		private function reportTime(asProcessingTime:Number):void
		{
			asProcessing.sample(asProcessingTime);

			var t:Number = getTimer();
			if( t - lastUpdate > 1000)
				lastUpdate = t;
			else
				return;
			tf.text = 
				"number of actors: " + ACTOR_COUNT + 
				"\nfps: " + fps.average + 
				"\nmilli/frame: " + mpf.average + 
				"\ntotal AS processing: " + asProcessing.average + 
				"\ncollision query: " + queryTime +
				"";
		}
		
	}
}