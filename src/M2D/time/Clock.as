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
*/package M2D.time
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class Clock
	{
		protected var timer:Timer;
		protected var _frameRate:int = 60;
		public var maxDeltaMilliseconds:Number = 0; 
		private var startTime:Number;
		public var currentTime:int;
		public var processingTime:Number = 0;
		public var paused:Boolean = false;
		public var lastUpdateTime:Number;
		
		public function Clock(frameRate:int = 60)
		{
			_frameRate = frameRate;			
		}
		
		public function start():void
		{
			timer = new Timer(1000/_frameRate);
			timer.addEventListener(TimerEvent.TIMER,timerHandler);
			startTime = getTimer();
			timer.start();
		}
		protected function timerHandler(e:TimerEvent):void
		{
			if(paused == false)
			{
				var startT:Number = getTimer();
				if(maxDeltaMilliseconds > 0 && startT - lastUpdateTime > maxDeltaMilliseconds)
				{
					startT += (startT - (lastUpdateTime-maxDeltaMilliseconds));
				}
				currentTime = startT-startTime;
			}
			for(var i:int =0;i<listeners.length;i++) 
			{
				listeners[i].tick();					
			}
			processingTime = getTimer() - startT; 
		}
		
		private var listeners:Vector.<IClockListener> = new Vector.<IClockListener>();

		public function pause():void
		{
			paused = true;
		}
		public function unpause():void
		{
			var startT:Number = getTimer();
			startTime = startT-currentTime;
			paused = false; 
		}
		public function addListener(l:IClockListener):void
		{
			listeners.push(l);	
		}
		
	}
}