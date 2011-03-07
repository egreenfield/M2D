package M2D.time
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

		private var startTime:Number;
		public var currentTime:int;
		public var processingTime:Number = 0;
		public var paused:Boolean = false;
		
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