//
//  GameScene.swift
//  FlappyBird
//
//  Created by Emre Kunt on 17/01/16.
//  Copyright (c) 2016 usturlapp. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var bird    = SKSpriteNode()
    var bg      = SKSpriteNode()
    var labelHolder = SKSpriteNode()
    
    let birdGroup: UInt32 = 1
    let objectGroup : UInt32 = 2
    let gapGroup : UInt32 = 0 << 3
    
    var gameOver = 0
    var score = 0
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    
    var movingObjects = SKNode()
   
    
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, -5)
        self.addChild(movingObjects)
        self.addChild(labelHolder)
        

        addBg()
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 70)
        scoreLabel.zPosition = 3
        self.addChild(scoreLabel)
        

        let birdTexture     = SKTexture(imageNamed: "img/flappy1.png")
        let birdTexture2    = SKTexture(imageNamed: "img/flappy2.png")
        let animation       = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap    = SKAction.repeatActionForever(animation)
        
        bird    = SKSpriteNode(texture: birdTexture)
        bird.position   = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bird.runAction(makeBirdFlap)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2)
        bird.physicsBody?.dynamic = true;
        bird.physicsBody?.allowsRotation = false;
        bird.physicsBody?.categoryBitMask = birdGroup
        bird.physicsBody?.collisionBitMask = gapGroup
        bird.physicsBody?.contactTestBitMask = objectGroup
        bird.zPosition = 10
        self.addChild(bird)
        
        
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize:CGSizeMake(self.size.width, 1))
        ground.physicsBody?.dynamic = false;
        ground.physicsBody?.categoryBitMask = objectGroup
        self.addChild(ground)
    
        let timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(GameScene.animatePipes), userInfo: nil, repeats: true)
        
        
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == gapGroup || contact.bodyB.categoryBitMask == gapGroup{
            score += 1
            scoreLabel.text = "\(score)"
            
        } else {

            if gameOver == 0 {
            gameOver = 1
            movingObjects.speed = 0
            gameOverLabel.fontName = "Helvetica"
            gameOverLabel.fontSize = 30
            gameOverLabel.text = "TEKRAR DENEYİN!"
            gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            gameOverLabel.zPosition = 3
            labelHolder.addChild(gameOverLabel)
            }
        }
    }
    
    func animatePipes() {
        if gameOver == 0
        {
        let gapHeight = bird.size.height * 4
        let movementAmount = arc4random() % UInt32(self.frame.size.height / 2)
        let pipeOffSet = CGFloat(movementAmount) - self.frame.size.height / 4
        
        let movePipes = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        let pipe1Texture = SKTexture(imageNamed: "img/pipe1.png")
        let pipe1       = SKSpriteNode(texture: pipe1Texture)
        pipe1.position  = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipe1.size.height / 2 + gapHeight / 2 + pipeOffSet)
        pipe1.zPosition = 1
        pipe1.runAction(moveAndRemovePipes)
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipe1.size)
        pipe1.physicsBody?.dynamic = false
        pipe1.physicsBody?.categoryBitMask = objectGroup
        movingObjects.addChild(pipe1)
        
        let pipe2Texture = SKTexture(imageNamed: "img/pipe2.png")
        let pipe2       = SKSpriteNode(texture: pipe2Texture)
        pipe2.position  = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - pipe2.size.height / 2 - gapHeight / 2 + pipeOffSet)
        pipe2.zPosition = 1
        pipe2.runAction(moveAndRemovePipes)
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipe2.size)
        pipe2.physicsBody?.dynamic = false
        pipe2.physicsBody?.categoryBitMask = objectGroup
        movingObjects.addChild(pipe2)
            let gap = SKNode()
            gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeOffSet)
            gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe1.size.width, gapHeight))
            gap.runAction(moveAndRemovePipes)
            gap.physicsBody?.dynamic = false
            gap.physicsBody?.collisionBitMask = gapGroup
            gap.physicsBody?.categoryBitMask  = gapGroup
            gap.physicsBody?.contactTestBitMask = birdGroup
            movingObjects.addChild(gap)
            
        }
     
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if gameOver == 0{
            bird.physicsBody?.velocity = CGVectorMake(0,0)
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 50))
        } else {
            score = 0
            scoreLabel.text = "0"
            movingObjects.removeAllChildren()
            addBg()
            bird.position   = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
            bird.physicsBody?.velocity = CGVectorMake(0,0)
            
            labelHolder.removeAllChildren()
            gameOver = 0
            movingObjects.speed = 1

  
        }
    
    
    }
    
    func addBg(){
        let bgTexture       = SKTexture(imageNamed: "img/bg.png")
        let moveBg = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: 9)
        let replaceBg = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        let moveBgForever = SKAction.repeatActionForever(SKAction.sequence([moveBg, replaceBg]))
        
        for var i: CGFloat = 0; i < 3; i++ {
            
            bg = SKSpriteNode(texture: bgTexture)
            bg.position     = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * i, y: CGRectGetMidY(self.frame))
            bg.size.height  = self.frame.height
            bg.runAction(moveBgForever)
            movingObjects.addChild(bg)
            
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
