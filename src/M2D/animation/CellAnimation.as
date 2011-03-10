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
package M2D.animation
{
	import M2D.sprites.Actor;
	import M2D.time.Clock;
	import M2D.time.IClockListener;

	public class CellAnimation implements IClockListener
	{
		private var _clock:Clock;
		private var _actor:Actor;
		private var _base:int;
		private var _length:int;
		private var _mpf:Number = 1000/30;
		private var _currentFrame:int = 0;
		private var _lastFrameTime:Number;
		
		public function CellAnimation(clock:Clock,base:int,length:int,actor:Actor = null)
		{
			_clock = clock;
			_actor = actor;
			_base = base;
			_length = length;
			_currentFrame = Math.max(Math.min(_currentFrame,(_base+_length-1)),_base);
		}
		
		public function get currentFrame():int
		{
			return _currentFrame;
		}

		public function set currentFrame(value:int):void
		{
			_currentFrame = value;
		}

		public function get length():int
		{
			return _length;
		}

		public function set length(value:int):void
		{
			_length = value;
		}

		public function get base():int
		{
			return _base;
		}

		public function set base(value:int):void
		{
			_base = value;
		}

		public function clone():CellAnimation
		{
			var c:CellAnimation = new CellAnimation(_clock,_base,_length,_actor);
			c._mpf = _mpf;
			c._currentFrame = _currentFrame;
			
			return c;
		}
		
		public function get actor():Actor
		{
			return _actor;
		}

		public function set actor(value:Actor):void
		{
			_actor = value;
		}

		public function get clock():Clock
		{
			return _clock;
		}

		public function set clock(value:Clock):void
		{
			_clock = value;
		}

		public function get mpf():Number
		{
			return _mpf;
		}

		public function set mpf(value:Number):void
		{
			_mpf = value;
		}

		public function start():void
		{
			_lastFrameTime = _clock.currentTime;
			_currentFrame = _actor.cell;
			_clock.addListener(this);
		}
		public function tick():void
		{
			var tDelta:Number = clock.currentTime - _lastFrameTime;
			var elapsedFrames:Number = Math.floor(tDelta/_mpf);
			var newFrame:int = _base + (_currentFrame - _base + elapsedFrames)%_length;
			_actor.cell = newFrame;
		}
	}
}