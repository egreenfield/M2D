package M2D.sprites
{
	import M2D.core.IBlitOp;
	import M2D.worlds.BatchTexture;
	import M2D.worlds.IRenderJob;
	import M2D.worlds.World;
	
	import flash.display3D.Context3D;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class SymbolLibrary implements IRenderJob
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
		public function SymbolLibrary()
		{
		}

		private var _numDrawTriangleCalls:int = 0;		
		private var _timeInDrawTriangles:int = 0;		
		private var blitOps:Vector.<IBlitOp> = new Vector.<IBlitOp>();
		
		private var actorMap:Dictionary = new Dictionary(true);
			
		private function getActorMap(tx:BatchTexture):ActorList
		{
			var list:ActorList = actorMap[tx];
			if(list == null)
				list = actorMap[tx] = new ActorList();
			return list;
		}
		public function createAsset(tx:BatchTexture,rc:Rectangle = null):Asset
		{
			var list:ActorList = getActorMap(tx);
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
			}
			a.texture = tx;
			a.library = this;
			return a;
		}

		public function activate(actor:Actor,active:Boolean):void
		{
			var list:ActorList = getActorMap(actor.asset.texture);
			if(active)
			{
				list.blitOps.push(actor);
			}
			else
			{
			}
			list.activeActorsDirty = true;
		}				
		
		public function get numDrawTrianglesCallsPerFrame():int { return _numDrawTriangleCalls;}
		public function get timeInDrawTriangles():int {return _timeInDrawTriangles;}
		
		
		
		public function render():void
		{
			for(var aTexture:* in actorMap)
			{
				var list:ActorList = actorMap[aTexture];
				renderActors(aTexture,list);
			}
		}
		
		private function renderActors(tx:BatchTexture,list:ActorList):void
		{
			var context3D:Context3D = world.context3D;
			var blitOps:Vector.<IBlitOp> = list.blitOps;
			
			tx.prepare();
			
			if(list.activeActorsDirty)
			{
				var moveDest:int = 0;
				var len:int = blitOps.length;
				for(var i:int = 0;i<len;i++)
				{
					var actor:Actor = blitOps[i] as Actor;
					if(actor.active == false)
						continue;
					blitOps[moveDest] = actor;
					moveDest++;
				}
				if(moveDest < len)
				{
					blitOps.splice(moveDest,len-moveDest);
				}
				list.blitOps = blitOps.sort(compareDepth);
				list.activeActorsDirty = false;
			}
			world.gContext.blit2D(tx.texture,list.blitOps);			
		}
		
		private function compareDepth(lhs:Actor,rhs:Actor):int
		{
			if(lhs.depth < rhs.depth)
				return -1;
			else if (lhs.depth > rhs.depth)
				return 1;
			return 0;
		}
	}
}
import M2D.core.IBlitOp;

class ActorList
{
	public var activeActorsDirty:Boolean = true;
	public var blitOps:Vector.<IBlitOp> = new Vector.<IBlitOp>();
}