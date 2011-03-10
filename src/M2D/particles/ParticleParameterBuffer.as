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
	import flash.display3D.Context3D;
	import flash.display3D.VertexBuffer3D;

	public class ParticleParameterBuffer
	{
		public var firstIndexInParams:Number = 0;
		public var numParticles:Number;
		
		public function ParticleParameterBuffer(numParticles:int)
		{
			this.numParticles = numParticles;
			paramVector = new Vector.<Number>(numParticles * ParticleSymbol.NUM_PARAM_FLOATS_PER_PARTICLE);				
		}
		
		public var paramVector:Vector.<Number>;		
		public var paramBuffer:VertexBuffer3D;	
		private var _buffersDirty:Boolean = true;

		public function initBuffers(ctx:Context3D):void
		{
			if(_buffersDirty == false)
				return;
			if(paramBuffer != null)
			{
				paramBuffer.dispose();
				paramBuffer = null;
			}
			paramBuffer = ctx.createVertexBuffer( paramVector.length /ParticleSymbol.NUM_PARAMS_PER_PARTICLE, ParticleSymbol.NUM_PARAMS_PER_PARTICLE ); // 3 vertices, 5 floats per vertex
			paramBuffer.uploadFromVector(paramVector,0,paramVector.length/ParticleSymbol.NUM_PARAMS_PER_PARTICLE);
			
			_buffersDirty = false;
		}		
		public function commit():void
		{
			paramBuffer.uploadFromVector(paramVector,0,paramVector.length/ParticleSymbol.NUM_PARAMS_PER_PARTICLE);			
		}
	}
}