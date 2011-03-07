package
{
	import M2D.sprites.Actor;
	
	import flash.utils.getTimer;
	
	public class CirclingActor
	{
		public var actor:Actor;
		public function CirclingActor(a:M2D.sprites.Actor)
		{
			actor = a;
			super();
		}
		public var centerX:Number;
		public var centerY:Number;
		public var radius:Number;
		public var speed:Number = 1;
		public function update():void
		{
			actor.x = centerX + Math.cos(getTimer()/1000* speed * Math.PI*2)*radius;
			actor.y = centerY + + Math.sin(getTimer()/1000* speed * Math.PI*2)*radius
			actor.rotation = Math.sin(getTimer()/1000* speed * Math.PI*2)*20;
		}
	}
}