package M2D
{

	public class Asset
	{
		public function Asset()
		{
		}
		public var width:Number;
		public var height:Number;		
		public var texture:BatchTexture;
		public var library:SymbolLibrary;
		
		public var cellColumnCount:int = 1;
		public var cellRowCount:int = 1;
		
		
			
		public function createActor():Actor
		{
			var newActor:Actor = new Actor();
			newActor.asset = this;
			newActor.active = true;
			return newActor;
		}		
	}
}
