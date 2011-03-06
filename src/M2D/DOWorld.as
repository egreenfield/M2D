package M2D
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	public class DOWorld extends WorldBase
	{
		
		private var actors:Vector.<Actor> = new Vector.<Actor>();
		private var bitmaps:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		private var root:Sprite;
		
		public function DOWorld()
		{
		}
		
		override public function initContext(stage:Stage,container:DisplayObjectContainer,slot:int,bounds:Rectangle):void
		{
			super.initContext(stage,container,slot,bounds);
			root = new Sprite();
			container.addChild(root);
		}
		override public function tick():void
		{
			var t:Number = getTimer();
			
			for(var i:int = 0;i<actors.length;i++) {
				var actor:Actor = actors[i];
				var bmp:DisplayObject = bitmaps[i];
				bmp.transform.matrix = actor.get2DMatrix();
			}	
		}
		override public function addActor(actor:Actor):Actor
		{
			actors.push(actor);
//			var bmp:Bitmap = new Bitmap(actor.asset.data,PixelSnapping.NEVER,false);
//			bitmaps.push(bmp);
//			root.addChild(bmp);
			return actor;
		}
	}
}
