package M2D
{
	import flash.display3D.Context3D;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	public class ParticleLibrary implements IRenderJob
	{
		private var _world:World;
		public function set world(w:World):void
		{
			this._world = w;
		}
		public function get world():World
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
		
		private function getInstanceMap(symbol:ParticleSymbol):InstanceList
		{
			var list:InstanceList = InstanceMap[symbol];
			if(list == null)
				list = InstanceMap[symbol] = new InstanceList();
			return list;
		}
		public function createSymbol():ParticleSymbol
		{
			var a:ParticleSymbol = new ParticleSymbol();
			var list:InstanceList = getInstanceMap(a);
			a.library = this;
			return a;
		}
		
		public function activate(instance:ParticleInstance,active:Boolean):void
		{
			var list:InstanceList = getInstanceMap(instance.symbol);
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
				var list:InstanceList = InstanceMap[aSymbol];
				renderInstances(aSymbol,list);
			}
		}
		
		private function renderInstances(sym:ParticleSymbol,list:InstanceList):void
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
				for(var i:int = 0;i<len;i++)
				{
					var pi:ParticleInstance = blitOps[i] as ParticleInstance;
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
import M2D.IBlitOp;
import M2D.ParticleInstance;

class InstanceList
{
	public var activeInstancesDirty:Boolean = true;
	public var blitOps:Vector.<ParticleInstance> = new Vector.<ParticleInstance>();
}