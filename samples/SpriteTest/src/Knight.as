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
*/

package
{
	import M2D.animation.CellAnimation;
	import M2D.sprites.Actor;
	import M2D.sprites.Asset;
	import M2D.time.Clock;
	
	public class Knight
	{
		public var actor:Actor;
		public var speed:Number = 1;
		private var direction:int = 0;
		private var wrapBorder:int = 75;
		private var anim:CellAnimation;
		private static var _spriteSheet:Asset;
		
		[Embed(source="assets/knightRun.png")]
		public static var knight:Class;
		
		public function Knight(clock:Clock)
		{
			actor = spriteSheet.createActor();
			actor.x = Math.random() * MHSpriteTest.viewWidth;
			actor.y = Math.random() * MHSpriteTest.viewHeight;
			speed = (Math.random() * 3) + 1.5;
			direction = Math.floor(Math.random()*7);
			anim = new CellAnimation(clock, 0, 10);
			anim.actor = actor;
			anim.mpf = 1000.0 / 20.0;
			anim.base = direction * 10;
			anim.start();
			super();
		}
		
		private static function get spriteSheet():Asset
		{
			if (!_spriteSheet)
				_spriteSheet = MHSpriteTest.world.assetMgr.createAssetFromDisplayObject(new knight(), 8, 10);
			return _spriteSheet;
		}
		
		public function update():void
		{
			var deg:Number = ((direction + 1) * 45 + 45) % 360;
			var rad:Number = Math.PI * deg / 180.0;
			var x:Number = actor.x + speed * Math.cos(rad);
			var y:Number = actor.y + speed * Math.sin(rad);
			
			actor.x = actor.x + speed * Math.cos(rad);
			actor.y = actor.y + speed * Math.sin(rad);
			
			x = (x > MHSpriteTest.viewWidth + wrapBorder) ? -wrapBorder : x;
			x = (x < -wrapBorder) ? MHSpriteTest.viewWidth + wrapBorder : x;
			y = (y > MHSpriteTest.viewHeight + wrapBorder) ? -wrapBorder : y;
			y = (y < -wrapBorder) ? MHSpriteTest.viewHeight + wrapBorder : y;
			
			actor.x = x;
			actor.y = y;
		}
	}
}