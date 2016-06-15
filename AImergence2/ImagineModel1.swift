//
//  WorldScene1.swift
//  AImergence
//
//  Created by Olivier Georgeon on 11/02/16.
//  Copyright © 2016 Olivier Georgeon. All rights reserved.
//

import SceneKit

class ImagineModel1: ImagineModel0
{
    var switchNode0: SCNNode!
    var switchNode1: SCNNode!
    
    override func setupSpecific(scene: SCNScene) {
    }
    
    override func playExperience(experience: Experience) {
        switch experience.hashValue {
        case 00: // Left
            createOrRetrieveBodyNodeAndRunAction(action: actions.bumpBack())
            if switchNode0 == nil { switchNode0 = createSwitchNode(SCNVector3(-1.5 * scale, 0, 0)) }
            spawnExperienceNode(experience, position: SCNVector3( -1.0 * scale, 0.0, 0.0), delay: 0.1)
        case 01:
            createOrRetrieveBodyNodeAndRunAction(backward: true, action: actions.bump())
            if switchNode0 == nil { switchNode0 = createSwitchNode(SCNVector3(-1.5 * scale, 0, 0)) }
            spawnExperienceNode(experience, position: SCNVector3( -1.0 * scale, 0.0, 0.0), delay: 0.1)
        case 10: // Right
            createOrRetrieveBodyNodeAndRunAction(backward: true, action: actions.bumpBack())
            if switchNode1 == nil { switchNode1 = createSwitchNode(SCNVector3(1.5 * scale, 0, 0)) }
            spawnExperienceNode(experience, position: SCNVector3( 1.0 * scale, 0.0, 0.0), delay: 0.1)
        case 11:
            createOrRetrieveBodyNodeAndRunAction(action: actions.bump())
            if switchNode1 == nil { switchNode1 = createSwitchNode(SCNVector3(1.5 * scale, 0, 0)) }
            spawnExperienceNode(experience, position: SCNVector3( 1.0 * scale, 0.0, 0.0), delay: 0.1)
        case 20, 21: // swap
            if bodyNode != nil { bodyNode.runAction(actions.turnover()) }
            spawnExperienceNode(experience, position: SCNVector3( 0.0, 0.0, 0.0))
        default:
            break
        }
    }
    
    func createSwitchNode(position: SCNVector3) -> SCNNode {
        let node = SCNNode(geometry: Geometries.cube())
        node.position = position
        worldNode.addChildNode(node)
        return node
    }
}