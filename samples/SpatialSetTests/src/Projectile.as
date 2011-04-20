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
	import M2D.sprites.Asset;
	import M2D.time.Clock;
	
	public class Projectile extends Clip 
	{
		public var speed:Number = 1;
		private var direction:int = 0;
		private var wrapBorder:int = 75;
		private var anim:CellAnimation;
		private static var _spriteSheet:Asset;
		
		[Embed(source="assets/smiley.png")]
		public static var smiley:Class;
		
		public function Projectile(clock:Clock)
		{
			actor = spriteSheet.createActor();
			actor.x = Math.random() * CollisionTest.viewWidth;
			actor.y = Math.random() * CollisionTest.viewHeight;

			var rnd:Number = ((Math.random() * 4 ) % 3) * .25;
			actor.scaleX = rnd;
			actor.scaleY = rnd;
			actor.rotation = Math.random() * 360;
			
			speed = 3.0;
			direction = Math.floor(Math.random()*7);			
			
			super(actor);
		}
		
		private static function get spriteSheet():Asset
		{
			if (!_spriteSheet)
			{
				_spriteSheet = CollisionTest.world.assetMgr.createAssetFromDisplayObject(new smiley());
				_spriteSheet.hasAlphaChannel = true;
			}
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
			
			x = (x > CollisionTest.viewWidth + wrapBorder) ? -wrapBorder : x;
			x = (x < -wrapBorder) ? CollisionTest.viewWidth + wrapBorder : x;
			y = (y > CollisionTest.viewHeight + wrapBorder) ? -wrapBorder : y;
			y = (y < -wrapBorder) ? CollisionTest.viewHeight + wrapBorder : y;
			
			actor.x = x;
			actor.y = y;
			
			notifyPositionChanged();
		}
	}
}