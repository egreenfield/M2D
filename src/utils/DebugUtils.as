package utils
{
	public class DebugUtils
	{
		public function DebugUtils()
		{
		}
		private static var c:Array = [ '0', '1', '2', '3', '4', '5', '6', '7', '8',
			'9', 'A', 'B', 'C', 'D', 'E', 'F' ];

		public static function d2h( d:Number ) : String 
		{
			var result:String = "";
			while(d > 0)
			{
				var v:int = d % 16;
				result = c[v] + result;
				d -= v;
				d = d >> 4;
			}
			return "0x" + result;
		}
		public static function d2b( d:Number ) : String 
		{
			var result:String = "";
			while(d > 0)
			{
				var v:int = d % 2;
				result = c[v] + result;
				d -= v;
				d = d >> 1;
			}
			return "." + result;
		}
	}
}