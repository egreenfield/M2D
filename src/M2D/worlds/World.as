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
	import M2D.particles.ParticleLibrary;
	import M2D.sprites.SymbolLibrary;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.geom.Rectangle;

	public class World extends WorldBase
	{
		public function World()
		{
			assetMgr = new AssetMgr(this);
			renderMgr = new RenderMgr(this);
			addJob(library);
			addJob(particleLibrary);
		}
		
		override public function initContext(stage:Stage,container:DisplayObjectContainer,slot:int,bounds:Rectangle):void
		{
//			renderMgr.init(container);
			super.initContext(stage,container,slot,bounds);
		}
		// ======================================================================
		//	Constants
		// ----------------------------------------------------------------------
		
		public var assetMgr:AssetMgr;
		public var particleLibrary:ParticleLibrary = new ParticleLibrary();
		public var library:SymbolLibrary = new SymbolLibrary();
		public var renderMgr:RenderMgr;
	}
}
