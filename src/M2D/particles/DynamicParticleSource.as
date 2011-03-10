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
	import flash.geom.Matrix3D;
	
	import mx.utils.NameUtil;
	
	public class DynamicParticleSource implements ParticleSource
	{
		public var symbol:ParticleSymbol;
		public var instance:ParticleInstance;
		
		public var params:Vector.<ParticleParameterBuffer>;
		public static var period:Number = 3;
		public var totalBufferSize:Number;
		public var numParamBuffers:int;
		
		private var indexOfHead:Number = 0;
		private var indexOfTail:Number = 0;
		private var positionOfTail:Number = 0;
		private var buffersDirty:Boolean = true;
		
		public function get maxParticlesPerDrawCall():Number
		{
			return Math.min(ParticleSymbol.MAX_BUFFER_SIZE,symbol.possibleNumLivingParticles*period);
		}
		
		private function get singleBufferSize():Number
		{
			return Math.min(ParticleSymbol.MAX_BUFFER_SIZE,symbol.possibleNumLivingParticles*period);
		}
		
		public function DynamicParticleSource(symbol:ParticleSymbol,instance:ParticleInstance)
		{
			this.symbol = symbol;
			this.instance = instance;
		}
		
		public function updateNumbers():void
		{
			numParamBuffers = Math.ceil((symbol.possibleNumLivingParticles*period)/singleBufferSize);
			totalBufferSize = numParamBuffers * singleBufferSize;
		}
		
		private function indexToPosition(value:Number):Number
		{
			return (value % totalBufferSize);
		}
		
		private function indexToBufferPosition(value:Number):Number
		{
			return value % singleBufferSize;	
		}
		
		private function indexToBuffer(value:Number):Number
		{
			return Math.floor(value / singleBufferSize) % numParamBuffers;
		}
		
		public function getBufferRange(range:*,baseIndex:Number,firstIndex:Number,requestedLength:Number):void
		{
			if(firstIndex < indexOfTail)
				throw new Error("Index out of range");
			if((firstIndex + requestedLength) > (baseIndex + totalBufferSize))
				throw new Error("request too big");
			if(firstIndex > indexOfHead)
			{
				fillRange(firstIndex,requestedLength); 
			}
			else if (firstIndex + requestedLength > indexOfHead)
			{
				fillRange(indexOfHead,requestedLength - (indexOfHead - firstIndex));
			}
			indexOfTail = baseIndex;
			positionOfTail = indexToPosition(indexOfTail);
			
			// at this point, we can guarantee that [head,tail] is fully filled and contains the range we care about.
			// now we find the requested index and cap to the buffer it exists in.
			
			var bufferIndex:Number = indexToBuffer(firstIndex);
			var positionInBuffer:Number = indexToBufferPosition(firstIndex);
			var fillLength:Number = Math.min(requestedLength,singleBufferSize - positionInBuffer);
			range.firstPosition = positionInBuffer;
			range.length = fillLength;
			range.timeOffsetOfBuffer = 0;
			range.params = params[bufferIndex];			
		}
		
		public static function getMaxParticlesPerDrawCall(possibleNumLivingParticles:Number):Number
		{
			return Math.min(ParticleSymbol.MAX_BUFFER_SIZE,possibleNumLivingParticles*period);
		}
		
		private function fillRange(firstIndex:Number,requestedLength:Number):void
		{
			var tailBuffer:Number = indexToBuffer(indexOfTail);
			var positionOfTailInBuffer:Number = indexToBufferPosition(indexOfTail);
			var m:Matrix3D = (symbol.generateInWorldSpace)? instance.getBlitXForm():null;
			
			while(requestedLength > 0)
			{
				var bufferIndex:Number = indexToBuffer(firstIndex);
				var buffer:ParticleParameterBuffer = params[bufferIndex];
				var positionInBuffer:Number = indexToBufferPosition(firstIndex);
				// we fill the entire rest of the buffer, even if it means going past the requested length
				var fillLength:Number = Math.min(singleBufferSize - positionInBuffer,requestedLength);
				// make sure we on't overwrite the tail.  This should only happen because we are overfilling the request.
				if(tailBuffer == bufferIndex && positionOfTailInBuffer > positionInBuffer)
					fillLength = Math.min(fillLength,positionOfTailInBuffer - positionInBuffer);
				symbol.fillBuffer(buffer,positionInBuffer,firstIndex,fillLength,m);
				indexOfHead = firstIndex + fillLength;
				requestedLength -= fillLength;
				firstIndex += fillLength;
				buffer.commit();
			}
		}
		
		public function initData():void
		{
			if(params != null)
				return;

			updateNumbers();
			
			params = new Vector.<ParticleParameterBuffer>();
			for(var i:int = 0;i<numParamBuffers;i++)
			{
				var p:ParticleParameterBuffer = new ParticleParameterBuffer(maxParticlesPerDrawCall);
				p.firstIndexInParams = 0;
				params.push(p);	
			}					
		}
		public function initBuffers():void
		{
			if(buffersDirty == false)
				return;
			
			updateNumbers();
			
			var ctx:Context3D = symbol.library.world.context3D;
			for(var i:int = 0;i<numParamBuffers;i++)
			{
				params[i].initBuffers(ctx);
			}
			buffersDirty = false;
		}
	}
}