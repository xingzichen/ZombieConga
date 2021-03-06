//
//  GameScene.swift
//  ZombieConga
//
//  Created by Liang on 14-6-19.
//  Copyright (c) 2014年 Xing Michael. All rights reserved.
//

import SpriteKit
import AVFoundation


class GameScene: SKScene {
    
    let ZOMBIE_MOVE_POINTS_PER_SEC:CGFloat = 120.0;
    let ZOMBIE_ROTATE_RADIANS_PER_SEC:CGFloat = CGFloat(2*M_PI);
    
    let CAT_MOVE_POINTS_PER_SEC:CGFloat = 120.0;
    let CAT_ROTATE_RADIANS_PER_SEC = CGFloat(2*M_PI);
    
    let BG_POINTS_PER_SEC:CGFloat = 50;

    
    var _lastUpdateTime:NSTimeInterval = 0.0;
    var _dt:NSTimeInterval = 0.0;
    var _velocity:CGPoint = CGPointZero;
    var _zombie:SKSpriteNode = SKSpriteNode(imageNamed:"zombie1");
    var _zombieTowardLocation = CGPointZero;
    var _zombieAnimation = SKAction();
    var _catTrain = [SKSpriteNode]();
    var _bgLayer:SKNode = SKNode();
    
    var _backgroundMusicPlayer = AVAudioPlayer();
    
    var _lives = 20;
    var _gameOver = false;
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.backgroundColor = UIColor.whiteColor();
        self.playBackgroundMusic("bgMusic.mp3");
        
        _bgLayer = SKNode();
        self.addChild(_bgLayer);
        
        for var i=0;i<2;i++ {
        
            let bg = SKSpriteNode(imageNamed:"background");
    //        bg.position = CGPoint(x: view.bounds.size.width/2,y: view.bounds.size.height/2);
    //        bg.anchorPoint = CGPoint(x: 0.5,y: 0.5);
    //        self.addChild(bg);
            bg.anchorPoint = CGPointZero;
            bg.position = CGPointMake(bg.size.width*CGFloat(i), 0);
            bg.name = "bg";
//            self.addChild(bg);
            _bgLayer.addChild(bg);

        }
        
        _zombie.position = CGPointMake(100,100);
//        self.addChild(_zombie);
        _bgLayer.addChild(_zombie);
        
        _zombieTowardLocation = _zombie.position;
        
        self.runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnEnemy),SKAction.waitForDuration(2.0)])));
        
        self.runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnCats),SKAction.waitForDuration(1.0)])));
        
        self.initZombieAnimation();
        
        

    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if _lastUpdateTime != 0 {
            _dt = currentTime - _lastUpdateTime;
        }else{
            _dt = 0;
        }
//        println(_dt);
        _lastUpdateTime = currentTime;
        
        if( CGPointLength(const: CGPointSubtract(_zombie.position, b: _zombieTowardLocation)) > CGPointLength(const:CGPointMultiplyScalar(_velocity, b: CGFloat(_dt)))){
            self.moveSprite(_zombie, velocity:_velocity);
            self.rotateSprite(_zombie, direction:_velocity, rotateRadiansPerSec:ZOMBIE_ROTATE_RADIANS_PER_SEC);
        }
        else {
            _zombie.position = _zombieTowardLocation;
            self.stopZombieAnimation();
        }
        
        self.boundsCheckPlayer();
        
//        moveSpriteToLocation(_zombie, location:_zombieTowardLocation, self.stopZombieAnimation);
        if( _lives<=0 && !_gameOver){
            _gameOver = true;
//            println("Yeah !!! Game Over!!!");
            
            var gameOverScene = GameOverScene(size: self.scene.size, won: false);
            var reveal = SKTransition.flipHorizontalWithDuration(0.5);
            self.view.presentScene(gameOverScene, transition: reveal);
            _backgroundMusicPlayer.stop();
            self.checkCollisions();
            self.moveTrain();
        }
        
    }
    
    override func didEvaluateActions() {
        self.moveBg();
        
    }
    
    // MARK: - sprite nodes
    
    func spawnEnemy(){
        var enemy = SKSpriteNode(imageNamed:"enemy");
        var enemyScenePos = CGPointMake(self.view.bounds.size.width + enemy.size.width/2,
            ScalarRandomRange(enemy.size.height/2, max: self.view.bounds.size.height-enemy.size.height/2));
        
        enemy.position = self.convertPoint(enemyScenePos, toNode:_bgLayer);
        
        enemy.name = "enemy";
//        self.addChild(enemy);
        _bgLayer.addChild(enemy);
        
        var actionMove = SKAction.moveToX(enemy.size.width/2, duration: 2.0);
        var actionRemove = SKAction.removeFromParent();
        
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]));
    }
    
    func spawnCats(){
        var cat = SKSpriteNode(imageNamed:"cat");
        var catScenePos = CGPointMake(ScalarRandomRange(0, max:self.view.bounds.width),
            ScalarRandomRange(0, max:self.view.bounds.height));
        
        cat.position = self.convertPoint(catScenePos, toNode:_bgLayer);
        
        cat.xScale = 0;
        cat.yScale = 0;
        cat.name = "cat";
//        self.addChild(cat);
        _bgLayer.addChild(cat);
        
        cat.zRotation = CGFloat(-M_PI/16);
        var actionAppear = SKAction.scaleTo(1.0, duration:0.5);
        var actionWait = SKAction.waitForDuration(10);
        
        var actionLeftWiggle = SKAction.rotateByAngle(CGFloat(M_PI/8), duration: 0.5);
        var actionRightWiggle = actionLeftWiggle.reversedAction();
        var actionFullWiggle = SKAction.sequence([actionLeftWiggle, actionRightWiggle]);
        
        var actionScaleUp = SKAction.scaleTo(1.2, duration:0.25);
        var actionScaleDown = actionScaleUp.reversedAction();
        var actionFullScale = SKAction.sequence([actionScaleUp, actionScaleDown]);
        
        var actionGroup = SKAction.sequence([actionFullScale, actionFullWiggle]);
        var actionGroupWait = SKAction.repeatAction(actionGroup, count: 10);
        
        var actionDisappear = SKAction.scaleTo(0, duration: 0.5);
        var removeFromParent = SKAction.removeFromParent();
        
        cat.runAction(SKAction.sequence([actionAppear, actionGroupWait, actionWait, actionDisappear, removeFromParent]));
    }
    
    // MARK: - Nodes Relations
    
    func checkCollisions(){
        _bgLayer.enumerateChildNodesWithName("cat", usingBlock:{ node, stop in
            var cat = node as SKSpriteNode;
            if(CGRectIntersectsRect(cat.frame,self._zombie.frame)){
//                cat.removeFromParent();
                self.addCatIntoTrain(cat);
                self.runAction(SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false));
            }
            });
        
        _bgLayer.enumerateChildNodesWithName("enemy", usingBlock:{ node, stop in
            var enemy = node as SKSpriteNode;
            var smallerFrame = CGRectInset(enemy.frame, 20, 20);
            if(CGRectIntersectsRect(smallerFrame, self._zombie.frame)){
                enemy.removeFromParent();
                self.runAction(SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false));
                self.loseCats();
                self._lives--;
            }
            });
    }
    
    func addCatIntoTrain(cat:SKSpriteNode){
        cat.name = "train";
        cat.removeAllActions();
        var actionScale = SKAction.scaleTo(1, duration:0.2);
        var actionGreen = SKAction.colorizeWithColor(UIColor.greenColor(), colorBlendFactor:1.0, duration:0.2);
        cat.runAction(SKAction.sequence([actionScale, actionGreen]));
        _catTrain.append(cat);
        
        if( _catTrain.count >= 10 && _lives>0){
            _gameOver = true;
//            println("Ooh!!! You Win!!!");
            var gameOverScene = GameOverScene(size: self.scene.size, won: true);
            var reveal = SKTransition.flipHorizontalWithDuration(0.5);
            self.view.presentScene(gameOverScene, transition: reveal);
            _backgroundMusicPlayer.stop();
        }
    }
    
    func loseCats(){
        var loseCount = 0;
        
        if(_catTrain.count == 0){
            return;
        }
        
        var node = _catTrain[_catTrain.count-1];
        
        var randomSpot = node.position;
        randomSpot.x += self.ScalarRandomRange(-100, max: 100);
        randomSpot.y += self.ScalarRandomRange(-100, max: 100);
        node.name = "";
        
        var actionRotate = SKAction.rotateByAngle(CGFloat(M_PI * 4), duration:1.0);
        var actionMoveRandom = SKAction.moveTo(randomSpot, duration: 1.0);
        var actionDisappear = SKAction.scaleTo(0, duration: 1.0);
        var action = SKAction.sequence([SKAction.group([actionRotate,actionMoveRandom,actionDisappear]),SKAction.removeFromParent()]);
                    
        node.runAction(action);
        
        _catTrain.removeAtIndex(_catTrain.count-1);
        
//        self.enumerateChildNodesWithName("train", usingBlock:{
//            (node: SKNode!, stop: CMutablePointer<ObjCBool>) -> Void in
//            var randomSpot = node.position;
//            randomSpot.x += self.ScalarRandomRange(-100, max: 100);
//            randomSpot.y += self.ScalarRandomRange(-100, max: 100);
//            node.name = "";
//            
//            var actionRotate = SKAction.rotateByAngle(M_PI * 4, duration:1.0);
//            var actionMoveRandom = SKAction.moveTo(randomSpot, duration: 1.0);
//            var actionDisappear = SKAction.scaleTo(0, duration: 1.0);
//            var action = SKAction.sequence([SKAction.group([actionRotate,actionMoveRandom,actionDisappear]),SKAction.removeFromParent()]);
//            
//            node.runAction(action);
//            loseCount++;
//            if(loseCount>=2){
//                stop.withUnsafePointer() { (p :UnsafePointer<ObjCBool>) in
//                    p.memory = true /* or whatever */
//                }
//            }
//
//            });
    
    }
    
    // MARK: - Zombie Animations
    
    func initZombieAnimation(){
        var textures:AnyObject[] = [];
        for var i=1;i<=4;++i {
            var textureName = String(format: "zombie%d", i);
            var texture = SKTexture(imageNamed: textureName);
            textures.append(texture);
        }
        for var i=3;i>0;--i {
            var textureName = String(format: "zombie%d", i);
            var texture = SKTexture(imageNamed: textureName);
            textures.append(texture);
        }
        _zombieAnimation = SKAction.animateWithTextures(textures, timePerFrame: 0.1);
    }
    
    func startZombieAnimation(){
        if !_zombie.actionForKey("animation") {
            _zombie.runAction(SKAction.repeatActionForever(_zombieAnimation), withKey:"animation");
        }
    }
    
    func stopZombieAnimation(){
        _zombie.removeActionForKey("animation");
    }
    
    // MARK: - move
    
    func moveSprite(sprite:SKSpriteNode, velocity:CGPoint){
        var amountToMove:CGPoint = CGPointMultiplyScalar(velocity, b: CGFloat(_dt));
        sprite.position = CGPointAdd(sprite.position, b:amountToMove);
    }
    
    func moveSpriteToLocation(sprite:SKSpriteNode, location:CGPoint ){
        var offset = CGPointSubtract(location, b: sprite.position);
        var direction = CGPointNormalize(const: offset);
        var velocity = CGPointMultiplyScalar(direction, b: CAT_MOVE_POINTS_PER_SEC);
        
        if( CGPointLength(const: CGPointSubtract(sprite.position, b: location)) >= CGPointLength(const:CGPointMultiplyScalar(velocity, b: CGFloat(_dt)))){
            self.moveSprite(sprite, velocity:velocity);
            self.rotateSprite(sprite, direction:velocity, rotateRadiansPerSec: CAT_ROTATE_RADIANS_PER_SEC);
        }
        else {
//            sprite.position = location;
        }
    }
    
    func moveZombieToward(location:CGPoint){
        self.startZombieAnimation();
        _zombieTowardLocation = location;
        var offset = CGPointSubtract(location, b: _zombie.position);
        var direction = CGPointNormalize(const: offset);
        _velocity = CGPointMultiplyScalar(direction, b: ZOMBIE_MOVE_POINTS_PER_SEC);
//        println("zombie position : \(_zombie.position) , touch point : \(_zombieTowardLocation)");
    }
    
    func rotateSprite(sprite:SKSpriteNode, direction:CGPoint){
        sprite.zRotation = CGPointToAngle(const: direction);
    }
    
    func rotateSprite(sprite:SKSpriteNode, direction:CGPoint, rotateRadiansPerSec:CGFloat){
        var rotation = ScalarShortestAngleBetween(const: CGPointToAngle(const: direction), const: sprite.zRotation);
        var amtToRotate = rotateRadiansPerSec*CGFloat(_dt);
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
    
    func moveTrain(){
        // make sure the train is not empty
        if _catTrain.isEmpty {
            return;
        }
        // first cat follow the zombie
        _catTrain[0].runAction(self.actionFollow(_zombie, follower: _catTrain[0]));
        // other cats follow the front one
        for (var i=1; i<_catTrain.count; ++i){
            _catTrain[i].runAction(self.actionFollow(_catTrain[i-1], follower: _catTrain[i]));
        }
        
    }
    
    func actionFollow(leader:SKSpriteNode, follower:SKSpriteNode)->SKAction{
        var actionWait = SKAction.waitForDuration(0.5);
        var actionFollow = SKAction.runBlock({
                self.moveSpriteToLocation(follower, location: leader.position);
            });
        return SKAction.sequence([actionWait, actionFollow]);
    }
    
    func moveBg(){
//        self.enumerateChildNodesWithName("bg", usingBlock:{ node, stop in
//            var bg:SKSpriteNode = node as SKSpriteNode;
        var bgVelocity = CGPointMake(-self.BG_POINTS_PER_SEC, 0);
        var amtToMove = self.CGPointMultiplyScalar(bgVelocity, b: CGFloat(self._dt));
        self._bgLayer.position = self.CGPointAdd(self._bgLayer.position, b: amtToMove);
        
        self._bgLayer.enumerateChildNodesWithName( "bg", usingBlock:{node, stop in
            var bg:SKSpriteNode = node as SKSpriteNode;
            var bgScreenPos = self._bgLayer.convertPoint(bg.position, toNode:self);
            if (bgScreenPos.x <= -bg.size.width){
                bg.position = CGPointMake(bg.position.x + bg.size.width*2, bg.position.y);
            }
        });
//        });
    }
    
    func boundsCheckPlayer(){
        var newPosition = _zombie.position;
        var newVelocity = _velocity;
        
        var bottomLeft = _bgLayer.convertPoint(CGPointZero,fromNode:self);
        var topRight = _bgLayer.convertPoint(CGPointMake(self.view.bounds.size.width/2,self.view.bounds.size.height/2), fromNode:self);
        
        if (newPosition.x <= bottomLeft.x) {
            newPosition.x = bottomLeft.x;
            newVelocity.x = -newVelocity.x;
        }
        if (newPosition.x >= topRight.x) {
            newPosition.x = topRight.x;
            newVelocity.x = -newVelocity.x;
        }
        if (newPosition.y <= bottomLeft.y) {
            newPosition.y = bottomLeft.y;
            newVelocity.y = -newVelocity.y;
        }
        if (newPosition.y >= topRight.y) {
            newPosition.y = topRight.y;
            newVelocity.y = -newVelocity.y;
        }
        
        // 4
        _zombie.position = newPosition;
        _velocity = newVelocity;
    }
    
    // MARK: - Touch Actions
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        let touch = touches.anyObject() as UITouch;
        var touchLocation = touch.locationInNode(_bgLayer);
        self.moveZombieToward(touchLocation);
    }

    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        let touch = touches.anyObject() as UITouch;
        var touchLocation = touch.locationInNode(_bgLayer);
        self.moveZombieToward(touchLocation);

    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        let touch = touches.anyObject() as UITouch;
        var touchLocation = touch.locationInNode(_bgLayer);
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
        if length==0 {
            length = 1;
        }
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
        if angle >= CGFloat(M_PI) {
            angle -= CGFloat(M_PI*2);
        }
        else if angle <= CGFloat(-M_PI) {
            angle += CGFloat(M_PI*2);
        }
        return angle;
    }
    
    let ARC4RANDOM_MAX = 0x100000000;
    func ScalarRandomRange(min:CGFloat, max:CGFloat)->CGFloat{
        return CGFloat(floorf( ( CFloat(arc4random()) / CFloat(ARC4RANDOM_MAX)) * CFloat(max - min) + CFloat(min) ));
    }
    
    func playBackgroundMusic(filename : String){
        var error:AutoreleasingUnsafePointer<NSError?> = nil;// = AutoreleasingUnsafePointer<NSError?>();
        var backgroundMusicURL = NSBundle.mainBundle().URLForResource(filename, withExtension:nil);
        _backgroundMusicPlayer = AVAudioPlayer(contentsOfURL:backgroundMusicURL, error:error);
        _backgroundMusicPlayer.numberOfLoops = -1;
        _backgroundMusicPlayer.prepareToPlay();
        _backgroundMusicPlayer.play();
    }


}
