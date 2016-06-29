//
//  GameScene.swift
//  AImergence2
//
//  Created by Olivier Georgeon on 09/01/16.
//  Copyright (c) 2016 Olivier Georgeon. All rights reserved.
//

import SpriteKit

protocol GameSceneDelegate
{
    func playExperience(experience: Experience)
    func unlockLevel(score: Int)
    func isInstructionUnderstood() -> Bool
    func isImagineUnderstood() -> Bool
    func isLevelUnlocked() -> Bool
    func isInterfaceUnlocked(interface: Int) -> Bool
    func showInstructionWindow()
    func showImagineWindow()
    func showGameCenter()
    func showLevelWindow()
}

enum BUTTON: Int { case INSTRUCTION, IMAGINE, GAMECENTER, LEVEL, NONE}

class GameSKScene: PositionedSKScene {
    
    let gameModel:GameModel2
    let level:Level0
    
    let backgroundNode = SKSpriteNode(imageNamed: "fond.png")
    let robotNode = SKSpriteNode(imageNamed: "happy1.png")
    let instructionButtonNode = ButtonSKNode(activatedImageNamed: "instructions-color", disactivatedImageNamed: "instructions-black")
    let imagineButtonNode = ButtonSKNode(activatedImageNamed: "imagine-color", disactivatedImageNamed: "imagine-black")
    let gameCenterButtonNode = ButtonSKNode(activatedImageNamed: "gamecenter-color", disactivatedImageNamed: "gamecenter-black")
    let levelButtonNode = ButtonSKNode(activatedImageNamed: "levels-color", disactivatedImageNamed: "levels-black")
    
    var currentButton = BUTTON.NONE
    
    var gameSceneDelegate: GameSceneDelegate!
    var experimentNodes = [ExperimentSKNode]()
    var experienceNodes = Set<ExperienceSKNode>()
    var clock:Int = 0
    var scoreLabel:SKLabelNode
    var scoreBackground:SKShapeNode
    var shapePopupNode:SKNode!
    var shapeNodes = Array<SKShapeNode>()
    var colorPopupNode: SKNode?
    var colorNodes = Array<SKShapeNode>()
    var editNode: ReshapableSKNode?
    var won = false
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
            scoreLabel.removeAllChildren()
            scoreLabel.addChild(gaugeNode(score))
            if score >= level.winScore {
                scoreBackground.fillColor = UIColor.greenColor()
                if !won {
                    gameSceneDelegate.unlockLevel(clock)
                    won = true
                    imagineButtonNode.pulse()
                }
                if !gameSceneDelegate.isImagineUnderstood() {
                    if currentButton == BUTTON.INSTRUCTION {
                        shiftButton()
                    }
                }
            } else {
                scoreBackground.fillColor = UIColor.whiteColor()
            }
        }
    }
    
    var robotHappyFrames: [SKTexture]!
    var robotSadFrames: [SKTexture]!
    var robotBlinkFrames: [SKTexture]!
    
    init(gameModel: GameModel2)
    {
        self.level = gameModel.level
        self.gameModel = gameModel
        scoreLabel = gameModel.createScoreLabel()
        scoreBackground = gameModel.createScoreBackground()
        super.init(size:CGSize(width: 0 , height: 0))
        cameraNode = SKCameraNode()
        self.camera = cameraNode
        self.addChild(cameraNode!)
        cameraNode!.addChild(cameraRelativeOriginNode)        
        layoutScene()
    }

    required init?(coder aDecoder: NSCoder)
    {
        self.level = Level0()
        self.gameModel = GameModel2()
        scoreLabel = gameModel.createScoreLabel()
        scoreBackground = gameModel.createScoreBackground()
        super.init(coder: aDecoder)
        layoutScene()
    }
    
    func layoutScene()
    {
        anchorPoint = CGPointZero
        scaleMode = .AspectFill
        name = "gameScene"
        
        backgroundColor = gameModel.backgroundColor
        
        self.addChild(scoreBackground)
        scoreBackground.addChild(scoreLabel)
        scoreLabel.addChild(gaugeNode(0))
        
        shapePopupNode = gameModel.createShapePopup()
        shapeNodes = gameModel.createShapeNodes(shapePopupNode)
        
        experimentNodes = gameModel.createExperimentNodes(self)
        
        robotNode.size = CGSize(width: 100, height: 100)
        robotNode.position = CGPoint(x: 120, y: 180)
        robotNode.zPosition = 1
        cameraRelativeOriginNode.addChild(robotNode)
        backgroundNode.size = CGSize(width: 1188 , height: 1188)
        backgroundNode.position = CGPoint(x: 400, y: 0)
        backgroundNode.zPosition = -20
        backgroundNode.name = "background"
        cameraRelativeOriginNode.addChild(backgroundNode)
        robotNode.addChild(instructionButtonNode)
        robotNode.addChild(imagineButtonNode)
        robotNode.addChild(gameCenterButtonNode)
        robotNode.addChild(levelButtonNode)
        
        robotHappyFrames = loadFrames("happy", imageNumber: 6, by: 1)
        robotSadFrames = loadFrames("sad", imageNumber: 7, by: 1)
        robotBlinkFrames = loadFrames("blink", imageNumber: 9, by: 3)
    }
    
    override func didMoveToView(view: SKView)
    {
        /* Setup your scene here */
        super.didMoveToView(view)

        // Needs the delegate to be ready
        if !gameSceneDelegate.isInstructionUnderstood() {
            currentButton = BUTTON.INSTRUCTION
            instructionButtonNode.pulse()
            levelButtonNode.disappear()
            instructionButtonNode.appear()
        } else if !gameSceneDelegate.isImagineUnderstood() {
            currentButton = BUTTON.IMAGINE
            imagineButtonNode.pulse()
            levelButtonNode.disappear()
            imagineButtonNode.appear()
        }
        if gameSceneDelegate.isInstructionUnderstood() {
            instructionButtonNode.disactivate()
        }
        if gameSceneDelegate.isImagineUnderstood() {
            imagineButtonNode.disactivate()
        }
        if gameSceneDelegate.isInterfaceUnlocked(2) {
            gameCenterButtonNode.disactivate()
            levelButtonNode.disactivate()
        }
        
        for recognizer in view.gestureRecognizers ?? [] {
            if recognizer is UITapGestureRecognizer || recognizer is UILongPressGestureRecognizer  {
                view.removeGestureRecognizer(recognizer)
            }
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameSKScene.tap(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(GameSKScene.longPress(_:)))
        view.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    override func positionInFrame(frameSize: CGSize) {
        super.positionInFrame(frameSize)
        if frameSize.height > frameSize.width {
            cameraNode?.position =  PositionedSKScene.portraitCameraPosition
            cameraRelativeOriginNode.position = -PositionedSKScene.portraitCameraPosition
            backgroundNode.position.x = 0
            backgroundNode.size.width = 667
            robotNode.position = PositionedSKScene.portraitRobotPosition
            robotNode.setScale(1)
        } else {
            cameraNode?.position.x =  size.width / 2 - 190
            cameraNode?.position.y =  233
            //cameraRelativeOriginNode.position = -PositionedSKScene.landscapeCameraPosition
            if cameraNode != nil {
                cameraRelativeOriginNode.position = -cameraNode!.position
            }
            backgroundNode.position.x = 400
            backgroundNode.size.width = 1188
            robotNode.position = PositionedSKScene.landscapeRobotPosition
            robotNode.setScale(2)
        }      
    }
        
    func tap(recognizer: UITapGestureRecognizer)
    {
        let positionInScene = self.convertPointFromView(recognizer.locationInView(self.view))
        let positionInScreen = cameraRelativeOriginNode.convertPoint(positionInScene, fromNode: self)
        let positionInRobot = robotNode.convertPoint(positionInScene, fromNode: self)
        for experimentNode in experimentNodes {
            if experimentNode.containsPoint(positionInScene){
                play(experimentNode)
            }
        }
        //if robotNode!.containsPoint(positionInScreen) { // also includes the robotNode's child nodes
        if CGRectContainsPoint(robotNode.frame, positionInScreen) {
            shiftButton()
        }
        if instructionButtonNode.containsPoint(positionInRobot) {
            gameSceneDelegate.showInstructionWindow()
        }
        if imagineButtonNode.containsPoint(positionInRobot) {
            gameSceneDelegate.showImagineWindow()
        }
        if gameCenterButtonNode.containsPoint(positionInRobot) {
            gameSceneDelegate.showGameCenter()
        }
        if levelButtonNode.containsPoint(positionInRobot) {
            gameSceneDelegate.showLevelWindow()
            levelButtonNode.unpulse()
        }
    }
    
    func shiftButton() {
        if currentButton.rawValue >= BUTTON.NONE.rawValue {
            currentButton = BUTTON.INSTRUCTION
        } else {
            currentButton = BUTTON(rawValue: currentButton.rawValue + 1)!
        }
        switch currentButton {
        case .INSTRUCTION:
            instructionButtonNode.appear()
        case .IMAGINE:
            instructionButtonNode.disappear()
            imagineButtonNode.appear()
        case .GAMECENTER:
            imagineButtonNode.disappear()
            gameCenterButtonNode.appear()
        case .LEVEL:
            gameCenterButtonNode.disappear()
            levelButtonNode.appear()
        default:
            levelButtonNode.disappear()
        }
    }
    
    func longPress(recognizer: UILongPressGestureRecognizer)
    {
        let positionInScene = self.convertPointFromView(recognizer.locationInView(self.view))
        let positionInShapePopup = shapePopupNode?.convertPoint(positionInScene, fromNode: self)
        let positionInColorPopup = colorPopupNode?.convertPoint(positionInScene, fromNode: self)

        switch recognizer.state {
        case .Began:
            for experimentNode in experimentNodes {
                if CGRectContainsPoint(experimentNode.frame, positionInScene) {
                //if experimentNode.containsPoint(positionInScene) {
                    editNode = experimentNode
                    addChild(shapePopupNode!)
                }
            }
            for experienceNode in experienceNodes {
                if CGRectContainsPoint(experienceNode.calculateAccumulatedFrame(), positionInScene) {
                //if experienceNode.containsPoint(positionInScene) {
                    editNode = experienceNode
                    colorPopupNode = gameModel.createColorPopup()
                    colorNodes = gameModel.createColorNodes(colorPopupNode!, experience: experienceNode.experience)
                    cameraRelativeOriginNode.addChild(colorPopupNode!)
                }
            }
        case .Ended:
            for i in 0..<shapeNodes.count {
                if CGRectContainsPoint(shapeNodes[i].frame, positionInShapePopup!) {
                //if shapeNodes[i].containsPoint(positionInShapePopup!) {
                    if let experimentNode = editNode as? ExperimentSKNode {
                        experimentNode.experiment.shapeIndex = i
                        experimentNode.reshape()
                        for node in experienceNodes {
                            if node.experience.experimentNumber == experimentNode.experiment.number {
                                node.reshape()
                            }
                        }
                    }
                }
            }
            shapePopupNode?.removeFromParent()
            for i in 0..<colorNodes.count {
                if CGRectContainsPoint(colorNodes[i].frame, positionInColorPopup!) {
                //if colorNodes[i].containsPoint(positionInColorPopup!) {
                    if let experienceNode = editNode as? ExperienceSKNode {
                        experienceNode.experience.colorIndex = i
                        for node in experienceNodes {
                            node.refill()
                        }
                    }
                }
            }
            colorNodes = Array<SKShapeNode>()
            colorPopupNode?.removeFromParent()
            colorPopupNode = nil
            editNode = nil
        default:
            break
        }
    }
    
    func play(experimentNode: ExperimentSKNode) {
        
        clock += 1
        
        let experiment = experimentNode.experiment
        
        let(experience, score) = level.play(experiment)
        self.score = score

        switch experience.valence {
        case let x where x > 0 :
            animRobot(robotHappyFrames)
        case let x where x < 0:
            animRobot(robotSadFrames)
        default:
            animRobot(robotBlinkFrames)
        }
        
        gameSceneDelegate.playExperience(experience)
        
        for node in experienceNodes {
            if node.isObsolete(clock) {
                node.removeFromParent()
                experienceNodes.remove(node)
            } else {
                node.runAction(gameModel.actionMoveTrace)
            }
        }
        
        let experienceNode = ExperienceSKNode(experience: experience, stepOfCreation: clock, gameModel: gameModel)
        experienceNode.position = experimentNode.position 
        addChild(experienceNode)
        experienceNodes.insert(experienceNode)
        
        let actionIntroduce = SKAction.moveBy(gameModel.moveByVect(experimentNode.position), duration: 0.3)

        experienceNode.runAction(gameModel.actionScale)
        experienceNode.runAction(actionIntroduce, completion: {experienceNode.addValenceNode()})
    }
    
    func animRobot(texture: [SKTexture]) {
        robotNode.runAction(
            SKAction.animateWithTextures(texture, timePerFrame: 0.05, resize: false, restore: false))
    }
    
    func loadFrames(imageName: String, imageNumber: Int, by: Int) -> [SKTexture] {
        var frames = [SKTexture]()
        
        for i in 1.stride(to: imageNumber, by: by) {
        //for var i=1; i<=imageNumber; i = i + 3 {
            let textureName = imageName + "\(i)"
            frames.append(SKTexture(imageNamed: textureName))
        }
        for i in imageNumber.stride(to: 0, by: -by) {
        //for var i = imageNumber - 1; i > 0; i = i - 3 {
            let textureName = imageName + "\(i)"
            frames.append(SKTexture(imageNamed: textureName))
        }
        frames.append(SKTexture(imageNamed: imageName + "1"))
        return frames
    }
    
    func gaugeNode(score: Int) -> SKNode {
        let gaugeNode = SKNode()
        gaugeNode.position = CGPoint(x: -50, y: -40)
        var y = -70
        var height = 140
        if score < -10 {
            y = score * 6 - 10
            height = -score * 6 + 80
        }
        if score > 10 {
            height = score * 6 + 80
        }
        let gaugeBackgroundNode = SKShapeNode(rect: CGRect(x: -3, y: y, width: 10, height: height), cornerRadius: 5)
        gaugeBackgroundNode.zPosition = -1
        //gaugeBackgroundNode.fillColor = UIColor.whiteColor()
        gaugeBackgroundNode.lineWidth = 1
        gaugeNode.addChild(gaugeBackgroundNode)
        if score > 0 {
            for i in 1...score {
                let dotNode = SKShapeNode(rect: CGRect(x: -1, y: i * 6, width: 6, height: 4))
                dotNode.fillColor = UIColor.greenColor()
                dotNode.lineWidth = 0
                gaugeNode.addChild(dotNode)
            }
        }
        if score < 0 {
            for i in 1...(-score) {
                let dotNode = SKShapeNode(rect: CGRect(x: -1, y: -i * 6, width: 6, height: 4))
                dotNode.fillColor = UIColor.redColor()
                dotNode.lineWidth = 0
                gaugeNode.addChild(dotNode)
            }
        }
        return gaugeNode
    }
}

