//
//  LigandModelViewController.swift
//  swiftyProteins
//
//  Created by Yaroslava HLIBOCHKO on 7/19/19.
//  Copyright © 2019 Yaroslava HLIBOCHKO. All rights reserved.
//

import UIKit
import SceneKit

class LigandModelViewController: UIViewController {

    @IBOutlet weak var moleculeImage: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var sceneKitView: SCNView!
    var file: String = ""
    var name: String = ""
    var info: String = ""
    var myScene: MyScene?
    var atomsArray: [SCNNode] = []
    var conectsArray: [(SCNNode, Int, Int)] = []
    var hydrogenHidden: Bool?
    var camOrbit: SCNNode?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = name
        sceneKitView.scene = MyScene(file: self.file)

        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 35)
        sceneKitView.scene?.rootNode.addChildNode(cameraNode)
        sceneKitView.allowsCameraControl = true
        sceneKitView.autoenablesDefaultLighting = true
        
        myScene = sceneKitView.scene as? MyScene
        atomsArray = myScene!.atomsArray
        conectsArray = myScene!.conectsArray
        
        let nameString = getInfo("_chem_comp.name")
        var text = ""
        if nameString.isEmpty == false {
            text = "Name: " + nameString + "\n"
        }
        infoLabel.text = text + "Formula: " + getInfo("_chem_comp.formula") + "\n" + "Weight: " +  getInfo("_chem_comp.formula_weight") + "\n" + "Atoms count: \(atomsArray.count)"
        infoLabel.isHidden = true
        hydrogenHidden = false
        if let url = URL(string: "https://cdn.rcsb.org/etl/ligand/img/\(name.first!)/\(name)/\(name)-large.png") {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.moleculeImage.image = UIImage(data: data)
                }
            } else {
                print("error")
            }
        }
        moleculeImage.isHidden = true
    }
    
    @IBAction func showInfoButton(_ sender: UIButton) {
        switch infoLabel.isHidden {
        case true:
            infoLabel.isHidden = false
        default:
            infoLabel.isHidden = true
        }
    }
    @IBAction func showMoleculeImage(_ sender: Any) {
        switch moleculeImage.isHidden {
        case true:
            moleculeImage.isHidden = false
        default:
            moleculeImage.isHidden = true
        }
    }
    
    @IBAction func showHiddenHydrogens(_ sender: Any) {
        switch hydrogenHidden {
        case false:
            hydrogenHidden = true
            for isHydrogenNode in atomsArray {
                if isHydrogenNode.name == "H" {
                    isHydrogenNode.isHidden = true
                }
            }
            for isHydrogenConect in conectsArray {
                if isHydrogenConect.0.name == "conect with hydrogen" {
                    isHydrogenConect.0.isHidden = true
                }
            }
        default:
            hydrogenHidden = false
            for isHydrogen in atomsArray {
                if isHydrogen.name == "H" {
                    isHydrogen.isHidden = false
                }
            }
            for isHydrogenConect in conectsArray {
                if isHydrogenConect.0.name == "conect with hydrogen" {
                    isHydrogenConect.0.isHidden = false
                }
            }
        }
    }
    
    func getInfo (_ keyString: String) -> String {
        let splitInfo = info.split(separator: "\n")
        for subInfo in splitInfo {
            if subInfo.contains(keyString) {
                var getName = subInfo.split(separator: "\"")
                var getNameBySpaces = subInfo.split(separator: " ")
                if getName.count > 1 {
                    return "\(getName[1])"
                } else  if getNameBySpaces.count > 1 {
                    return "\(getNameBySpaces[1])"
                } else {
                    return ""
                }
            }
        }
        return ""
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation = touches.first?.location(in: sceneKitView)
        let hit = sceneKitView.hitTest(touchLocation!, options: nil)
        if hit.isEmpty == false {
            let node = hit[0].node
            if (node.name != nil) {
                
                //del me later
                var i = 0
                for nd in atomsArray {
                    if nd == node {
                        break
                    }
                    i += 1
                }
                showToast(message: "Atom \(node.name!) \(i)")
            }
        }
    }
    
    func showToast(message : String)
    {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-150, width: 150, height: 35))
        
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations:
            {
                toastLabel.alpha = 0.0
        }, completion:
            {
                (isCompleted) in
                toastLabel.removeFromSuperview()
        })
    }
    
    @IBAction func shareButton(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, true, 0.0)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let img = image {
            let shareObject = [img] as [UIImage]
            let vc = UIActivityViewController(activityItems: shareObject, applicationActivities: nil)
            vc.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            self.present(vc, animated: true, completion: nil)
        }
    }
}
