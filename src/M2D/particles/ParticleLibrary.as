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
	import M2D.core.IBlitOp;
	import M2D.worlds.IRenderJob;
	import M2D.worlds.WorldBase;
	
	import flash.display3D.Context3D;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	public class ParticleLibrary implements IRenderJob
	{
		private var _world:WorldBase;
		public function set world(w:WorldBase):void
		{
			this._world = w;
		}
		public function get world():WorldBase
		{
			return _world;
		}
		public function ParticleLibrary()
		{
		}
		
		private var _numDrawTriangleCalls:int = 0;		
		private var _timeInDrawTriangles:int = 0;		
		private var blitOps:Vector.<IBlitOp> = new Vector.<IBlitOp>();
		
		private var InstanceMap:Dictionary = new Dictionary(true);
		
		private function getInstanceMap(symbol:ParticleSymbol):ParticleInstanceList
		{
			var list:ParticleInstanceList = InstanceMap[symbol];
			if(list == null)
				list = InstanceMap[symbol] = new ParticleInstanceList();
			return list;
		}
		public function createSymbol():ParticleSymbol
		{
			var a:ParticleSymbol = new ParticleSymbol();
			var list:ParticleInstanceList = getInstanceMap(a);
			a.library = this;
			return a;
		}
		
		public function activate(instance:ParticleInstance,active:Boolean):void
		{
			var list:ParticleInstanceList = getInstanceMap(instance.symbol);
			if(active)
			{
				list.blitOps.push(instance);
			}
			else
			{
			}
			list.activeInstancesDirty = true;
		}				
		
		public function get numDrawTrianglesCallsPerFrame():int { return _numDrawTriangleCalls;}
		public function get timeInDrawTriangles():int {return _timeInDrawTriangles;}
		
		
		
		public function render():void
		{
			for(var aSymbol:* in InstanceMap)
			{
				var list:ParticleInstanceList = InstanceMap[aSymbol];
				renderInstances(aSymbol,list);
			}
		}
		
		private function renderInstances(sym:ParticleSymbol,list:ParticleInstanceList):void
		{
			var context3D:Context3D = world.context3D;
			var blitOps:Vector.<ParticleInstance> = list.blitOps;
			
			var len:int = blitOps.length;
			if(list.activeInstancesDirty)
			{
				var moveDest:int = 0;
				for(var i:int = 0;i<len;i++)
				{
					var pi:ParticleInstance = blitOps[i] as ParticleInstance;
					if(pi.active == false)
						continue;
					
					pi.render();
					blitOps[moveDest] = pi;
					moveDest++;
				}
				if(moveDest < len)
				{
					blitOps.splice(moveDest,len-moveDest);
				}
				list.blitOps = blitOps.sort(compareDepth);
				list.activeInstancesDirty = false;
			}
			else
			{
				for(i = 0;i<len;i++)
				{
					pi = blitOps[i] as ParticleInstance;
					pi.render();
				}				
			}
		}
		
		private function compareDepth(lhs:ParticleInstance,rhs:ParticleInstance):int
		{
			if(lhs.depth < rhs.depth)
				return -1;
			else if (lhs.depth > rhs.depth)
				return 1;
			return 0;
		}
	}
}
import M2D.particles.ParticleInstance;

class ParticleInstanceList
{
	public var activeInstancesDirty:Boolean = true;
	public var blitOps:Vector.<ParticleInstance> = new Vector.<ParticleInstance>();
}