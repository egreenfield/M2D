package M2D.worlds
{
	import M2D.core.GContext;
	import M2D.particles.ParticleLibrary;
	import M2D.sprites.SymbolLibrary;
	
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class World extends WorldBase
	{
		public function World()
		{
			assetMgr = new AssetMgr(this);
			addJob(library);
			addJob(particleLibrary);
		}
		// ======================================================================
		//	Constants
		// ----------------------------------------------------------------------
		
		
		private var renderMode:String = Context3DRenderMode.AUTO;
		public var context3D:Context3D;
		public var gContext:GContext = new GContext();
		
		public var cameraMatrix:Matrix3D;
		
		
		public var assetMgr:AssetMgr;
		public var particleLibrary:ParticleLibrary = new ParticleLibrary();
		public var library:SymbolLibrary = new SymbolLibrary();
		
		private var stage3D:Stage3D;
		public var antiAliasDepth:int = 2;
		private var cameraDirty:Boolean = true;
		
		private var jobs:Vector.<IRenderJob> = new Vector.<IRenderJob>();
		

		override public function initContext(stage:Stage,container:DisplayObjectContainer,slot:int,bounds:Rectangle):void
		{
			super.initContext(stage,container,slot,bounds);			
			acquireContext();
		}
		
		private function acquireContext():void
		{
			stage3D = stage.stage3Ds[slot];
		
			stage3D.viewPort = bounds;
			context3D = stage3D.context3D;
			if(context3D == null)
			{
				stage3D.addEventListener ( Event.CONTEXT3D_CREATE, stageNotificationHandler,false,0,true );
				stage3D.requestContext3D ( renderMode );										
			}
			else
			{
				initContext3D();
			}
		}
		private function stageNotificationHandler(e:Event):void
		{
			context3D = stage3D.context3D;
			initContext3D();	
		}
		
		private function initContext3D():void
		{
			context3D.enableErrorChecking = true;
			context3D.configureBackBuffer( bounds.width, bounds.height, antiAliasDepth, false); // fixed size
			context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			gContext.init(context3D);
		}
		

		
		private function buildCameraMatrix():void
		{
			if(cameraDirty == false)
				return;
			trace("Build Camera");
			cameraMatrix = new Matrix3D();
			cameraMatrix.appendScale(2/bounds.width,-2/bounds.height,1);
			cameraMatrix.appendTranslation(-1,1,0);//(bounds.left-stage3D.viewPort.width/2),0,0);//-(bounds.top - stage3D.viewPort.height/2),0);
				
			gContext.cameraMatrix = cameraMatrix;
			cameraDirty = false;
		}
		public var timeInDrawTriangles:int = 0;
		public var numDrawTrianglesCallsPerFrame:int = 0;
		
		override public function render():void
		{
			timeInDrawTriangles = 0;
			numDrawTrianglesCallsPerFrame = 0;
			
			if(context3D == null)
				return;

			context3D.clear(((backgroundColor & 0xFF0000) >> 16	)/256,
				((backgroundColor & 0x00FF00) >> 8	)/256,
				((backgroundColor & 0x0000FF) 		)/256);

			if(cameraDirty)
			{
				buildCameraMatrix();
			}
			
			
			var nextGroup:int = 0;
			
			for(var i:int=0 ; i<jobs.length;i++) {
				jobs[i].render();
				timeInDrawTriangles += jobs[i].timeInDrawTriangles;
				numDrawTrianglesCallsPerFrame += jobs[i].numDrawTrianglesCallsPerFrame;
			}
			context3D.present();
		}
				
		override public function addJob(job:IRenderJob):void
		{
			jobs.push(job);
			job.world = this;
		}			
	}
}
