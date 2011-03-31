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
*/package M2D.sprites
{
	import M2D.core.IBlitOp;
	import M2D.worlds.BatchTexture;
	import M2D.worlds.IRenderJob;
	import M2D.worlds.RenderTask;
	import M2D.worlds.WorldBase;
	
	import flash.display3D.Context3D;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class SymbolLibrary implements IRenderJob
	{
		private var _world:WorldBase;
		private var _renderID:uint;
		
		public function set world(w:WorldBase):void
		{
			this._world = w;
		}
		public function get world():WorldBase
		{
			return _world;
		}
		public function SymbolLibrary()
		{
		}

		
		public function createAsset(tx:BatchTexture,rc:Rectangle = null):Asset
		{
			var a:Asset = new Asset();
			if(rc == null)
			{
				a.width = tx.defaultWidth;
				a.height = tx.defaultHeight;
			}
			else
			{
				a.width = rc.width;
				a.height = rc.height;
				a.offsetLeft = rc.left;
				a.offsetTop = rc.top;
			}
			a.texture = tx;
			a.library = this;
			return a;
		}

		public function activate(actor:Actor,active:Boolean):void
		{
			actor.task.job = this;
			world.addRenderData(actor.task);
		}				
		public function set renderID(value:uint):void
		{
			_renderID = value;
		}
		public function get renderID():uint
		{
			return _renderID;
		}
						
		public function render(renderData:Vector.<RenderTask>,start:uint):uint
		{
			var newResult:uint = world.gContext.blit2D(renderData,start,renderData.length);
			return newResult;
		}
	}
}
import M2D.core.IBlitOp;
import M2D.sprites.Actor;

class ActorList
{
	public var activeActorsDirty:Boolean = true;
	public var blitOps:Vector.<Actor> = new Vector.<Actor>();
}