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
	
	public class StaticParticleSource implements ParticleSource
	{
		public var symbol:ParticleSymbol;
		public var params:Vector.<ParticleParameterBuffer>;
		public var period:Number = 3;
		private var buffersDirty:Boolean = true;
		
		public function get maxParticlesPerDrawCall():Number
		{
			return Math.min(ParticleSymbol.MAX_BUFFER_SIZE,numParticlesBeforeRepeat);
		}
		
		public function get numParticlesBeforeRepeat():Number
		{
			return symbol.possibleNumLivingParticles*period;	
		}
		public function StaticParticleSource(symbol:ParticleSymbol)
		{
			this.symbol = symbol;
		}
		
		public function updateNumbers():void
		{
			
		}
		public function get numParamBuffers():Number
		{
			return Math.ceil(numParticlesBeforeRepeat/maxParticlesPerDrawCall);			
		}
		
		
		public function getBufferRange(range:*,baseIndex:Number, firstIndex:Number,requestedLength:Number):void
		{
			
			var parameterRefillLimit:Number = numParticlesBeforeRepeat;
			var positionOfFirstIndex:Number = firstIndex % parameterRefillLimit;
			var timeLengthOfRepeat:Number = (parameterRefillLimit)*symbol.birthDelay;
			var timeLengthOfBuffer:Number = (maxParticlesPerDrawCall)*symbol.birthDelay;
			var timeOffset:Number = Math.floor((firstIndex*symbol.birthDelay)/timeLengthOfRepeat) * timeLengthOfRepeat;
			
			var paramBufferIndex:int = 0;
			var bufferStart:Number = 0;
			while((paramBufferIndex+1)*maxParticlesPerDrawCall <= positionOfFirstIndex)
			{
				paramBufferIndex++;
				timeOffset += timeLengthOfBuffer;
				bufferStart += maxParticlesPerDrawCall;
			}
			range.params = params[paramBufferIndex];
			range.firstPosition = positionOfFirstIndex - bufferStart;	
			range.length = Math.min(requestedLength,range.params.numParticles - range.firstPosition);
			range.timeOffsetOfBuffer = timeOffset;
		}
		public function initData():void
		{
			if(params != null)
				return;
			
			params = new Vector.<ParticleParameterBuffer>();
			for(var i:int = 0;i<numParamBuffers;i++)
			{
				var p:ParticleParameterBuffer = new ParticleParameterBuffer(maxParticlesPerDrawCall);
				p.firstIndexInParams = 0;
				symbol.fillBuffer(p,0,0,maxParticlesPerDrawCall,null);
				params.push(p);	
			}					
		}
		public function initBuffers():void
		{
			if(buffersDirty == false)
				return;
			
			var ctx:Context3D = symbol.library.world.context3D;
			for(var i:int = 0;i<numParamBuffers;i++)
			{
				params[i].initBuffers(ctx);
			}
			
			buffersDirty = false;
		}
	}
}