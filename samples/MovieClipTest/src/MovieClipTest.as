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
*/

package
{
	import M2D.animation.CellAnimation;
	import M2D.sprites.Actor;
	import M2D.sprites.Asset;
	import M2D.time.Clock;
	import M2D.worlds.World;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	
	[SWF(width="650", height="400", frameRate="60", backgroundColor="0xB0E0E5")]
	public class MovieClipTest extends Sprite 
	{
		private var world:World;
		private var clock:Clock;
		
		[Embed(source="assets/snake.swf", symbol="Snake")]
		public var snake:Class;
		
		[Embed(source="assets/rocket.swf", symbol="Rocketship")]
		public var rocket:Class;
		
		public function MovieClipTest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			world = new World();
			world.backgroundColor = 0xB0E0E5;
			world.initContext(stage, this, 0, new Rectangle(0, 0, stage.stageWidth, stage.stageHeight));
			
			clock = new Clock(60);
			clock.start();
			clock.addListener(world);
			
			createSnake();
			createRocket();
		}
		
		private function createSnake():void
		{
			// Create sprite sheet asset from embedded MovieClip/SpriteAsset instance.
			var spriteSheet:Asset = world.assetMgr.createAssetFromAnimatedDisplayObject(new snake(), 1);
			
			// Spawn an actor and position it.
			var actor:Actor = spriteSheet.createActor();
			actor.x = 150;
			actor.y = 250;
			
			// Create a cell animation to increment our animation frames.
			// Set our animation speed to 15 fps.
			var animator:CellAnimation = new CellAnimation(clock, 0, spriteSheet.frameCount, actor);
			animator.mpf = 1000.0 / 15.0;
			animator.start();
			
			// Add generated sprite sheet to display list for demonstration purposes.
			var sheet:Bitmap = new Bitmap(spriteSheet.texture.data);
			sheet.x = 0;
			sheet.y = 50;
			sheet.scaleX = .5;
			sheet.scaleY = .5;
			addChild(sheet);
		}
		
		private function createRocket():void
		{
			// Create sprite sheet asset from embedded MovieClip/SpriteAsset instance. In this
			// case we generate a sprite sheet at 2x scale.
			var spriteSheet:Asset = world.assetMgr.createAssetFromAnimatedDisplayObject(new rocket(), 1, 2, 2);
			
			// Spawn an actor and position it.
			var actor:Actor = spriteSheet.createActor();
			actor.x = 390;
			actor.y = 150;
			
			// Create a cell animation to increment our animation frames.  
			// Set our animation speed to 40 fps.
			var animator:CellAnimation = new CellAnimation(clock, 0, spriteSheet.frameCount, actor);
			animator.mpf = 1000.0 / 40.0;
			animator.start();
			
			// Add generated sprite sheet to display list for demonstration purposes.
			var sheet:Bitmap = new Bitmap(spriteSheet.texture.data);
			sheet.x = 500;
			sheet.scaleX = .5;
			sheet.scaleY = .5;
			addChild(sheet);
		}
	}
}