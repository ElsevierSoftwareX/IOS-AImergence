//
//  ExperimentNode.swift
//  AImergence2
//
//  Created by Olivier Georgeon on 20/01/16.
//  Copyright © 2016 Olivier Georgeon. All rights reserved.
//

import SpriteKit

class ExperimentSKNode: ReshapableSKNode
{
    let experiment: Experiment

    override var shapeIndex:Int {return experiment.shapeIndex }
    
    init(rect: CGRect, gameModel: GameModel, experiment: Experiment) {
        self.experiment = experiment
        super.init(rect: rect, gameModel: gameModel)
        reshape()
        fillColor = gameModel.color
        lineWidth = 0
        name = "experiment_\(experiment.number)"
    }
    
    convenience init(gameModel:GameModel, experiment:Experiment){
        self.init(rect: gameModel.experimentRect, gameModel: gameModel, experiment: experiment)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}