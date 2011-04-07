/*
 * LotsOfCoins - M2D Sample
 * Author: Terry Paton
 */
package {
	import M2D.animation.CellAnimation;
	import M2D.sprites.Actor;
	import M2D.sprites.Asset;
	import M2D.worlds.BatchTexture;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	[SWF(width="800", height="480", frameRate="40", backgroundColor="0xB0E0E5")]
	public class LotsOfCoins extends Sprite 
	{
		private static const totalObjects:int=4000;
		public var images:Vector.<CoinClip>;
		public var tf2:TextField;
		protected var scene:RenderScene;
		private var instanceCount:int=0;
		private var fallingSpeed:Number=5
		private var frames:int=0;
		private var coinAsset:Asset;
		public static var edgeBuffer:Number=10;
		public static var stageWidth:Number=800;
		public static var stageHeight:Number=480;
		private var _mouseX:Number;
		private var _mouseY:Number;
		private var dx:Number;
		private var dy:Number;
		private var dist:Number;
		
		[Embed(source="assets/coin.png")]
		public var coinPng:Class;
		
		public function LotsOfCoins() 
		{
			super();
			scene=new RenderScene(800, 480);
			addChild(scene);
			createStats();
			
			images=new Vector.<CoinClip>();
			var n:int=totalObjects;
			while (n--) {
				addObject()
			}

			addEventListener(Event.ENTER_FRAME, loop);
		}

		private function addObject():void 
		{
			if (instanceCount < totalObjects) 
			{				
				var image:CoinClip = image=scene.addAnimatedSprite(coinPng);

				image.x=Math.random() * stageWidth;
				image.y=Math.random() * stageHeight;
				image.rotate(Math.random() * 360);

				images.push(image);
				instanceCount++;
				tf2.text = String(instanceCount) + " Objects";
				var animation:CellAnimation=new CellAnimation(scene._clock, 0, 24);
				animation.actor=image.actorRef;
				image.actorRef.cell=int(Math.random() * 20)
				image.animationRef=animation
			}
		}
		
		protected function loop(event:Event):void 
		{
			_mouseX = mouseX;
			_mouseY = mouseY;

			var image:CoinClip
			var l:uint=images.length;
			for (var i:Number=0; i < l; i++) 
			{
				image=images[i];
				
				// find how close item is to the mouse
				dx=image.x - _mouseX;
				dy=image.y - _mouseY;
				dist=Math.floor(Math.sqrt(dx * dx + dy * dy));
				
				if (dist < 100) 
				{
					// push the item away
					image.velocityx=dx * .1
					image.velocityy=dy * .1
				}
				image.manage()
			}
		}
		
		private function createStats():void
		{
			tf2=new TextField();
			tf2.autoSize=TextFieldAutoSize.LEFT;
			tf2.width=300;
			tf2.x=80
			tf2.background=true;
			tf2.border=true;
			addChild(tf2);
			tf2.text=String(instanceCount) + " Objects";
			addChild(new Stats());
		}
	}
}