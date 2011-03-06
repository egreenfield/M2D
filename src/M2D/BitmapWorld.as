package M2D
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.PixelSnapping;
	import flash.display.Stage;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	public class BitmapWorld extends WorldBase
	{
		
		private var actors:Vector.<Actor> = new Vector.<Actor>();
		private var bmp:Bitmap;
		private var surface:BitmapData;
		
		public function BitmapWorld ()
		{
		}
		
		override public function initContext(stage:Stage,container:DisplayObjectContainer,slot:int,bounds:Rectangle):void
		{
			super.initContext(stage,container,slot,bounds);
			surface = new BitmapData(bounds.width,bounds.height);
			bmp = new Bitmap(surface,PixelSnapping.NEVER,false);
			container.addChild(bmp);
		}
		override public function tick():void
		{
			var t:Number = getTimer();
			for(var i:int = 0;i<actors.length;i++)
			{
				actors[i].update();
			}
			
			surface.fillRect(new Rectangle(0,0,bounds.width,bounds.height),backgroundColor);
			for(i = 0;i<actors.length;i++) {
				var actor:Actor = actors[i];

//				surface.draw(actor.asset.data,actor.get2DMatrix());
			}	
		}
		
		override public function addJob(job:IRenderJob):void
		{
		}
		override public function addActor(actor:Actor):Actor
		{
			actors.push(actor);
			return actor;
		}
	}
}