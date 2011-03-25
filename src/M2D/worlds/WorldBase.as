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
*/package M2D.worlds
{
	import M2D.core.GContext;
	import M2D.time.Clock;
	import M2D.time.IClockListener;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.geom.Matrix3D;
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

		private var renderMode:String = Context3DRenderMode.AUTO;		
		public var context3D:Context3D;
		public var gContext:GContext = new GContext();
		
		public var cameraMatrix:Matrix3D;
		
		
		
		private var stage3D:Stage3D;
		public var antiAliasDepth:int = 2;
		private var cameraDirty:Boolean = true;
		
		private var jobs:Vector.<IRenderJob> = new Vector.<IRenderJob>();
		
		
		public function initContext(stage:Stage,container:DisplayObjectContainer,slot:int,bounds:Rectangle):void
		{
			this.bounds = bounds.clone();
			this.slot = slot;
			this.stage = stage;
			acquireContext();
		}
		
		private function acquireContext():void
		{
			stage3D = stage.stage3Ds[slot];
			
			stage3D.viewPort = bounds;
			context3D = stage3D.context3D;
			if(context3D == null)
			{
				stage3D.addEventListener ( Event.CONTEXT3D_CREATE, stageNotificationHandler,false,0,true);
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
			context3D.enableErrorChecking = false;
			context3D.configureBackBuffer( bounds.width, bounds.height, antiAliasDepth, true); // fixed size
			context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context3D.setDepthTest(true,Context3DCompareMode.LESS_EQUAL);
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
		
		public function render():void
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
		
		public function addJob(job:IRenderJob):void
		{
			jobs.push(job);
			job.world = this;
		}
		
		public function get clock():Clock
		{
			return _clock;
		}

		public function set clock(value:Clock):void
		{
			_clock = value;
		}

		
		public function tick():void
		{
			render();
		}
		
	}
}