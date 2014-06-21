//
//  GameScene.swift
//  ZombieConga
//
//  Created by Liang on 14-6-19.
//  Copyright (c) 2014年 Xing Michael. All rights reserved.
//

import SpriteKit


class GameScene: SKScene {
    
    let ZOMBIE_MOVE_POINTS_PER_SEC:CGFloat = 120.0;
    let ZOMBIE_ROTATE_RADIANS_PER_SEC = 2*M_PI;
    
    var _lastUpdateTime:NSTimeInterval = 0.0;
    var _dt:NSTimeInterval = 0.0;
    var _velocity:CGPoint = CGPointZero;
    var _zombie:SKSpriteNode = SKSpriteNode(imageNamed:"zombie1");
    var _zombieTowardLocation = CGPointZero;
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.backgroundColor = UIColor.whiteColor();
        
        let bg = SKSpriteNode(imageNamed:"background");
        bg.position = CGPoint(x: view.bounds.size.width/2,y: view.bounds.size.height/2);
        bg.anchorPoint = CGPoint(x: 0.5,y: 0.5);
        self.addChild(bg);
        
        _zombie.position = CGPointMake(100,100);
        self.addChild(_zombie);
        
        _zombieTowardLocation = _zombie.position;
        
        println("View bounds \(view.bounds)");
        println("Scene size \(self.size)")

    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if _lastUpdateTime != nil {
            _dt = currentTime - _lastUpdateTime;
        }else{
            _dt = 0;
        }
        
        _lastUpdateTime = currentTime;
        
        if( CGPointLength(const: CGPointSubtract(_zombie.position, b: _zombieTowardLocation)) >= CGPointLength(const:CGPointMultiplyScalar(_velocity, b: _dt))){
            self.moveSprite(_zombie, velocity:_velocity);
            self.rotateSprite(_zombie, direction:_velocity, rotateRadiansPerSec: ZOMBIE_ROTATE_RADIANS_PER_SEC);
        }
        else {
            _zombie.position = _zombieTowardLocation;
        }
        
//        println("\(_dt)");
    }
    
    
    
    
    // MARK: - move
    
    func moveSprite(sprite:SKSpriteNode, velocity:CGPoint){
        var amountToMove:CGPoint = CGPointMultiplyScalar(velocity, b: _dt);
        sprite.position = CGPointAdd(sprite.position, b:amountToMove);
    }
    
    func moveZombieToward(location:CGPoint){
        _zombieTowardLocation = location;
        var offset = CGPointSubtract(location, b: _zombie.position);
        var direction = CGPointNormalize(const: offset);
        _velocity = CGPointMultiplyScalar(direction, b: ZOMBIE_MOVE_POINTS_PER_SEC);
        println("zombie position : \(_zombie.position) , touch point : \(_zombieTowardLocation)");
    }
    
    func rotateSprite(sprite:SKSpriteNode, direction:CGPoint){
        sprite.zRotation = CGPointToAngle(const: direction);
    }
    
    func rotateSprite(sprite:SKSpriteNode, direction:CGPoint, rotateRadiansPerSec:CGFloat){
        var rotation = ScalarShortestAngleBetween(const: CGPointToAngle(const: direction), const: sprite.zRotation);
        println("rotation : \(rotation)")
        var amtToRotate = rotateRadiansPerSec*_dt;
        if (rotation>0) {
            if(rotation - amtToRotate < 0){
                sprite.zRotation = CGPointToAngle(const: direction);
            }else{
                sprite.zRotation -= amtToRotate;
            }
        }else{
            if(rotation + amtToRotate > 0){
                sprite.zRotation = CGPointToAngle(const: direction);
            }else{
                sprite.zRotation += amtToRotate;
            }
        }
    }
    
    
    // MARK: - Touch Actions
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        let touch = touches.anyObject() as UITouch;
        var touchLocation = touch.locationInNode(self);
        self.moveZombieToward(touchLocation);
    }

    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        let touch = touches.anyObject() as UITouch;
        var touchLocation = touch.locationInNode(self);
        self.moveZombieToward(touchLocation);

    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        let touch = touches.anyObject() as UITouch;
        var touchLocation = touch.locationInNode(self);
        self.moveZombieToward(touchLocation);

    }
    
    // MARK: - Helper Methods
    
    func CGPointMultiplyScalar(a:CGPoint,b:CGFloat)->CGPoint{
        return CGPointMake(a.x*b, a.y*b);
    }
    
    func CGPointAdd(a:CGPoint, b:CGPoint)->CGPoint{
        return CGPointMake(a.x+b.x, a.y+b.y);
    }
    
    func CGPointSubtract(a:CGPoint,b:CGPoint)->CGPoint{
        return CGPointMake(a.x-b.x,a.y-b.y);
    }
    
    func CGPointLength(const a:CGPoint)->CGFloat{
        return CGFloat(sqrtf(CFloat(a.x*a.x) + CFloat(a.y*a.y)));
    }
    
    func CGPointNormalize(const a:CGPoint)->CGPoint{
        var length = CGPointLength(const: a);
        return CGPointMake(a.x/length, a.y/length);
    }
    
    func CGPointToAngle(const a:CGPoint)->CGFloat{
        return CGFloat(atan2f(CFloat(a.y), CFloat(a.x)));
    }
    
    func ScalarSign(const a:CGFloat) -> CGFloat{
        return a >= 0 ? 1 : -1;
    }
    
    func ScalarShortestAngleBetween(const a:CGFloat, const b:CGFloat)->CGFloat{
        var difference = b - a;
        var angle = CGFloat(fmodf(CFloat(difference), CFloat(M_PI*2)));
        if angle >= M_PI {
            angle -= M_PI*2;
        }
        else if angle <= -M_PI {
            angle += M_PI*2;
        }
        return angle;
    }
    
    let ARC4RANDOM_MAX = 0x100000000;
    func ScalarRandomRange(min:CGFloat, max:CGFloat)->CGFloat{
        return CGFloat(floorf( ( CFloat(arc4random()) / CFloat(ARC4RANDOM_MAX)) * CFloat(max - min) + CFloat(min) ));
    }


}
