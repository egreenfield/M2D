package {
	import M2D.animation.CellAnimation;
	import M2D.sprites.Actor;

	public class CoinClip {
		public function CoinClip(_actor:Actor) {
			actorRef=_actor
			super();
		}

		public function set x(_x:Number):void {
			actorRef.x=_x
		}

		public function set y(_y:Number):void {
			actorRef.y=_y
		}

		public function get x():Number {
			return actorRef.x
		}

		public function get y():Number {
			return actorRef.y
		}

		public function setAlpha(_alpha:Number):void {
			actorRef.alpha=_alpha
		}

		public function rotate(_rotate:Number):void {
			actorRef.rotation+=_rotate
			newAngle=actorRef.rotation
		}

		public function move(_x:Number, _y:Number):void {
			actorRef.x+=_x
			actorRef.y+=_y
		}
		private var radians:Number
		private var newAngle:Number
		private var angleDiff:Number

		public function manage():void {
			// apply velocity
			if (Math.abs(velocityx) > 0.1) {
				velocityx*=.9
				actorRef.x+=velocityx
				if (Math.abs(velocityx) < .1) {
					velocityx=0
				}
			}
			if (Math.abs(velocityy) > 0.1) {
				velocityy*=.9
				actorRef.y+=velocityy
				if (Math.abs(velocityy) < .1) {
					velocityy=0
				}
			}
			// adjust the rotation of the actor
			if (Math.abs(velocityx) > 0 || Math.abs(velocityy) > 0) {
				radians=Math.atan2(velocityy, velocityx)
				newAngle=radians * 180 / Math.PI
			} else {
				newAngle=0
			}
			angleDiff=newAngle - actorRef.rotation
			if (Math.abs(angleDiff) > 0.1) {
				actorRef.rotation+=angleDiff * .1
				if (actorRef.rotation > 360) {
					actorRef.rotation-=360
				}
				if (actorRef.rotation < 0) {
					actorRef.rotation+=360
				}
				actorRef.cell++
				if (actorRef.cell > 23) {
					actorRef.cell=0
				}
			}

			if (actorRef.x > LotsOfCoins.stageWidth + LotsOfCoins.edgeBuffer) {
				actorRef.x=-LotsOfCoins.edgeBuffer
			}
			if (actorRef.x < -LotsOfCoins.edgeBuffer) {
				actorRef.x+=LotsOfCoins.stageWidth + LotsOfCoins.edgeBuffer
			}
			if (actorRef.y > LotsOfCoins.stageHeight + LotsOfCoins.edgeBuffer) {
				actorRef.y=-LotsOfCoins.edgeBuffer
			}
			if (actorRef.y < -LotsOfCoins.edgeBuffer) {
				actorRef.y=LotsOfCoins.stageHeight + LotsOfCoins.edgeBuffer
			}
		}
		public var velocityx:Number=0;
		public var velocityy:Number=0;
		public var actorRef:Actor
		public var animationRef:CellAnimation
	}
}