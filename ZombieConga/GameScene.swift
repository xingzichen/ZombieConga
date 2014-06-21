//
//  GameScene.swift
//  ZombieConga
//
//  Created by Liang on 14-6-19.
//  Copyright (c) 2014年 Xing Michael. All rights reserved.
//

import SpriteKit


class GameScene: SKScene {
    
    let ZOMBIE_MOVE_POINTS_PER_SEC:CFloat = 120.0
    
    var _lastUpdateTime:NSTimeInterval = 0.0;
    var _dt:NSTimeInterval = 0.0;
    var _velocity:CGPoint = CGPointZero;
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.backgroundColor = UIColor.whiteColor();
        
        let bg = SKSpriteNode(imageNamed:"background");
        bg.position = CGPoint(x: view.bounds.size.width/2,y: view.bounds.size.height/2);
        bg.anchorPoint = CGPoint(x: 0.5,y: 0.5);
//        bg.anchorPoint = CGPointZero;
        self.addChild(bg);
        
        println("View bounds \(view.bounds)");
        println("Scene size \(self.size)")

    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if _lastUpdateTime != nil {
            _dt = currentTime - _lastUpdateTime;
        }else{
            _dt = 0;
        }
        
        _lastUpdateTime = currentTime;
        println("\(_dt)");
    }
    
    func moveSprite(sprite:SKSpriteNode, velocity:CGPoint){
        var amountToMove:CGPoint = CGPointMultiplyScalar(velocity, b: _dt);
    }
    
    // MARK: - helper methods
    
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
