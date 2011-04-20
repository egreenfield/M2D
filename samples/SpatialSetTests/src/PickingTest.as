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
	import M2D.sprites.Actor;
	import M2D.sprites.Asset;
	import M2D.time.Clock;
	import M2D.time.IClockListener;
	import M2D.worlds.World;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import spatial.HierarchicalGrid;
	import spatial.ISpatialSet;
	import spatial.SimpleSpatialSet;
	
	/**
	 * Simple example exercising the HierarchicalGrid spatial manager's picking methods.
	 * Swap the HierarchicalGrid with a SimpleSpatialSet to contrast with a brute
	 * force approach. Time (ms) to query is presented in stats window.
	 */ 
	[SWF(width="1014", height="768", frameRate="60", backgroundColor="0xB0E0E5")]
	public class PickingTest extends Sprite implements IClockListener
	{
		public static var world:World;
		public static var viewWidth:Number = 1014;
		public static var viewHeight:Number = 768;
		public static var cellWidth:Number = 44;
		public static var cellHeight:Number = 44;
		public static var layerHeight:Number = 25;
		public static var worldMax:int = 100;
		
		public var queryTime:Number = 0;
		private var instanceCount:Number = 0;
		private var actors:Vector.<Actor> = new Vector.<Actor>();
		
	    private var spatialManager:ISpatialSet = new HierarchicalGrid(viewWidth, viewHeight);
		//private var spatialManager:ISpatialSet = new SimpleSpatialSet(viewWidth, viewHeight);
		
		[Embed(source="assets/tile.png")]
		public static var Tile:Class;
		
		[Embed(source="assets/brick.png")]
		public static var BlueTile:Class;
		
		public function PickingTest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			world = new World();
			world.backgroundColor = 0xB0E0E5;
			world.initContext(stage,this,0,new Rectangle(0,0,viewWidth,viewHeight));
			
			_clock = new Clock(60);
			_clock.addListener(this);
			clock.addListener(world);

			buildFoundation();
			createStats();
			createInfo();

			_clock.start();
			
			stage.addEventListener("click", stageClickHandler);
			stage.addEventListener("mouseMove", stageMouseMoveHandler);
			stage.addEventListener("keyDown", stageKeyDownHandler);
			stage.addEventListener("keyUp", stageKeyUpHandler);
		}
		
		private function buildFoundation():void
		{
			var texture:Asset = world.assetMgr.createAssetFromDisplayObject(new Tile());
			texture.hasAlphaChannel = true;
			
			var offsetX:Number = .5; 
			var offsetY:Number = viewHeight * .75; 
			var size:int = 25;
			
			// Foundation
			createCube(texture, 0, 0, 0, size, size, 3, offsetX, offsetY);

			// Left and Right Stairs
			createStairs(0, texture, 0, 0, 3, 7, size-1, 9, offsetX, offsetY, 1, .7);
			createStairs(1, texture, 0, 17, 3, size, 7, 9, offsetX, offsetY, 1, .7);

			// A few other material elements.
			texture = world.assetMgr.createAssetFromDisplayObject(new BlueTile());
			texture.hasAlphaChannel = true;
			createCube(texture, 8, 13, 3, 3, 3, 4, offsetX, offsetY-11, 2, .8);
			createCube(texture, 2, 17, 13, 6, 6, 1, offsetX, offsetY-8, 2, .8);
		}
				
		private function placeTile(actor:Actor, row:int, col:int, layer:int, cellWidth:Number, cellLength:Number, cellHeight:Number, offsetX:Number, offsetY:Number):void
		{
			actor.x = (row + col) * (cellWidth / 2) + offsetX;
			actor.y = (cellLength/4) * (row - col) +  offsetY - ((cellHeight) * layer);
			actor.depth = ((row + 1) + (worldMax-col) + (layer+1));
		}
		
		
		private function createCube(texture:Asset, r:int, c:int, l:int, width:int, length:int, 
									height:int, tileOffsetX:Number, tileOffsetY:Number, size:int=1, alpha:Number=1):void
		{
			for (var level:int = l; level < l + height; level++)
			{
				for (var row:int = r; row < r + width; row+=size)
				{
					for (var col:int = c; col < c+length; col+=size)
					{
						var actor:Actor = texture.createActor();
						placeTile(actor, row, col, level, cellWidth, cellHeight, layerHeight, tileOffsetX, tileOffsetY);
						actors.push(actor);
						spatialManager.add(new Clip(actor));
						actor.alpha = alpha;
						instanceCount++
					}
				}
			}
		}
		
		private function createStairs(direction:int, texture:Asset, r:int, c:int, l:int, width:int, length:int, 
									height:int, tileOffsetX:Number, tileOffsetY:Number, size:int=1, alpha:Number=1):void
		{
			var endRow:int = r + width;
			var startCol:int = c;
			
			for (var level:int = l; level < l + height; level++)
			{
				for (var row:int = r; row < endRow; row+=size)
				{
					for (var col:int = startCol; col < c+length; col+=size)
					{
						var actor:Actor = texture.createActor();
						placeTile(actor, row, col, level, cellWidth, cellHeight, layerHeight, tileOffsetX, tileOffsetY);
						actors.push(actor);
						spatialManager.add(new Clip(actor));
						actor.alpha = alpha;
						instanceCount++;
					}
				}
				if (direction == 0) startCol++; else endRow--;
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
			updateStats();
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
		
		private function createInfo():void
		{
			var info:TextField = new TextField();
			var format:TextFormat = new TextFormat();
			info.background = false;
			info.text = "Click to toggle individual tile alpha. Press 'A' or 'S' while moving mouse for interactive test...";
			info.autoSize = "right";
			format.color = 0xFFFFFF;
			format.italic = true;
			format.bold = true;
			format.size = 16;
			info.x = viewWidth - info.width;
			info.setTextFormat(format);
			info.defaultTextFormat = format;
			addChild(info);
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
				"number of actors: " + instanceCount + 
				"\nfps: " + fps.average + 
				"\nmilli/frame: " + mpf.average + 
				"\ntotal AS processing: " + asProcessing.average + 
				"\nlast hit test query: " + queryTime +
				"";
		}
		
		private function stageClickHandler(event:MouseEvent):void
		{
			var s:Number = getTimer();
			var clip:Clip = 
				spatialManager.queryObjectAtPoint(new Point(event.stageX, event.stageY), true) as Clip;
			queryTime = getTimer() - s;
			if (clip)
				clip.alpha = clip.alpha == 1 ? .5 : 1;
		}
		
		private var keyMap:Object = new Object();
		private function stageKeyUpHandler(event:KeyboardEvent):void
		{
			keyMap[event.keyCode] = false;
		}
		
		private function stageKeyDownHandler(event:KeyboardEvent):void
		{
			keyMap[event.keyCode] = true;
		}
		
		private function stageMouseMoveHandler(event:MouseEvent):void
		{
			if (keyMap[65] || keyMap[83])
			{
				var s:Number = getTimer();
				var clip:Clip = spatialManager.queryObjectAtPoint(new Point(event.stageX, event.stageY), true) as Clip;
				queryTime = getTimer() - s;
				if (clip)
					clip.alpha = keyMap[65] ? 1 : .5;
			}
		}
	}
}