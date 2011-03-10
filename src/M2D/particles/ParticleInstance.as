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
	import M2D.time.Clock;
	import M2D.worlds.Instance;
	import M2D.worlds.WorldBase;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class ParticleInstance extends Instance
	{
		internal static const NUM_INDICES_PER_PARTICLE:int = 6;
		internal static const NUM_TRIANGLES_PER_PARTICLE:int = 2;
		
		public var symbol:ParticleSymbol;
		public var source:ParticleSource;
		public var startTime:Number;
		public var currentTime:Number;
		
		
		private static var tmpMatrix:Matrix3D = new Matrix3D();
		private static var CONSTANTS:Vector.<Number> = Vector.<Number> ( [0,0,0,.5] ); 
		
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
		}
		
	
		
		
		public function start():void
		{
			startTime = _clock.currentTime;  
		}
		
		public function render():void
		{
			var world:WorldBase = symbol.library.world;
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
			
			symbol.initForContext();
			source.initData();
			source.initBuffers();
			symbol.texture.prepare();
			
	
			ctx.setProgram(symbol.shaderProgram );
			
			ctx.setVertexBufferAt( 0, symbol._vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2 );
			ctx.setVertexBufferAt( 1, symbol._vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2 );

			
	
			if(symbol.generateInWorldSpace)
			{
				tmpMatrix.identity();
				tmpMatrix.appendTranslation(0,0,-depth/3000);			
			}
			else
			{
				getBlitXForm().copyToMatrix3D(tmpMatrix);
			}
			
//			tmpMatrix.append(world.cameraMatrix);
			
			ctx.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 0, tmpMatrix, true );				
			ctx.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 4, world.cameraMatrix, true );				
			
			CONSTANTS[0] = symbol.gravityX/2; //- firstLivingBirthTime;
			CONSTANTS[1] = symbol.gravityY/2; //- firstLivingBirthTime;
			CONSTANTS[2] = delta; //- firstLivingBirthTime;
			CONSTANTS[3] = symbol.lifespan; //- firstLivingBirthTime;
	
			
			
			
			ctx.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,Vector.<Number>([1,-.01,-.01,-.01]));
			ctx.setTextureAt( 0, symbol.texture.texture);
	
			
			
			var range:BufferRange = BufferRange.range;
			var firstIndexOfRequest:Number = firstLivingParticleIndex;
			while(numLivingParticles > 0)
			{				
				source.getBufferRange(range,firstLivingParticleIndex,firstIndexOfRequest,numLivingParticles);
				
				CONSTANTS[2] = delta - range.timeOffsetOfBuffer;
					
				ctx.setVertexBufferAt( 2, range.params.paramBuffer, 0, Context3DVertexBufferFormat.FLOAT_1 );			
				ctx.setVertexBufferAt( 3, range.params.paramBuffer, 3, Context3DVertexBufferFormat.FLOAT_2 );			
				ctx.setVertexBufferAt( 4, range.params.paramBuffer, 1, Context3DVertexBufferFormat.FLOAT_2 );			

				ctx.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 8, CONSTANTS);
				ctx.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, 1, CONSTANTS);
				
				ctx.drawTriangles(symbol._indexBuffer,range.firstPosition*NUM_INDICES_PER_PARTICLE,range.length*NUM_TRIANGLES_PER_PARTICLE);
				firstIndexOfRequest += range.length;
				numLivingParticles -= range.length;
			}
			
		}	
	}
}
import M2D.particles.ParticleParameterBuffer;

class BufferRange
{
	public static var range:BufferRange = new BufferRange();
	public var firstPosition:Number;
	public var length:Number;
	public var timeOffsetOfBuffer:Number;
	public var params:ParticleParameterBuffer;
}
