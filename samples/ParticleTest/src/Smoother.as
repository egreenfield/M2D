package
{
	public class Smoother
	{
		public var values:Vector.<Number>;
		public var length:int;
		public var average:Number = 0;
		public var sum:Number = 0;
		public var precision:Number = 2;
		
		public function Smoother(len:int)
		{
			values = new Vector.<Number>();
			length = len;
		}
		public function sample(value:Number):void
		{
			if(isNaN(value) || value == Infinity)
				return;
			
			sum += value;
			values.push(value);
			if(values.length > length)
				sum -= values.shift();
			var precisionFactor:Number = Math.pow(10,precision);
			average = Math.floor(precisionFactor * sum/values.length)/precisionFactor;			
		}
	}
}