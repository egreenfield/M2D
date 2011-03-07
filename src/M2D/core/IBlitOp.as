package M2D.core
{
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;

	public interface IBlitOp
	{
		function getBlitXForm():Matrix3D;
		function getBlitSourceRC():Rectangle;		
	}
}