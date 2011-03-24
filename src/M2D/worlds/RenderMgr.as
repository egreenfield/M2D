package M2D.worlds
{
	import M2D.core.RenderTask;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;

	public class RenderMgr
	{
		private var stage:Stage;
		private var root:DisplayObject;
		
		public var autoRender:Boolean = true;
		public var world:WorldBase;
		public var renderEveryFrame:Boolean = true;
		
		public function RenderMgr(world:WorldBase)
		{
			this.world = world;
		}
		
		public function init(root:DisplayObjectContainer):void
		{
			this.root = root;
			root.addEventListener(Event.ENTER_FRAME,enterFrameHandler,false,0,true);
			if(root.stage != null)
			{
				stage = root.stage;
				if(autoRender)
					stage.addEventListener(Event.RENDER,renderHandler,false,0,true);				
			}
			else
				root.addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler,false,0,true);
		}
		
		public function addTask(task:RenderTask):void
		{
			
		}
		
		private function enterFrameHandler(e:Event):void
		{
			if(renderEveryFrame)
				stage.invalidate();
		}
		
		private function addedToStageHandler(e:Event):void
		{
			stage = e.currentTarget.stage as Stage;
			stage.addEventListener(Event.RENDER,renderHandler,false,0,true);
		}
		
		private function renderHandler(e:Event):void
		{
			if(renderEveryFrame)
				world.render();			
		}
	}
}