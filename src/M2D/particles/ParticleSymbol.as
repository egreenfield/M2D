package M2D.particles
{
	import M2D.worlds.BatchTexture;
	
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;

	public class ParticleSymbol
	{
		public function ParticleSymbol()
		{
		}
		public var width:Number;
		public var height:Number;		
		public var _texture:BatchTexture;
		public var library:ParticleLibrary;
		
		public var birthDelay:Number = 100;
		public var lifespan:Number = 1000;
		public var maxParticles:Number = 0;
		
		public var gravityX:Number = 0;
		public var gravityY:Number = 3/10000;

		internal var vertexVector:Vector.<Number>;
		internal var indexVector:Vector.<uint> = new Vector.<uint>();
		internal var _vertexBuffer:VertexBuffer3D;
		internal var _indexBuffer:IndexBuffer3D;
		internal var shaderProgram:Program3D;		
		private var _buffersDirty:Boolean = true;

		private static const VERTEX_LENGTH:Number = 4;
		
		private static const DEFAULT_VERTEX_SHADER:String =
			"mov vt0, va0 \n" +		// load vertex
			"add vt0.xy, vt0.xy,va4.xy\n" +	// add in x0,y0
			"cos vt1.x, va3.x\n" + 	// put cos/sin of angle into vt1
			"sin vt1.y, va3.x\n" +
			"mul vt1.x, vt1.x, va3.y\n" + // multiply by velocity
			"mul vt1.y, vt1.y, va3.y\n" + 
			"sub vt2.x, vc8.z, va2.x\n" +	// get the relative time offset, in milliseconds
			"mov v1, vt0\n" +				// send time to fragment shader.  This is a hack for now.
			"mov v1.x, vt2.x\n" +
			"mul vt1.x, vt1.x, vt2.x\n" +	// now multiple x velocity by time
			"mul vt1.y, vt1.y, vt2.x\n" +	// now multiple y velocity by time
			"add vt0.xy, vt0.xy,vt1.xy\n" +	// now add velocity to base position
			
			"mul vt3.y, vt2.x, vt2.x\n" +	// load t^2
			"mul vt3.y, vt3.y, vc8.y\n" + 	// multiply by acceleration
			
			"dp4 vt4.x, vt0, vc0		\n" +	// 4x4 matrix transform from stream 0 to output clipspace
			"dp4 vt4.y, vt0, vc1		\n" +	// 4x4 matrix transform from stream 0 to output clipspace
			"dp4 vt4.z, vt0, vc2		\n" +	// 4x4 matrix transform from stream 0 to output clipspace
			"dp4 vt4.w, vt0, vc3		\n" +	// 4x4 matrix transform from stream 0 to output clipspace

			"add vt4.y, vt4.y, vt3.y\n" + // now add in accel in global space.
			
			"dp4 op.x, vt4, vc4		\n" +	// 4x4 matrix transform from stream 0 to output clipspace
			"dp4 op.y, vt4, vc5		\n" +	// 4x4 matrix transform from stream 0 to output clipspace
			"dp4 op.z, vt4, vc6		\n" +	// 4x4 matrix transform from stream 0 to output clipspace
			"dp4 op.w, vt4, vc7		\n" +	// 4x4 matrix transform from stream 0 to output clipspace
			"mov v0, va1		\n" +	// copy fragment straight through
			"";
		
		private static const ALPHA_TEXTURE_SHADER:String =
			"mov ft0, v0\n" +
			"tex ft1, ft0, fs0 <2d,clamp,linear>\n"+ // sample texture 0
			"add ft2,ft1,fc0\n" +
			"kil ft2.w\n" +
			"div ft3.a v1.x fc1.w\n" + 
			"sub ft3.a fc0.x ft3.a\n" +
			"mul ft1.a ft1.a  ft3.a\n" +
			"mov oc, ft1\n" +
			"\n";
		
		public function set texture(value:BatchTexture):void
		{
			_texture = value;
			width = _texture.defaultWidth;
			height = _texture.defaultHeight;
		}
		
		public function get texture():BatchTexture
		{
			return _texture;
		}
		
		public function createInstance():ParticleInstance
		{
			var newInstance:ParticleInstance= new ParticleInstance(this);
			newInstance.active = true;
			return newInstance;
		}		
		
		internal function initData():void
		{
			var ctx:Context3D = library.world.context3D;
			
			var uvWidth:Number = width/texture.width;
			var uvHeight:Number = height/texture.height;
			
			var left:Number = -width/2;
			var top:Number = -height/2;
			var right:Number = width/2;
			var bottom:Number = height/2;
			
			
			if(vertexVector == null)
			{
				var possibleNumLivingParticles:Number = Math.ceil(lifespan/birthDelay);
				// why the random numbers? If reduces the chance two different particle instances will
				// need to fill buffers at the same time.
				var numParticlesInBuffers:Number = Math.floor(possibleNumLivingParticles*2);

				
				vertexVector = new Vector.<Number>();
				
				for(var i:Number = 0;i<numParticlesInBuffers;i++) {
					var vertexOffset:Number = i*4;
					var r:Number = Math.random()*2*Math.PI;
					var v:Number = (Math.random() * 200 + 30)/1000;
					
					vertexVector.push(
						left,top,		0,0,	
						right,top,		uvWidth,0,	
						left,bottom,		0,uvHeight,	
						right,bottom,		uvWidth,uvHeight	
					);
					indexVector.push(
						vertexOffset, vertexOffset+1, vertexOffset+2,vertexOffset+1,vertexOffset+2,vertexOffset+3
					);
				}
			}						
		}
		internal function initBuffers():void
		{
			var ctx:Context3D = library.world.context3D;

			if(_buffersDirty == false)
				return;

			if(_vertexBuffer != null)
			{
				_vertexBuffer.dispose();
				_vertexBuffer = null;
			}
			if(_indexBuffer != null)
			{
				_indexBuffer.dispose();
				_indexBuffer = null;
			}

			_vertexBuffer = ctx.createVertexBuffer( vertexVector.length /VERTEX_LENGTH, VERTEX_LENGTH ); // 3 vertices, 5 floats per vertex
			_vertexBuffer.uploadFromVector(vertexVector,0,vertexVector.length/VERTEX_LENGTH);
			_indexBuffer = ctx.createIndexBuffer( indexVector.length );
			_indexBuffer.uploadFromVector( indexVector,0,indexVector.length );  			 			
			
		}
		internal function initShaders():void
		{
			if(shaderProgram != null)
				return;
			
			
			// programs			
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble( Context3DProgramType.VERTEX, DEFAULT_VERTEX_SHADER );
			
			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler(); 
			fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
				ALPHA_TEXTURE_SHADER
			);
			
			
			shaderProgram = library.world.context3D.createProgram();
			shaderProgram.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode );			
			
			
		}
	}
}
