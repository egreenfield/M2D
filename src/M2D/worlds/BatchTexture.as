package M2D.worlds
{
	
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	public class BatchTexture
	{
		public function BatchTexture()
		{
		}

		
		public var texture:Texture;		
		public var width:Number;
		public var height:Number;	
		public var defaultWidth:Number;
		public var defaultHeight:Number;
		
		public var data:BitmapData;
		public var assetMgr:AssetMgr;


		
		private static var worldDataMap:Dictionary = new Dictionary(true);
		
		
		
		internal static function createFromDisplayObject(d:DisplayObject):BatchTexture
		{
			var tx:BatchTexture = new BatchTexture();
			
			tx.defaultWidth = d.width;
			tx.defaultHeight = d.height;
			
			tx.width = Math.pow(2,Math.ceil(Math.LOG2E * Math.log(d.width)));;
			tx.height = Math.pow(2,Math.ceil(Math.LOG2E * Math.log(d.height)));
			
			if(d is Bitmap)
			{
				var b:Bitmap = d as Bitmap;
				tx.data = b.bitmapData;
				if(tx.width != d.width || tx.height != d.height) {
					var fullBmp:BitmapData = new BitmapData( tx.width , tx.height, b.bitmapData.transparent, 0xFF0000 );
					fullBmp.copyPixels(b.bitmapData,new Rectangle(0,0,b.width,b.height),new Point(0,0));
					tx.data = fullBmp;
				}
			}
			else
			{
				fullBmp = new BitmapData( tx.width, tx.height, true,0xFFFFFFFF );
				var bounds:Rectangle = d.getBounds(d);
				var m:Matrix = new Matrix(1,0,0,1,-bounds.left,-bounds.top);
				fullBmp.draw(d,m);
				tx.data = fullBmp;				
			}
			
			return tx;
		}
		
		
		

		public function prepare():void
		{
			var context3D:Context3D = assetMgr.world.context3D;
			if(texture == null)
			{
				texture = context3D.createTexture(width,height,Context3DTextureFormat.BGRA,false);
				texture.uploadFromBitmapData(data);				
			}			
		}
		
	}
}
