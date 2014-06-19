//
//  GameScene.swift
//  ZombieConga
//
//  Created by Liang on 14-6-19.
//  Copyright (c) 2014年 Xing Michael. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
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
        
//        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
//        myLabel.text = "Hello, World!";
//        myLabel.fontSize = 65;
//        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
//        
//        self.addChild(myLabel)
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
    }
    
    
}
