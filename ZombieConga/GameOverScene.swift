//
//  GameOverScene.swift
//  ZombieConga
//
//  Created by Liang on 14-7-5.
//  Copyright (c) 2014年 Xing Michael. All rights reserved.
//

import SpriteKit

class GameOverScene : SKScene {
    
    var _won = false;
    
    init(size: CGSize, won: Bool){
        super.init(size: size)
        _won = won;

    }
    
    override func didMoveToView(view: SKView) {
        var bg:SKSpriteNode;
        if(_won){
            bg = SKSpriteNode(imageNamed:"YouWin.png");
            self.runAction(SKAction.sequence([SKAction.waitForDuration(1),
                SKAction.playSoundFileNamed("win.wav", waitForCompletion: false)]));
        }else{
            bg = SKSpriteNode(imageNamed:"YouLose.png");
            self.runAction(SKAction.sequence([SKAction.waitForDuration(0.1),
                SKAction.playSoundFileNamed("lose.wav", waitForCompletion: false)]));
        }
        bg.position = CGPointMake(size.width/2, size.height/2);
        self.addChild(bg);
    }
}


