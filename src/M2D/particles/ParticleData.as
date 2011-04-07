package M2D.particles
{
	import flash.geom.Vector3D;

	public class ParticleData
	{
		public function ParticleData()
		{
		}
		public var direction:Number = 0; // radians;
		public var speed:Number = 0; // pixels / millisecond
		public var angularVelocity:Number = 0; // radians / millisecond
		public var location:Vector3D = new Vector3D();

		
	}
}