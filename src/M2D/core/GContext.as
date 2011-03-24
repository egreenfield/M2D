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
		private var _vertexBuffer:VertexBuffer3D;
		private var _shaderProgram:Program3D;		
		private var _buffersDirty:Boolean = true;
		//		private var _numDrawTriangleCalls:int = 0;		
		//		private var _timeInDrawTriangles:int = 0;
		
//----------------------------------------------------------------------------------------------------------------------------------------------------------
// constants
//----------------------------------------------------------------------------------------------------------------------------------------------------------
		
		private static const NUM_SHARED_VERTEX_CONTSTANTS:int = 5;
		private static const NUM_CONSTANTS_PER_SPRITE:Number = 3;
		private static const MAX_BATCH_SIZE:int = Math.floor((128-NUM_SHARED_VERTEX_CONTSTANTS)/NUM_CONSTANTS_PER_SPRITE);
		private static const VERTEX_COUNT:Number = 4*MAX_BATCH_SIZE;
		private static const INDEX_COUNT:Number = 6*MAX_BATCH_SIZE;
		private static const VERTEX_LENGTH:Number = 8;
		private static const NUM_CONSTANTS_USED_FOR_MATRIX:Number = 2;
		
		private static const CONSTANTS:Vector.<Number> = Vector.<Number> ( [0,0,0,0] ); 

//----------------------------------------------------------------------------------------------------------------------------------------------------------
// private statics
//----------------------------------------------------------------------------------------------------------------------------------------------------------

		private static var vertexVector:Vector.<Number> = null;
		private static var indexVector:Vector.<uint> = new Vector.<uint>();

		private static var tmpMatrix:Matrix3D = new Matrix3D();
		private static var tmpVector:Vector.<Number> = Vector.<Number>([0,0,0,0]);
		private static var tmpRC:Rectangle = new Rectangle();

		
		
		private static const DEFAULT_VERTEX_SHADER:String =
			"mov vt1, va0	\n" +
			"mov vt2, vc[va2.x] \n" +		// copy the model->world transform from constants 
			"mov vt3, vc[va2.y] \n" +
			"mov vt4, vc0 \n" +
			"mov vt4.z, vc[va2.x].w \n" +
			"m33 vt1.xyz, vt1, vt2		\n" +	// 4x4 matrix transform from world space to output clipspace
			"m44 op, vt1, vc1		\n" +	// 4x4 matrix transform from world space to output clipspace
			"mul vt2, va1, vc[va2.z]		\n" +	// scale tex coords by texture transform
			"add vt2.xy, vt2.xy, vc[va2.z].zw		\n" +	// offset tex coords by texture transform
			"mov v0, vt2		\n" +	// copy xformed tex coords to fragment program
			"mov v1.a, vc[va2.y].w \n" +	// also copy over alpha
			"";
		private static const ALPHA_TEXTURE_SHADER:String =
			"mov ft0, v0\n" +
			"tex ft1, ft0, fs0 <2d,clamp,linear>\n"+ // sample texture 0
			"mul ft1.a, ft1.a, v1.a\n" +
			"add ft2,ft1,fc0\n" +			
			"kil ft2.w\n" +
			"mov oc, ft1\n" +
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
				for(var i:int = 0;i<MAX_BATCH_SIZE;i++) {
					var vertexOffset:Number = i*4;
					var constantOffset:Number = i*NUM_CONSTANTS_PER_SPRITE;
					var tOffset:Number = constantOffset+NUM_SHARED_VERTEX_CONTSTANTS;
					var uvOffset:Number = constantOffset+NUM_SHARED_VERTEX_CONTSTANTS+NUM_CONSTANTS_USED_FOR_MATRIX;
					vertexVector.push(
						0,0,1,0,0,	tOffset,tOffset+1,uvOffset,
						1,0,1,1,0,	tOffset,tOffset+1,uvOffset,
						0,1,1,0,1,	tOffset,tOffset+1,uvOffset,
						1,1,1,1,1,	tOffset,tOffset+1,uvOffset
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
			
			_vertexBuffer = _context.createVertexBuffer( VERTEX_COUNT, VERTEX_LENGTH ); // 3 vertices, 5 floats per vertex
			_vertexBuffer.uploadFromVector(vertexVector,0,VERTEX_COUNT);
			
			
			_indexBuffer = _context.createIndexBuffer( indexVector.length );
			_indexBuffer.uploadFromVector( indexVector,0,indexVector.length );  			 			
			_buffersDirty = false;
		}
		
//----------------------------------------------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------------------------------------------
				
		public function blit2D(source:Texture,sources:Vector.<Actor>):void
		{			
			var count:int = sources.length;
			var base:int = 0;

			
			// can cache to remember when these have been set recently to skip repeating it.
			_context.setProgram( _shaderProgram );
			_context.setVertexBufferAt( 0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3 );
			_context.setVertexBufferAt( 1, _vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2 );
			_context.setVertexBufferAt( 2, _vertexBuffer, 5, Context3DVertexBufferFormat.FLOAT_3 );			
			_context.setVertexBufferAt( 3, null);			
			_context.setVertexBufferAt( 4, null);			
			_context.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 0, CONSTANTS);
			_context.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 1, cameraMatrix, true );				
			_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,Vector.<Number>([-.01,-.01,-.01,-.01]));
			
			
			// likely must be set every time
			_context.setTextureAt( 0, source);
			
//			_numDrawTriangleCalls = 0;
//			_timeInDrawTriangles = 0;
			while(base < count)
			{
				var batchSize:int = Math.min(count - base,MAX_BATCH_SIZE);
				blit2DBatch(sources,base,batchSize);
				base += batchSize;
			}			
		}
		
//----------------------------------------------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------------------------------------------
		
		private function blit2DBatch(sources:Vector.<Actor>,base:int,count:int):Number
		{
			
			// assume our vertex buffer has enough space for all our vertices;
			var constantBase:int = 1;
			var activeActorCount:int = 0;
			var end:Number = base+count;
			var ctx:Context3D = _context;
			var constantOffset:Number = NUM_SHARED_VERTEX_CONTSTANTS;
			for(var i:int = base;i<end;i++)
			{
				var xForm:Vector.<Number>= sources[i].getBlitXForm();
				ctx.setProgramConstantsFromVector( Context3DProgramType.VERTEX, constantOffset, xForm,NUM_CONSTANTS_PER_SPRITE);								
				constantOffset += NUM_CONSTANTS_PER_SPRITE;
			}
			
//			var t:Number = getTimer();
			_context.drawTriangles( _indexBuffer,0,2*count);
			return 0;//getTimer() - t;
		}		
	}
}