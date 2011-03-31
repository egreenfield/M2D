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
*/package M2D.core
{
	import M2D.sprites.Actor;
	import M2D.worlds.BatchTexture;
	import M2D.worlds.RenderTask;
	
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import spark.components.DataRenderer;

	public class GContext
	{
//----------------------------------------------------------------------------------------------------------------------------------------------------------
// public properies
//----------------------------------------------------------------------------------------------------------------------------------------------------------
		public var cameraMatrix:Matrix3D;
		
//----------------------------------------------------------------------------------------------------------------------------------------------------------
// private properies
//----------------------------------------------------------------------------------------------------------------------------------------------------------
		private var _context:Context3D;
		private var _indexBuffer:IndexBuffer3D;
		private var _vertexBuffers:Vector.<VBuffer> = new Vector.<VBuffer>(NUM_BUFFERS);
		private var nextBuffer:int = 0;
		private var _shaderProgram:Program3D;		
		private var _buffersDirty:Boolean = true;
		//		private var _numDrawTriangleCalls:int = 0;		
		//		private var _timeInDrawTriangles:int = 0;
		
//----------------------------------------------------------------------------------------------------------------------------------------------------------
// constants
//----------------------------------------------------------------------------------------------------------------------------------------------------------
		
		private static const NUM_SHARED_VERTEX_CONSTANTS:int = 5;
		private static const MAX_BATCH_SIZE:int = 1500;//Math.floor((128-NUM_SHARED_VERTEX_CONTSTANTS)/NUM_CONSTANTS_PER_SPRITE);
		private static const VERTEX_COUNT:Number = 4*MAX_BATCH_SIZE;
		private static const INDEX_COUNT:Number = 6*MAX_BATCH_SIZE;
		private static const VERTEX_LENGTH:Number = 3;
		private static const NUM_BUFFERS:int = 8;
		
		private static const CONSTANTS:Vector.<Number> = Vector.<Number> ( [0,0,0,0] ); 
		private static const FRAGMENT_CONSTANTS:Vector.<Number> = Vector.<Number> ( [0,0,0,-.001] );
//----------------------------------------------------------------------------------------------------------------------------------------------------------
// private statics
//----------------------------------------------------------------------------------------------------------------------------------------------------------
		private static var vertexVector:Vector.<Number> = null;
		private static var uvVector:Vector.<Number> = null;		
		private static var indexVector:Vector.<uint> = new Vector.<uint>();

		
		private static const DEFAULT_VERTEX_SHADER:String =
			"mov vt1, va0	\n" +
			"m44 op, vt1, vc1		\n" +	// 4x4 matrix transform from world space to output clipspace
			"mov v0, va1		\n" +	// copy xformed tex coords to fragment program
			"";
		private static const ALPHA_TEXTURE_SHADER:String =
			"mov ft0, v0\n" +
			"tex ft1, ft0.xy, fs0 <2d,clamp,linear>\n"+ // sample texture 0
			"mul ft1.a, ft1.a, v0.z\n" +
			"add ft2,ft1,fc0\n" +			
			"kil ft2.w\n" +
			"mov oc, ft1" +
			"\n";		
		
//----------------------------------------------------------------------------------------------------------------------------------------------------------
// Methods
//----------------------------------------------------------------------------------------------------------------------------------------------------------
		
		public function GContext()
		{
		}
		
//----------------------------------------------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------------------------------------------
		
		public function init(context:Context3D):void
		{
			_context = context;
			if(vertexVector == null)
			{
				vertexVector = new Vector.<Number>();
				uvVector = new Vector.<Number>();
				for(var i:int = 0;i<MAX_BATCH_SIZE;i++) {
					var vertexOffset:Number = i*4;
					vertexVector.push(
						0,0,0,
						1,0,0,
						0,1,0,
						1,1,0
					);
					uvVector.push(
						0,0,1,
						1,0,1,
						0,1,1,
						1,1,1
					);
					indexVector.push(
						vertexOffset, vertexOffset+1, vertexOffset+2,vertexOffset+1,vertexOffset+2,vertexOffset+3
					);
				}
			}
			
			if(_shaderProgram == null)
				initShaders(_context);
			if(_buffersDirty)
			{
				buildBuffers(_context)
			}		
		}

		
//----------------------------------------------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------------------------------------------

		private function initShaders(_context:Context3D):void
		{
			// programs			
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble( Context3DProgramType.VERTEX, DEFAULT_VERTEX_SHADER );
			
			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler(); 
			//			fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT, "mov oc, v0" /* copy color */ );
			fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
				ALPHA_TEXTURE_SHADER
			);
			
			
			_shaderProgram = _context.createProgram();
			_shaderProgram.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode );			
			
			
		}

//----------------------------------------------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------------------------------------------

		private function buildBuffers(_context:Context3D):void
		{
			if(_buffersDirty == false)
				return;
			
			
			if(_vertexBuffers.length > 0)
			{
				for(var i:int =0;i<_vertexBuffers.length;i++)
				{
					if(_vertexBuffers[i] != null)
					{
						_vertexBuffers[i].buffer.dispose();
						_vertexBuffers[i].uvBuffer.dispose();
					}
				}
				_vertexBuffers.length = 0;
			}
			if(_indexBuffer != null)
			{
				_indexBuffer.dispose();
				_indexBuffer = null;
			}
			
			for(i=0;i<NUM_BUFFERS;i++)
			{
				_vertexBuffers[i] = new VBuffer();
				_vertexBuffers[i].buffer = _context.createVertexBuffer( VERTEX_COUNT, VERTEX_LENGTH ); // 3 vertices, 5 floats per vertex
				_vertexBuffers[i].uvBuffer = _context.createVertexBuffer( VERTEX_COUNT, VERTEX_LENGTH ); // 3 vertices, 5 floats per vertex
			}
			
			
			_indexBuffer = _context.createIndexBuffer( indexVector.length );
			_indexBuffer.uploadFromVector( indexVector,0,indexVector.length );  			 			
			_buffersDirty = false;
		}
		
//----------------------------------------------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------------------------------------------
				
		public function blit2D(sources:Vector.<RenderTask>,start:uint,end:uint):uint
		{			
			var mask:Number = RenderTask.TRANSPARENT_MASK | RenderTask.RENDER_MASK | RenderTask.MATERIAL_MASK;
			var keyValue:Number = sources[start].highKey & mask;
			var first:Actor = sources[start].data as Actor;			
			var source:BatchTexture = first.asset.texture;
			
			source.prepare();
			// can cache to remember when these have been set recently to skip repeating it.
			_context.setProgram( _shaderProgram );
			_context.setVertexBufferAt( 2, null);			
			_context.setVertexBufferAt( 3, null);			
			_context.setVertexBufferAt( 4, null);			
			_context.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 0, CONSTANTS);
			_context.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 1, cameraMatrix, true );				
			_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,FRAGMENT_CONSTANTS);
			
			
			// likely must be set every time
			_context.setTextureAt( 0, source.texture);

			
			var next:uint = start;
			//nextBuffer = 0;
			var vertexOffset:Number = 0;
			var bufferCount:Number = 0;
			var vertexBuffer:VBuffer = _vertexBuffers[nextBuffer];
			
			// assume our vertex buffer has enough space for all our vertices;
			var ctx:Context3D = _context;
			
			while(next < end && (sources[next].highKey & mask) == keyValue)
			{
				var actor:Actor = sources[next].data as Actor;
				var xForm:Vector.<Number>= actor.getBlitXForm();
				
				var xf56:Number = xForm[5] + xForm[6];
				var xf12:Number = xForm[1] + xForm[2];
				vertexVector[vertexOffset] = xForm[2];
				vertexVector[vertexOffset+1] = xForm[6];
				vertexVector[vertexOffset+2] = xForm[3];
				
				vertexVector[vertexOffset+3] = xForm[0] + xForm[2];
				vertexVector[vertexOffset+4] = xForm[4] + xForm[6];
				vertexVector[vertexOffset+5] = xForm[3];
				
				vertexVector[vertexOffset+6] = xf12;
				vertexVector[vertexOffset+7] = xf56;
				vertexVector[vertexOffset+8] = xForm[3];
				
				vertexVector[vertexOffset+9] = xForm[0] + xf12;
				vertexVector[vertexOffset+10] = xForm[4] + xf56;
				vertexVector[vertexOffset+11] = xForm[3];
				
				if(vertexBuffer.uvDirty)
				{
					uvVector[vertexOffset] = xForm[10];
					uvVector[vertexOffset+1] = xForm[11];
					uvVector[vertexOffset+2] = xForm[7];
					
					uvVector[vertexOffset+3] = xForm[8] + xForm[10];
					uvVector[vertexOffset+4] = xForm[11];
					uvVector[vertexOffset+5] = xForm[7];
					
					uvVector[vertexOffset+6] = xForm[10];
					uvVector[vertexOffset+7] = xForm[9] + xForm[11];
					uvVector[vertexOffset+8] = xForm[7];
					
					uvVector[vertexOffset+9] = xForm[8] + xForm[10];
					uvVector[vertexOffset+10] = xForm[9] + xForm[11];
					uvVector[vertexOffset+11] = xForm[7];
				}
				
				vertexOffset += VERTEX_LENGTH*4;

				bufferCount++;
				if(bufferCount == MAX_BATCH_SIZE)
				{
					vertexBuffer.buffer.uploadFromVector(vertexVector,0,bufferCount*4);
					if(vertexBuffer.uvDirty)
					{
						vertexBuffer.uvBuffer.uploadFromVector(uvVector,0,bufferCount*4);
						//vertexBuffer.uvDirty = false;
					}
					_context.setVertexBufferAt( 0, vertexBuffer.buffer, 0, Context3DVertexBufferFormat.FLOAT_3 );
					_context.setVertexBufferAt( 1, vertexBuffer.uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_3 );
					_context.drawTriangles( _indexBuffer,0,2*bufferCount);
					
					nextBuffer = (nextBuffer + 1) % NUM_BUFFERS;
					bufferCount = 0;
					vertexOffset = 0;
					vertexBuffer = _vertexBuffers[nextBuffer];
				}
				
				next++;
			}

			if(bufferCount > 0)
			{
				vertexBuffer.buffer.uploadFromVector(vertexVector,0,bufferCount*4);
				if(vertexBuffer.uvDirty)
				{
					vertexBuffer.uvBuffer.uploadFromVector(uvVector,0,bufferCount*4);
					//vertexBuffer.uvDirty = false;
				}
				_context.setVertexBufferAt( 0, vertexBuffer.buffer, 0, Context3DVertexBufferFormat.FLOAT_3 );
				_context.setVertexBufferAt( 1, vertexBuffer.uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_3 );
				_context.drawTriangles( _indexBuffer,0,2*bufferCount);				
				nextBuffer = (nextBuffer + 1) % NUM_BUFFERS;
			}
			return next;
		}
			}
}
import flash.display3D.VertexBuffer3D;

class VBuffer
{
	public var buffer:VertexBuffer3D;
	public var uvBuffer:VertexBuffer3D;
	public var dirty:Boolean = true;
	public var uvDirty:Boolean = true;
}