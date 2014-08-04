package ;

import motion.Actuate;
import aze.display.TileLayer;
import aze.display.TileClip;
import openfl.events.KeyboardEvent;
import openfl.geom.Rectangle;
import openfl.ui.Keyboard;
import openfl.Lib;
import openfl.display.Sprite;

enum PlayerStates {
	playerstand;
	playerup;
	playerdown;
	playerleft;
	playerright;
}

class Player extends Entity {
	
	private var _vclips:Array<TileClip>;
	private var _mapstate:Map<String, Int>;
	private var _curClip:TileClip;
	private var _movingDown:Bool;
	private var _invul:Bool;
	
	private var _pright:Int;
	private var _pleft:Int;
	private var _pup:Int;
	private var _pdown:Int;
	
	public function new(tl:TileLayer, x:Int, y:Int) {
		super(tl);
		
		this.x = x; this.y = y;
		_speed = 0.15;
		_movingDown = false;
		_invul = false;
		
		_vclips = new Array<TileClip>();
		_mapstate = new Map<String, Int>();
		
		var i:Int = 0;
		for (value in Type.getEnumConstructs(PlayerStates)) {
			var clip = new TileClip(_layer, value, 12);
			clip.x = x; clip.y = y;
			clip.visible = false;
			_layer.addChild(clip);
			
			_vclips.push(clip);
			_mapstate.set(value, i);
			i++;
		}
		
		_curClip = _vclips[_mapstate.get(Std.string(playerstand))];
		_curClip.visible = true;
		
		_hitbox = new Rectangle(x - 4, y - 8, 19, 10);
	}
	
	public override function keyPressed	(event:KeyboardEvent) : Void {
		switch (event.keyCode) {
			case Keyboard.UP: {
				_pup = 1;
			}
			case Keyboard.DOWN: {
				_pdown = 1;
			}
			case Keyboard.RIGHT: {
				_pright = 1;
			}
			case Keyboard.LEFT: {
				_pleft = 1;
			}
		}
	}
	
	public override function keyReleased(event:KeyboardEvent):Void {
		switch (event.keyCode) {
			case Keyboard.UP: {
				_pup = 0;
			}
			case Keyboard.DOWN: {
				_pdown = 0;
			}
			case Keyboard.RIGHT: {
				_pright = 0;
			}
			case Keyboard.LEFT: {
				_pleft = 0;
			}
		}
	}
	
	public function gotHit():Void {
		if (PlayState.getInstance()._lifes > 0) {
			PlayState.getInstance()._lifes--;
			PlayState.getInstance()._vlifes[PlayState.getInstance()._lifes].tile = "emptyheart";
			
			PlayState.getInstance()._sndplayerhit.play();
			PlayState.getInstance().damagedEffect(this, 2, 0.1);
			
			//_invul = true;
			//Actuate.timer(1.2).onComplete(Actuate.apply, [this, { _invul: false }]);
			
		} else {
			PlayState.getInstance()._sndexplosion.play();
			_invul = true;
			visible = false;
			PlayState.getInstance()._bodyexplosions.push(new BodyExplosion(_layer, Std.int(x), Std.int(y)));
			
			PlayState.getInstance().gameOver();
		}
	}
	
	public function update(eTime:Int, eb:Array<Bullet>):Void {
		
		// collisions with enemy bullets
		for (bullet in eb)
			if (collision(bullet)) {
				if (!_invul)
					gotHit();
				bullet.destroy();
			}
		
		_hspeed = _pright - _pleft;
		_vspeed = _pdown - _pup;
					
		x += _hspeed * eTime * _speed;
		y += _vspeed * eTime * _speed;

		if (x - _curClip.width / 2 < 0)
			x = _curClip.width / 2;
		else if (x + _curClip.width / 2 > 100)
			x = 100 - _curClip.width / 2;

		if (y - _curClip.height / 2 < 0)
			y = _curClip.height / 2;
		else if (y + _curClip.height / 2 > 144 - 30 + 6)
			y = 144 - _curClip.height / 2 - 30 + 6;
		
		// select the correct sprite
		if (_vspeed == 1) {
			_curClip = _vclips[_mapstate.get(Std.string(playerdown))];
			_movingDown = true;
		} else if (_vspeed == -1) {
			_curClip = _vclips[_mapstate.get(Std.string(playerup))];
		} else if (_hspeed == 1) {
			_curClip = _vclips[_mapstate.get(Std.string(playerstand))];
		} else if (_hspeed == -1) {
			_curClip = _vclips[_mapstate.get(Std.string(playerleft))];
		} else
			_curClip = _vclips[_mapstate.get(Std.string(playerstand))];
		
		for (i in _vclips)
			i.visible = false;
			
		if (visible)
			_curClip.visible = true;
			
		_curClip.x = x; _curClip.y = y;
		if (_movingDown)
			_curClip.y -= 8;

		_movingDown = false;
		
		_hitbox.x = x - 4; _hitbox.y = y - 9;
	}
	
}
