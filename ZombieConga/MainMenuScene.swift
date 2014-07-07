//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Liang on 7/7/14.
//  Copyright (c) 2014 Xing Michael. All rights reserved.
//

import SpriteKit


class MainMenuScene : SKScene {
    init(size: CGSize) {
        super.init(size: size);
        var bg = SKSpriteNode(imageNamed:"MainMenu.png");
        bg.position = CGPointMake(size.width/2, size.height/2);
        self.addChild(bg);
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        var gameScene = GameScene(size: self.scene.size);
        var reveal = SKTransition.flipHorizontalWithDuration(0.5);
        self.view.presentScene(gameScene, transition: reveal);
    }
}