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
	import M2D.sprites.Asset;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	public class AssetMgr
	{
		public var world:World;
		private var nextTextureID:uint = 0;
		
		public function AssetMgr(world:World)
		{
			this.world = world;
		}
		
		public function createTextureFromDisplayObject(d:DisplayObject):BatchTexture
		{
			var tx:BatchTexture = BatchTexture.createFromDisplayObject(d);
			tx.textureID = nextTextureID++;
			tx.assetMgr = this;
			return tx;
		}
		
		public function createAssetFromDisplayObject(d:DisplayObject, cellRowCount:uint = 1, cellColumnCount:uint = 1, srcRect:Rectangle = null):Asset
		{
			var tx:BatchTexture = createTextureFromDisplayObject(d);
			var asset:Asset = world.library.createAsset(tx);
			asset.cellColumnCount = cellColumnCount;
			asset.cellRowCount = cellRowCount;
			return asset;
		}
		
		public function createTextureFromAnimatedDisplayObject(d:Sprite, padding:uint=1, scaleX:Number=1, scaleY:Number=1):BatchTexture
		{
			var tx:BatchTexture = BatchTexture.createFromAnimatedDisplayObject(d, padding, scaleX, scaleY);
			tx.textureID = nextTextureID++;
			tx.assetMgr = this;
			return tx;
		}
		
		public function createAssetFromAnimatedDisplayObject(d:Sprite, padding:uint=1, scaleX:Number=1, scaleY:Number=1):Asset
		{
			var tx:BatchTexture = createTextureFromAnimatedDisplayObject(d, padding, scaleX, scaleY);
			var asset:Asset = world.library.createAsset(tx);
			asset.cellColumnCount = tx.generatedColCount;
			asset.cellRowCount = tx.generatedRowCount;
			asset.frameCount = tx.generatedFrameCount;
			return asset;
		}
	}
}