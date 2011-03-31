package M2D.worlds
{
	public class RenderTask
	{
		public function RenderTask()
		{
		}
		public var key:Number;
		public var highKey:uint;
		public var lowKey:uint;
		
		public var job:IRenderJob;
		public var data:Object;
		
		// transparent: bit 30
		public static const TRANSPARENT_MASK:Number = (1 << (31));
		public static const RENDER_MASK:Number = (0x7 << (28));	// 3 bits
		public static const MATERIAL_MASK:Number = (0x3FF << (18));	// 10 bits
		
		public static const DEPTH_MASK:Number = (0xFFFF << (16));	// 16 bits

		public static function makeAlphaCode(alpha:Number):Number {return (alpha < 1)?  (1 << 31):0} 
		public static function makeRenderCode(code:Number):Number {return code << 28} 
		public static function makeMaterialCode(code:Number):Number {return code << 18} 
		public static function makeDepthCode(code:Number,isTransparent:Boolean = false):Number {return (isTransparent? code:(0xFFFF-code)) << 16} 

		public static const TRANSPARENT:Number = TRANSPARENT_MASK;
		public static const OPAQUE:Number = 0;
		public function setKey(high:uint,low:uint):void
		{
			highKey = high;
			lowKey = low;
			key = makeKey(high,low);
		}
		
		public static function makeKey(high:uint,low:uint):Number
		{
			var result:Number = high * 0xFFFFFFFF + low;
			return result;
		}
	}
}