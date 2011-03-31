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
*/package M2D.particles
{
	import M2D.worlds.IRenderJob;
	import M2D.worlds.RenderTask;
	import M2D.worlds.WorldBase;
	
	public class ParticleLibrary implements IRenderJob
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
		public function set renderID(value:uint):void
		{
			_renderID = value;
		}
		public function get renderID():uint
		{
			return _renderID;
		}
		public function ParticleLibrary()
		{
		}
		public function createSymbol():ParticleSymbol
		{
			var a:ParticleSymbol = new ParticleSymbol();
			a.library = this;
			return a;
		}
		
		public function activate(instance:ParticleInstance,active:Boolean):void
		{
			instance.task.job = this;
			world.addRenderData(instance.task);			
		}				
		
		public function render(renderData:Vector.<RenderTask>,start:uint):uint
		{
			var pi:ParticleInstance = renderData[start].data as ParticleInstance;
			pi.render();
			return start+1;
		}		
	}
}
