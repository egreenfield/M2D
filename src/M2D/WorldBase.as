package M2D
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.geom.Rectangle;

	public class WorldBase implements IClockListener
	{
		protected var bounds:Rectangle;
		protected var slot:int;
		protected var stage:Stage;
		public var backgroundColor:uint = 0xFFAAAA;
		private var _clock:Clock;
		
		public function WorldBase()
		{
		}

		public function get clock():Clock
		{
			return _clock;
		}

		public function set clock(value:Clock):void
		{
			_clock = value;
		}

		public function initContext(stage:Stage,root:DisplayObjectContainer,slot:int,bounds:Rectangle):void
		{
			this.bounds = bounds.clone();
			this.slot = slot;
			this.stage = stage;
			
		}
		
		public function tick():void
		{
			render();
		}
		
		public function render():void
		{
			
		}
		
		public function addActor(actor:Actor):Actor
		{
			return actor;
		}
		
		public function removeActor(actor:Actor):Actor
		{
			return actor;
		}
		
		public function addJob(job:IRenderJob):void
		{
		}
	}
}