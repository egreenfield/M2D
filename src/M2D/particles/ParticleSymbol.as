/*
* M2D 
* .....................
* 
* Author: Ely Greenfield
* Copyright (c) Adobe Systems 2011
* https://github.com/egreenfield/M2D
* 
* 
* Licence Agreement
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/package M2D.particles
{
	import M2D.worlds.BatchTexture;
	
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import zones.Zone2D;

	public class ParticleSymbol
	{
		public function ParticleSymbol()
		{
		}
		
		internal static const NUM_PARAMS_PER_PARTICLE:Number = 5;
		internal static const NUM_VERTICES_PER_PARTICLE:Number = 4;
		internal static const NUM_PARAM_FLOATS_PER_PARTICLE:Number =NUM_VERTICES_PER_PARTICLE*NUM_PARAMS_PER_PARTICLE; 
		
		
		private var staticSource:ParticleSource;
		public var width:Number;
		public var height:Number;		
		public var _texture:BatchTexture;
		public var library:ParticleLibrary;
		
		public var birthDelay:Number = 100;
		public var lifespan:Number = 1000;
		public var maxParticles:Number = 0;
		
		public static const MAX_BUFFER_SIZE:Number = 1500;
		public var gravityX:Number = 0;
		public var gravityY:Number = 3/10000;

		public var generateInWorldSpace:Boolean = true;
		
		internal var vertexVector:Vector.<Number>;
		internal var indexVector:Vector.<uint> = new Vector.<uint>();
		internal var _vertexBuffer:VertexBuffer3D;
		internal var _indexBuffer:IndexBuffer3D;
		internal var shaderProgram:Program3D;		
		private var _buffersDirty:Boolean = true;
		private var configuration:ParticleConfiguration = new ParticleConfiguration();
		public var birthZone:Zone2D;
		
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
			"mul vt3.x, vt3.y, vc8.x\n" + 	// multiply by acceleration
			"mul vt3.y, vt3.y, vc8.y\n" + 	// multiply by acceleration
			
			"m44 vt4, vt0, vc0		\n" +	// 4x4 matrix transform from stream 0 to output clipspace

			"add vt4.y, vt4.y, vt3.y\n" + // now add in accel in global space.
			"add vt4.x, vt4.x, vt3.x\n" + // now add in accel in global space.
			
			"m44 op, vt4, vc4		\n" +	// 4x4 matrix transform from stream 0 to output clipspace
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
			updateBufferNumbers();			
			
			if(generateInWorldSpace == false && staticSource == null)
				staticSource = new StaticParticleSource(this);
			

			var newInstance:ParticleInstance= new ParticleInstance(this);
			
			newInstance.source= generateInWorldSpace? (new DynamicParticleSource(this,newInstance)):staticSource;;
			newInstance.active = true;
			return newInstance;
		}		
		
		public var possibleNumLivingParticles:Number;
		
		private function updateBufferNumbers():void
		{
			possibleNumLivingParticles = Math.ceil(lifespan/birthDelay);
		}
		
		internal function initForContext():void 
		{
			initData();
			initShaders();
			initBuffers();
		}
		
		internal function initData():void
		{
			if(vertexVector != null)
				return;

			if(staticSource != null)
				staticSource.initData();
			
			var ctx:Context3D = library.world.context3D;
			
			var uvWidth:Number = width/texture.width;
			var uvHeight:Number = height/texture.height;
			
			var left:Number = -width/2;
			var top:Number = -height/2;
			var right:Number = width/2;
			var bottom:Number = height/2;
			
			

			
			vertexVector = new Vector.<Number>();
			
			var maxParticlesPerDrawCall:Number = generateInWorldSpace?  
					DynamicParticleSource.getMaxParticlesPerDrawCall(possibleNumLivingParticles) 	:
					staticSource.maxParticlesPerDrawCall											;
			
			for(var i:int = 0;i<maxParticlesPerDrawCall;i++) {
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

			if(staticSource != null)
				staticSource.initBuffers();
			
			_vertexBuffer = ctx.createVertexBuffer( vertexVector.length /VERTEX_LENGTH, VERTEX_LENGTH ); // 3 vertices, 5 floats per vertex
			_vertexBuffer.uploadFromVector(vertexVector,0,vertexVector.length/VERTEX_LENGTH);
			_indexBuffer = ctx.createIndexBuffer( indexVector.length );
			_indexBuffer.uploadFromVector( indexVector,0,indexVector.length );  			 			

			_buffersDirty = false;
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
		
		
		private static var location:Vector3D = new Vector3D();

		internal function fillBuffer(buffer:ParticleParameterBuffer, firstPosition:Number,firstIndex:Number,length:Number,m:Matrix3D):void
		{		
			
			//configuration
			location.x = 0;
			location.y = 0;	
			var l:Vector3D = location;
			for(var i:Number = 0;i<length;i++) {
				var particleIdx:Number = firstIndex + i + buffer.firstIndexInParams;
				var idx:Number = (firstPosition+i)*NUM_PARAM_FLOATS_PER_PARTICLE;
				var r:Number = (Math.random()*.5+.5-.25)*-Math.PI;//(birthTime%1000)/1000*2*Math.PI * (Math.random() * .4 + .8);
				var v:Number = (Math.random() * 100 + 30)/1000;
				var birthTime:Number = birthDelay * (particleIdx);
				if(birthZone != null)
				{
					birthZone.getLocation(location);
				}
				if(m != null)
				{
					l = m.transformVector(location);
				}
					
				for(var j:Number = 0;j<NUM_VERTICES_PER_PARTICLE;j++) {
					buffer.paramVector[idx++] = birthTime;
					buffer.paramVector[idx++] = l.x;
					buffer.paramVector[idx++] = l.y;
					buffer.paramVector[idx++] = r; 
					buffer.paramVector[idx++] = v;
				}
			}
		}
		

		internal function updateTime(buffer:ParticleParameterBuffer, firstPosition:Number,length:Number):void
		{		
			for(var i:Number = 0;i<length;i++) {
				var particleIdx:Number = firstPosition + i + buffer.firstIndexInParams;
				var idx:Number = (firstPosition+i)*NUM_PARAM_FLOATS_PER_PARTICLE;
				var birthTime:Number = birthDelay * (particleIdx);
				
				for(var j:Number = 0;j<NUM_VERTICES_PER_PARTICLE;j++) {
					buffer.paramVector[idx] = birthTime;
					idx += NUM_PARAMS_PER_PARTICLE;
				}
			}
		}		
	}
}
