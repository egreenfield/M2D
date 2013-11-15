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
*/

package M2D.worlds
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	public class BatchTexture
	{
		public var texture:Texture;		
		public var width:Number;
		public var height:Number;	
		public var defaultWidth:Number;
		public var defaultHeight:Number;
		public var data:BitmapData;
		public var assetMgr:AssetMgr;
		public var textureID:uint;
		public var generatedFrameCount:uint;
		public var generatedRowCount:uint;
		public var generatedColCount:uint;
		
		private static var worldDataMap:Dictionary = new Dictionary(true);
		
		public function BatchTexture()
		{
		}
		
		public function prepare():void
		{
			var context3D:Context3D = assetMgr.world.context3D;
			if(texture == null)
			{
				texture = context3D.createTexture(width,height,Context3DTextureFormat.BGRA,false);
				texture.uploadFromBitmapData(data);				
			}			
		}
		
		internal static function createFromDisplayObject(d:DisplayObject):BatchTexture
		{
			var tx:BatchTexture = constructTextureForBounds(d.width, d.height);
			
			if(d is Bitmap)
			{
				var b:Bitmap = d as Bitmap;
				tx.data = b.bitmapData;
				if(tx.width != d.width || tx.height != d.height) {
					var fullBmp:BitmapData = new BitmapData( tx.width , tx.height, b.bitmapData.transparent, 0xFF0000 );
					fullBmp.copyPixels(b.bitmapData,new Rectangle(0,0,b.width,b.height),new Point(0,0));
					tx.data = fullBmp;
				}
			}
			else
			{
				fullBmp = new BitmapData( tx.width, tx.height, true,0xFFFFFFFF );
				var bounds:Rectangle = d.getBounds(d);
				var m:Matrix = new Matrix(1,0,0,1,-bounds.left,-bounds.top);
				fullBmp.draw(d,m);
				tx.data = fullBmp;				
			}
			
			return tx;
		}
		
		internal static function createFromAnimatedDisplayObject(d:Sprite, padding:uint, scaleX:Number, scaleY:Number):BatchTexture
		{	
			var frameCount:int = countAnimationFrames(d);			
			var cellBounds:Rectangle = collectCellBounds(d, frameCount, padding, scaleX, scaleY);
			
			var matrix:Matrix = new Matrix();
			var colCount:Number = Math.ceil(Math.sqrt(frameCount));
			var rowCount:Number = colCount;
			var totalWidth:Number = (colCount * cellBounds.width);
			var totalHeight:Number = (rowCount * cellBounds.height);
			
			var tx:BatchTexture = constructTextureForBounds(totalWidth, totalHeight);
			tx.data = new BitmapData(tx.width, tx.height, true, 0x0);;
			tx.generatedColCount = tx.generatedRowCount = colCount;
			tx.generatedFrameCount = frameCount;
			
			for (var row:int = 0; row < rowCount; row++)
			{
				for (var col:int = 0; col < colCount; col++)
				{
					if (row * colCount + col < frameCount)
					{
						moveAnimationToFrame(d, row * colCount + col + 1 );
						var dest:Point = new Point(col * cellBounds.width , row * cellBounds.height);
						matrix.identity();
						matrix.scale(scaleX, scaleY);
						matrix.translate(dest.x + cellBounds.x * scaleX, dest.y + cellBounds.y * scaleY);						
						tx.data.draw(d, matrix, null, null, null, true);
					}
				}
			}
			
			return tx;
		}
		
		private static function collectCellBounds(clip:Sprite, frameCount:uint, padding:Number, scaleX:Number, scaleY:Number):Rectangle
		{
			var minLeft:Number = 0;
			var minTop:Number = 0;
			var maxDeltaWidth:Number = 0;
			var maxDeltaHeight:Number = 0;
			
			for (var cell:int = 0; cell < frameCount; cell++)
			{
				moveAnimationToFrame(clip, cell + 1);
				
				var bounds:Rectangle = clip.getBounds(clip);
				var dw:Number = bounds.width + bounds.x;
				var dh:Number = bounds.height + bounds.y;
				
				minLeft = bounds.x < minLeft ? bounds.x : minLeft;
				minTop = bounds.y < minTop ? bounds.y : minTop;
				maxDeltaWidth = dw > maxDeltaWidth ? dw : maxDeltaWidth;
				maxDeltaHeight = dh > maxDeltaHeight ? dh : maxDeltaHeight;
			}
			
			var regX:Number = -minLeft + padding;
			var regY:Number = -minTop + padding;
			
			var maxBounds:Rectangle = new Rectangle(); 
			maxBounds.x = regX;
			maxBounds.y = regY;
			maxBounds.width = Math.ceil((regX + maxDeltaWidth + 2 * padding)) * scaleX;
			maxBounds.height = Math.ceil((regY + maxDeltaHeight + 2 * padding)) * scaleY;
			
			return maxBounds;
		}
		
		private static function countAnimationFrames(clip:DisplayObjectContainer):int
		{
			var max:int = clip is MovieClip ? MovieClip(clip).totalFrames : 1;
			for (var i:int = 0; i < clip.numChildren; i++)
			{
				var child:DisplayObjectContainer = clip.getChildAt(i) as DisplayObjectContainer;
				if (child)
					max = Math.max(countAnimationFrames(child), max);
			}
			return max;
		}
		
		private static function moveAnimationToFrame(clip:DisplayObjectContainer, frame:int):void
		{
			if (clip is MovieClip)
			{
				var mc:MovieClip = clip as MovieClip;
				if (mc.totalFrames >= frame)
					mc.gotoAndStop(frame);
			}
			for (var i:int = 0; i < clip.numChildren; i++)
			{
				var child:DisplayObjectContainer = clip.getChildAt(i) as DisplayObjectContainer;
				if (child){
					if(child is MovieClip)
					{
						var childmc:MovieClip = child as MovieClip;
						if (childmc.totalFrames >= childmc.currentFrame){
							childmc.nextFrame();
							moveAnimationToFrame(child, childmc.currentFrame);
						}
					}else{
						moveAnimationToFrame(child, frame);
					}
				}
			}
		}
		
		private static function constructTextureForBounds(width:Number, height:Number):BatchTexture
		{
			var tx:BatchTexture = new BatchTexture();
			tx.defaultWidth = width;
			tx.defaultHeight = height;
			tx.width = Math.pow(2, Math.ceil(Math.LOG2E * Math.log(width)));
			tx.height = Math.pow(2, Math.ceil(Math.LOG2E * Math.log(height)));
			return tx;
		}
		
	}
}
