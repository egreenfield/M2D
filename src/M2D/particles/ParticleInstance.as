package M2D.particles
{
	import M2D.time.Clock;
	import M2D.worlds.Instance;
	import M2D.worlds.World;
	
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	public class ParticleInstance extends Instance
	{
		
		public var symbol:ParticleSymbol;
		private var possibleNumLivingParticles:Number;
		public var startTime:Number;
		public var currentTime:Number;

		private var firstIndexInParams:Number = -1;
		private var parameterRefillLimit:Number;
		private var numParticlesInBuffers:Number 
		
		private var _buffersDirty:Boolean = true;
		private var _paramBuffer:VertexBuffer3D;	
		
		private var paramVector:Vector.<Number>;		
		private static var tmpMatrix:Matrix3D = new Matrix3D();
		private static var CONSTANTS:Vector.<Number> = Vector.<Number> ( [0,0,0,.5] ); 
		
		private static const VERTEX_LENGTH:Number = 4;
		private static const NUM_PARAMS_PER_PARTICLE:Number = 5;
		private static const NUM_VERTICES_PER_PARTICLE:Number = 4;
		private static const NUM_PARAM_FLOATS_PER_PARTICLE:Number =NUM_VERTICES_PER_PARTICLE*NUM_PARAMS_PER_PARTICLE; 
		private static const NUM_INDICES_PER_PARTICLE:int = 6;
		private static const NUM_TRIANGLES_PER_PARTICLE:int = 2;
		
		private var _clock:Clock;
		
		public function set clock(value:Clock):void
		{
			_clock = value;
		}
		public function get clock():Clock
		{
			return _clock;
		}
		
		
		
		override public function set active(value:Boolean):void
		{
			if(value == _active)
				return;
			
			_active = value;
			symbol.library.activate(this,value);
		}
		
		public function ParticleInstance(symbol:ParticleSymbol)
		{
			this.symbol = symbol;

			possibleNumLivingParticles = Math.ceil(symbol.lifespan/symbol.birthDelay);
			// why the random numbers? If reduces the chance two different particle instances will
			// need to fill buffers at the same time.
			numParticlesInBuffers = possibleNumLivingParticles*2;
			parameterRefillLimit = Math.floor(possibleNumLivingParticles*(1+Math.random()));			
		}
		
	
		
		
		public function start():void
		{
			startTime = _clock.currentTime;  
		}
		
		public function render():void
		{
			var world:World = symbol.library.world;
			var ctx:Context3D = symbol.library.world.context3D;

			currentTime = _clock.currentTime;
			var delta:Number = currentTime - startTime;		
			var numBirthedParticles:Number = Math.ceil(delta/symbol.birthDelay);
			var numDeadParticles:Number = Math.max(0,Math.ceil((delta - symbol.lifespan)/symbol.birthDelay));
			var numLivingParticles:Number = numBirthedParticles - numDeadParticles;
			if(symbol.maxParticles > 0 && symbol.maxParticles < numLivingParticles)
			{
				numLivingParticles = symbol.maxParticles;
			}
			var firstLivingParticleIndex:Number = numBirthedParticles - numLivingParticles;		
			var firstLivingBirthTime:Number = firstLivingParticleIndex * symbol.birthDelay;		
				
			
			if(numLivingParticles <= 0)
				return;
			
			if(paramVector == null)
				initData();
			symbol.initShaders();
			if(_buffersDirty)
				buildBuffers(ctx)	
			symbol.texture.prepare();
			
	
			ctx.setProgram(symbol.shaderProgram );
			
			ctx.setVertexBufferAt( 0, symbol._vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2 );
			ctx.setVertexBufferAt( 1, symbol._vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2 );

			ctx.setVertexBufferAt( 2, _paramBuffer, 0, Context3DVertexBufferFormat.FLOAT_1 );			
			ctx.setVertexBufferAt( 3, _paramBuffer, 3, Context3DVertexBufferFormat.FLOAT_2 );			
			ctx.setVertexBufferAt( 4, _paramBuffer, 1, Context3DVertexBufferFormat.FLOAT_2 );			
			
	
			var xForm:Matrix3D = getBlitXForm();			
			xForm.copyToMatrix3D(tmpMatrix);				
//			tmpMatrix.append(world.cameraMatrix);
			
			ctx.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 0, tmpMatrix, true );				
			ctx.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 4, world.cameraMatrix, true );				
			
			CONSTANTS[0] = symbol.gravityX/2; //- firstLivingBirthTime;
			CONSTANTS[1] = symbol.gravityY/2; //- firstLivingBirthTime;
			CONSTANTS[2] = delta; //- firstLivingBirthTime;
			CONSTANTS[3] = symbol.lifespan; //- firstLivingBirthTime;
			ctx.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 8, CONSTANTS);
	
			
			ctx.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,Vector.<Number>([1,-.01,-.01,-.01]));
			ctx.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, 1, CONSTANTS);
			
			
			ctx.setTextureAt( 0, symbol.texture.texture);
	
			
			
			getBufferRange(BufferRange.range,firstLivingParticleIndex,numLivingParticles);
			ctx.drawTriangles(symbol._indexBuffer,BufferRange.range.firstPosition*NUM_INDICES_PER_PARTICLE,BufferRange.range.length*NUM_TRIANGLES_PER_PARTICLE);
			/*
			what I need to render a particle...
	X		time. (vc4.x)
			rotation (va3.x)
			velocity (va3.y)
			position (vc[0].xyz)
			start time (va2.x)
			inputs (va3.x)
			
	X		constants
	X		texture.
	X		quad
			transform
			*/				
		}
		
		private function getBufferRange(range:BufferRange,firstIndex:Number,requestedLength:Number):void
		{
			var endOfBuffer:Number = firstIndexInParams + parameterRefillLimit;
			var needsUpload:Boolean = false;
			
			var positionOfFirstIndex:Number = firstIndex - firstIndexInParams;
			if(firstIndexInParams < 0)
			{
/*				trace("filling first");
				trace("requestedLength: ",requestedLength);
				trace("index count of buffer: ",numParticlesInBuffers);
*/				firstIndexInParams = 0;
				fillBuffer(0,numParticlesInBuffers);
				needsUpload = true;
			}
			else if (firstIndex >= endOfBuffer) 
			{
//				trace("filling compelete");
				firstIndexInParams = firstIndex;
				fillBuffer(0,parameterRefillLimit);
				needsUpload = true;
			}
			else if (firstIndex + requestedLength > endOfBuffer)
			{
				var numToCopy:Number = (parameterRefillLimit-positionOfFirstIndex)*NUM_PARAM_FLOATS_PER_PARTICLE;
				var positionOfFirstNewParticle:Number = parameterRefillLimit-positionOfFirstIndex;
	/*			trace("*** Too Many");
				trace("requestedLength: ",requestedLength);
				trace("first Index:",firstIndex);
				trace("end of buffer is:",endOfBuffer);
				trace("position of first index:",positionOfFirstIndex);
				trace("index count of buffer: ",numParticlesInBuffers);
				trace("copying ",numToCopy);
	*/			
				var offset:Number = positionOfFirstIndex*NUM_PARAM_FLOATS_PER_PARTICLE;
				/*			for(var i:Number = 0;i<numToCopy;i++) {
					paramVector[i] = paramVector[i+offset];
				}
				*/
				var move:Vector.<Number> = paramVector.splice(0,offset);
				paramVector = paramVector.concat(move);
				firstIndexInParams = firstIndex;
				//trace("filling ",numToCopy);
				
				fillBuffer(positionOfFirstNewParticle,parameterRefillLimit-positionOfFirstNewParticle);
				positionOfFirstIndex = 0;
				needsUpload = true;
			}
			range.firstPosition = positionOfFirstIndex;
			range.length = requestedLength;
			if(needsUpload)
				_paramBuffer.uploadFromVector(paramVector,0,numParticlesInBuffers*4);
			
		}
		
		private function fillBuffer(firstPosition:Number,length:Number):void
		{		
			for(var i:Number = 0;i<length;i++) {
				var particleIdx:Number = firstPosition + i + firstIndexInParams;
				var idx:Number = (firstPosition+i)*NUM_PARAM_FLOATS_PER_PARTICLE;
				var r:Number = Math.random()*.1*Math.PI;//(birthTime%1000)/1000*2*Math.PI * (Math.random() * .4 + .8);
				var v:Number = (Math.random() * 300 + 30)/1000;
				var birthTime:Number = symbol.birthDelay * (particleIdx);
				var x0:Number = 0;//Math.random()*30 -15;
				var y0:Number = 0;//Math.random()*30 -15;
				for(var j:Number = 0;j<NUM_VERTICES_PER_PARTICLE;j++) {
					paramVector[idx++] = birthTime;
					paramVector[idx++] = x0;
					paramVector[idx++] = y0;
					paramVector[idx++] = r; 
					paramVector[idx++] = v;
				}
			}
		}
		
		
	
		private function initData():void
		{
			var ctx:Context3D = symbol.library.world.context3D;
			
			symbol.initData();
			
			if(paramVector == null)
			{
				paramVector = new Vector.<Number>(numParticlesInBuffers * NUM_PARAM_FLOATS_PER_PARTICLE);				
			}
			
			
		}
	
	
		private function buildBuffers(_context:Context3D):void
		{
			var vertexCount:Number = possibleNumLivingParticles;
			
			symbol.initBuffers();
			
			if(_buffersDirty == false)
				return;
			
			
			if(_paramBuffer != null)
			{
				_paramBuffer.dispose();
				_paramBuffer = null;
			}
			_paramBuffer = _context.createVertexBuffer( paramVector.length /NUM_PARAMS_PER_PARTICLE, NUM_PARAMS_PER_PARTICLE ); // 3 vertices, 5 floats per vertex
			_paramBuffer.uploadFromVector(paramVector,0,paramVector.length/NUM_PARAMS_PER_PARTICLE);
	
			_buffersDirty = false;
		}		
	}
}

class BufferRange
{
	public static var range:BufferRange = new BufferRange();
	public var firstPosition:Number;
	public var length:Number;
	public var needsUpload:Boolean = false;
}
