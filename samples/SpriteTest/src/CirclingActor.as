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
*/package
{
	import M2D.sprites.Actor;
	
	import flash.utils.getTimer;
	
	public class CirclingActor
	{
		public var actor:Actor;
		public function CirclingActor(a:M2D.sprites.Actor)
		{
			actor = a;
			super();
		}
		public var centerX:Number;
		public var centerY:Number;
		public var radius:Number;
		public var speed:Number = 1;
		public function update():void
		{
			actor.x = centerX + Math.cos(getTimer()/1000* speed * Math.PI*2)*radius;
			actor.y = centerY + + Math.sin(getTimer()/1000* speed * Math.PI*2)*radius
			actor.rotation = Math.sin(getTimer()/1000* speed * Math.PI*2)*20;
		}
	}
}