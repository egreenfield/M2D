package M2D
{
	import flash.display.DisplayObject;

	public class AssetMgr
	{
		public var world:World;
		public function AssetMgr(world:World)
		{
			this.world = world;
		}
		
		public function createTextureFromDisplayObject(d:DisplayObject):BatchTexture
		{
			var tx:BatchTexture = BatchTexture.createFromDisplayObject(d);
			tx.assetMgr = this;
			return tx;
		}
	}
}