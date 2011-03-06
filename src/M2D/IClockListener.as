package M2D
{
	public interface IClockListener
	{
		function tick():void;
		function set clock(value:Clock):void;
		function get clock():Clock;
	}
}