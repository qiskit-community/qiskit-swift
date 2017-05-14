//
//  BlochModelView.swift
//  QIKitAnalysis
//
//  Created by Joe Ligman on 4/5/17.
//  Copyright (c) 2017 IBM. All rights reserved.
//

import SceneKit
import QuartzCore


public class BlochModelView: SCNView {
    
    public func setupBlochSphereScene() {
   
        debugPrint("common initi")
        let scn = SCNScene(named: "Scene.scnassets/machine.scn")
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scn?.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.lightGray
        scn?.rootNode.addChildNode(ambientLightNode)
        
        scn?.rootNode.enumerateChildNodes { (node, _) in
            switch node.name {
            case .some("xaxis"):
                node.rotation = SCNVector4Make(0, 0, 1, .pi / 2)
            case .some("zaxis"):
                node.rotation = SCNVector4Make(1, 0, 0, .pi / 2)
            case .some("xtorus"):
                node.rotation = SCNVector4Make(0, 0, 1, .pi / 3)
            case .some("ytorus"):
                node.rotation = SCNVector4Make(0, 0, 1, .pi * 2 / 3)
            default:
                break
            }
        }
        
        allowsCameraControl = true
        showsStatistics = true
        backgroundColor = NSColor.black
        self.scene = scn
    }

    public func showWaiting() {
        guard let waitingNode = scene?.rootNode.childNode(withName: "waiting", recursively: true) else { return }
        waitingNode.isHidden = false
   
        let spin = CABasicAnimation(keyPath: "rotation")
        spin.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 1, w: 0))
        spin.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 1, w: CGFloat(2 * Double.pi)))
        spin.duration = 2.5
        spin.repeatCount = .infinity
        waitingNode.addAnimation(spin, forKey: "spin around")
    }
    
    public func hideWaiting() {
        guard let scene = self.scene else { return }
        guard let waitingNode = scene.rootNode.childNode(withName: "waiting", recursively: true) else { return }
        waitingNode.isHidden = true
        waitingNode.removeAllAnimations()
    }
    
    public func clearResultsByExecution() {
        guard let scene = self.scene else { return }
        scene.rootNode.enumerateChildNodes { (node: SCNNode, _) in
            switch node.name {
            case .some("\(0)"):
                node.isHidden = true
            case .some("\(1)"):
                node.isHidden = true
            case .some("\(2)"):
                node.isHidden = true
            case .some("\(3)"):
                node.isHidden = true
            case .some("\(4)"):
                node.isHidden = true
            default:
                break
            }
        }
    }
    
    public func showResultsByExecution(results: [String:AnyObject]) {
        
        guard let qubits = results["qubits"] as? [AnyObject] else { return }
        for index in 0..<qubits.count {
            let qbvalue = qubits[index] as! NSNumber

            guard let scene = self.scene else { return }
            scene.rootNode.enumerateChildNodes { (node: SCNNode, _) in
                switch node.name {
                case .some("\(qbvalue)"):
                    node.isHidden = false
                default:
                    break
                }
            }
        }
    }
    

}

