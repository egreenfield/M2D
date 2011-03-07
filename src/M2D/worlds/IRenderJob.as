package M2D.worlds
{
	
	public interface IRenderJob
	{
		function set world(value:World):void;
		function get world():World;
		function render():void;
		function get numDrawTrianglesCallsPerFrame():int;
		function get timeInDrawTriangles():int;
	}
}