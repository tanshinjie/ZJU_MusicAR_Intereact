//
//  ARViewController.swift
//  mySecondApp
//
//  Created by nextlab02 on 2019/7/5.
//  Copyright © 2019 Tan Shin Jie. All rights reserved.


import UIKit
import ARKit
import SceneKit

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imagePicker = UIImagePickerController()
    
    var renderPos = SCNVector3()
    
    var startDancing: Bool = false
    var counter: Int = 0
    
    var elvisNode1 = SCNNode()
    var elvisNode2 = SCNNode()
    var santaNode1 = SCNNode()
    var santaNode2 = SCNNode()
    var renderHasNotStarted = true
    var trackerNode = SCNNode()
    var foundSurface = false
    var tapGesture = UITapGestureRecognizer()
    @IBOutlet weak var backButton: UIButton!
    
    let configuration = ARWorldTrackingConfiguration()

    @IBOutlet weak var flashView: UIView!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var closeImageButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var shadeView: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func okButtonTapped(_ sender: Any) {
        descriptionLabel.isHidden = true
        okButton.isHidden = true
        shadeView.isHidden = true
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        self.foundSurface = false
        self.renderHasNotStarted = true
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func closeImageButtonTapped(_ sender: Any) {
        self.imageView.image = nil
        self.galleryButton.isHidden = false
        self.cameraButton.isHidden = false
        self.resetButton.isHidden = false
        self.addButton.isHidden = true
        self.backButton.isHidden = false
        self.closeImageButton.isHidden = true
        configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
    }
    
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        let resetConfiguration = ARWorldTrackingConfiguration()
        resetConfiguration.planeDetection = .horizontal
        sceneView.session.run(resetConfiguration)
        sceneView.session.pause()
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        sceneView.session.run(resetConfiguration, options: [.resetTracking, .removeExistingAnchors])
        self.foundSurface = false
        self.renderHasNotStarted = true
    }
    
    @IBAction func galleryButtonTapped(_ sender: Any) {
        self.openPhotoLibrary()
    }
    @IBAction func cameraButtonTapped(_ sender: Any) {
        let image = sceneView.snapshot()
        flashAnimation()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        print(analyzedResult.songTitle)
        sceneView.delegate = self
        super.viewWillAppear(animated)
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        configureLighting()
        
    }

    override func viewDidLoad() {
        descriptionLabel.clipsToBounds = true
        super.viewDidLoad()
        self.tapGesture = UITapGestureRecognizer(target: self, action:
            #selector(ARViewController.handleTap(gestureRecognize:)))
        view.addGestureRecognizer(self.tapGesture)
    }

    
    @objc
    func handleTap(gestureRecognize: UITapGestureRecognizer) {
        
//        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
//            if node == "planeNode" {
//                print("Remove planeNode")
//                node.removeFromParentNode()
//            }
//        }
        
        
        print("handleTap()")
        
//        let tapLocation = gestureRecognize.location(in: sceneView)
//        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
//        guard let hitTestResult = hitTestResults.first else { return }
//        let translation = hitTestResult.worldTransform.translation
//        let x = translation.x
//        let y = translation.y
//        let z = translation.z
        
        if analyzedResult.songTitle == "Hound Dog" {
            print("ElvisHoundDog")
            let scene = SCNScene(named: "character.scnassets/Elvis/hounddog1.dae")
            elvisNode1 = scene!.rootNode.childNode(withName: "ElvisNode1", recursively: false)!
            elvisNode1.scale = SCNVector3Make(0.5,0.5,0.5)
            let yawn = sceneView.session.currentFrame?.camera.eulerAngles.y
            elvisNode1.eulerAngles = SCNVector3Make(0,yawn ?? 0,0)
//                    elvisNode1.position = SCNVector3(0,-1,-3)
            elvisNode1.position = renderPos
            sceneView.scene.rootNode.addChildNode(elvisNode1)
            //        sceneView.removeGestureRecognizer(self.tapGesture)
        }
        
        if analyzedResult.songTitle == "Can't Help Falling In Love" ||  analyzedResult.songTitle == "Can't Help Falling in Love" {
            print("Elvis")
            let scene = SCNScene(named: "character.scnassets/Elvis/cantstopfellinginlove.dae")
            elvisNode2 = (scene?.rootNode.childNode(withName: "ElvisNode", recursively: false)!)!
            elvisNode2.scale = SCNVector3Make(0.5,0.5,0.5)
            let yawn = sceneView.session.currentFrame?.camera.eulerAngles.y
            elvisNode2.eulerAngles = SCNVector3Make(0,yawn ?? 0,0)
    //        elvisNode.position = SCNVector3(x,y,z)
            elvisNode2.position = renderPos
            sceneView.scene.rootNode.addChildNode(elvisNode2)
    //        sceneView.removeGestureRecognizer(self.tapGesture)
        }
        
        if analyzedResult.songTitle == "Twinkle Twinkle Little Star" {
            print("Santa 1")
            let scene = SCNScene(named: "character.scnassets/Santa/Bellydancing.dae")
            santaNode1 = (scene?.rootNode.childNode(withName: "SantaNode1", recursively: false)!)!
            santaNode1.scale = SCNVector3Make(0.5,0.5,0.5)
            let yawn = sceneView.session.currentFrame?.camera.eulerAngles.y
            santaNode1.eulerAngles = SCNVector3Make(0,yawn ?? 0,0)
            //        elvisNode.position = SCNVector3(x,y,z)
            santaNode1.position = renderPos
            sceneView.scene.rootNode.addChildNode(santaNode1)
            //        sceneView.removeGestureRecognizer(self.tapGesture)
        }
        if analyzedResult.songTitle == "Jingle Bells" {
            print("Santa 2")
            let scene = SCNScene(named: "character.scnassets/Santa/HipHopDancing.dae")
            santaNode2 = (scene?.rootNode.childNode(withName: "SantaNode2", recursively: false)!)!
            santaNode2.scale = SCNVector3Make(0.5,0.5,0.5)
            let yawn = sceneView.session.currentFrame?.camera.eulerAngles.y
            santaNode2.eulerAngles = SCNVector3Make(0,yawn ?? 0,0)
            //        elvisNode.position = SCNVector3(x,y,z)
            santaNode2.position = renderPos
            sceneView.scene.rootNode.addChildNode(santaNode2)
            //        sceneView.removeGestureRecognizer(self.tapGesture)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard renderHasNotStarted else { return } // if game has started, then app will exit from this code
        
        DispatchQueue.main.async {
            guard let hitTest = self.sceneView.hitTest(CGPoint(x: self.view.frame.midX, y: self.view.frame.midY), types: [.existingPlane, .featurePoint, .estimatedHorizontalPlane]).last else { return }
            let trans = SCNMatrix4(hitTest.worldTransform)
            self.renderPos = SCNVector3Make(trans.m41,trans.m42,trans.m43)
        }
        
        if !foundSurface {
            let trackerPlane = SCNPlane(width: 0.1, height: 0.1)
            trackerPlane.firstMaterial?.diffuse.contents = UIImage(named: "trackerDuck.png")
            trackerNode = SCNNode(geometry: trackerPlane)
            trackerNode.eulerAngles.x = .pi * -0.5
            sceneView.scene.rootNode.addChildNode(trackerNode)
        }
        trackerNode.position = renderPos
        foundSurface = true
    }

    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}



// MARK:- Image
extension ARViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: - Take Screenshot Animation
    func flashAnimation() {
        self.view.bringSubviewToFront(flashView)
        flashView.alpha = 0
        flashView.isHidden = false
        
        UIView.animate(withDuration: 0.05, delay: 0.0, options: [.curveEaseOut], animations: {() -> Void in
            self.flashView.alpha = 1.0
        }, completion: {(finished: Bool) -> Void in
            self.hideFlashView()
        })
    }
    
    func hideFlashView() {
        UIView.animate(withDuration: 0.05, delay: 0.0, animations: {() -> Void in
            self.flashView.alpha = 0.0
        })
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
            self.openPhotoLibrary()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func openPhotoLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("can't open photo library")
            return
        }
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .popover
        present(imagePicker, animated: true)
        self.sceneView.session.pause()
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer { picker.dismiss(animated: true) }
        print(info)
        // get the image
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageView.image = image
            self.galleryButton.isHidden = true
            self.cameraButton.isHidden = true
            self.resetButton.isHidden = true
            self.addButton.isHidden = true
            self.backButton.isHidden = true
            self.closeImageButton.isHidden = false
        }
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}


//    var jazzdancingNode = SCNNode()
//    var unnameddanceNode = SCNNode()
//    var cancanNode = SCNNode()
//    var swingdancing2Node = SCNNode()
//    var swingdancingNode = SCNNode()
//    var bboyhiphopmoveNode = SCNNode()
//    var hiphopdancingNode = SCNNode()
//    var macarenadanceNode = SCNNode()



    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        // 2
//        let width = CGFloat(planeAnchor.extent.x)
//        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: 0.3, height: 0.3) //SCNPlane(width: width, height: height)


        //        if !foundSurface {
        //            trackerNode = SCNNode(geometry: trackerPlane)
        //            trackerNode.eulerAngles.x = .pi * -0.5
        //            sceneView.scene.rootNode.addChildNode(trackerNode)

        // 3
        let planeColor = UIColor.purple
        planeColor.withAlphaComponent(0.5)
        plane.materials.first?.diffuse.contents = planeColor

        // 4
        let planeNode = SCNNode(geometry: plane)

        // 5
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2

        // 6
        node.addChildNode(planeNode)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }

        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height

        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }

//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        guard gate else { return }
//        refreshScene()
//    }
    
//    func refreshScene() {
//        gate = false
//        print(analyzedResult.playOffsetMs)
//        if analyzedResult.playOffsetMs < 30000 || (100000 < analyzedResult.playOffsetMs && analyzedResult.playOffsetMs < 130000) {
//            bellydancingNode.isHidden = false
//            jazzdancingNode.isHidden = true
//            unnameddanceNode.isHidden = true
//            cancanNode.isHidden = false
//            swingdancingNode.isHidden = true
//            swingdancing2Node.isHidden = true
//            bboyhiphopmoveNode.isHidden = false
//            hiphopdancingNode.isHidden = true
//            macarenadanceNode.isHidden = true
//        } else if (30000 < analyzedResult.playOffsetMs && analyzedResult.playOffsetMs < 60000) || (130000 < analyzedResult.playOffsetMs && analyzedResult.playOffsetMs < 160000) {
//            bellydancingNode.isHidden = true
//            jazzdancingNode.isHidden = false
//            unnameddanceNode.isHidden = true
//            cancanNode.isHidden = true
//            swingdancingNode.isHidden = false
//            swingdancing2Node.isHidden = true
//            bboyhiphopmoveNode.isHidden = true
//            hiphopdancingNode.isHidden = false
//            macarenadanceNode.isHidden = true
//        } else if (60000 < analyzedResult.playOffsetMs && analyzedResult.playOffsetMs < 100000) || (160000 < analyzedResult.playOffsetMs ){
//            bellydancingNode.isHidden = true
//            jazzdancingNode.isHidden = true
//            unnameddanceNode.isHidden = false
//            cancanNode.isHidden = true
//            swingdancingNode.isHidden = true
//            swingdancing2Node.isHidden = false
//            bboyhiphopmoveNode.isHidden = true
//            hiphopdancingNode.isHidden = true
//            macarenadanceNode.isHidden = false
//        } else { return }
//    }




/* 22-7-2019 */
//switch counter {
//case 0:
//    let url = Bundle.main.url(forResource: "Bboy Hip Hop Move", withExtension: "dae", subdirectory: "art.scnassets/mutant/110-120 bpm")!
//    let bboyhiphopmoveNode = SCNReferenceNode(url: url)!
//    self.sceneView.scene.rootNode.addChildNode(bboyhiphopmoveNode)
//    SCNTransaction.begin()
//    bboyhiphopmoveNode.load()
//    SCNTransaction.commit()
//    bboyhiphopmoveNode.position = SCNVector3Make(0,-1.25,-3)
//    bboyhiphopmoveNode.scale = SCNVector3Make(0.01,0.01,0.01)
//    counter += 1
//case 1:
//    let url = Bundle.main.url(forResource: "Hip Hop Dancing", withExtension: "dae", subdirectory: "art.scnassets/mutant/110-120 bpm")!
//    let hiphopdancingNode = SCNReferenceNode(url: url)!
//    self.sceneView.scene.rootNode.addChildNode(hiphopdancingNode)
//    SCNTransaction.begin()
//    hiphopdancingNode.load()
//    SCNTransaction.commit()
//    hiphopdancingNode.position = SCNVector3Make(0,-1.25,-3)
//    hiphopdancingNode.scale = SCNVector3Make(0.01,0.01,0.01)
//    counter += 1
//case 2:
//    let url = Bundle.main.url(forResource: "Macarena Dance", withExtension: "dae", subdirectory: "art.scnassets/mutant/110-120 bpm")!
//    let macarenadanceNode = SCNReferenceNode(url: url)!
//    self.sceneView.scene.rootNode.addChildNode(macarenadanceNode)
//    SCNTransaction.begin()
//    macarenadanceNode.load()
//    SCNTransaction.commit()
//    macarenadanceNode.position = SCNVector3Make(0,-1.25,-3)
//    macarenadanceNode.scale = SCNVector3Make(0.01,0.01,0.01)
//    counter = 0
//default:
//    return
//}
//func playAnimation(key: String) {
//    // Add the animation to start playing it right away
//    sceneView.scene.rootNode.addAnimation(animations[key]!, forKey: key)
//}
//
//func stopAnimation(key: String) {
//    // Stop the animation with a smooth transition
//    sceneView.scene.rootNode.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
//}

/* 6-7-2019 */
//let tapGesture = UITapGestureRecognizer(target: self, action:
//    #selector(page1.handleTap(gestureRecognize:)))
//view.addGestureRecognizer(tapGesture)
//    @objc
//    func handleTap(gestureRecognize: UITapGestureRecognizer) {
//        let scene = SCNScene(named: "art.scnassets/MainScene.scn")!
//
//        let ballNode = scene.rootNode.childNode(withName:"Ball", recursively: false)
//        ballNode?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: ballNode!, options: nil))
//        //        ballNode?.physicsBody?.isAffectedByGravity = true
//        ballNode?.physicsBody?.applyForce(SCNVector3(0,-1,0), asImpulse: true)
//        ballNode!.physicsBody?.restitution = 1
//
//        let platformNode = scene.rootNode.childNode(withName:"Platform", recursively: false)
//        platformNode?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: platformNode!, options: nil))
//        platformNode!.physicsBody?.restitution = 1
//
//        // set transform of node to be 10cm in front of the camera
//        var translationPlatform = matrix_identity_float4x4
//        translationPlatform.columns.3.z = -10
//        translationPlatform.columns.3.y = -2
//        platformNode!.simdTransform = matrix_multiply(sceneView.session.currentFrame!.camera.transform, translationPlatform)
//
//        var translationBall = matrix_identity_float4x4
//        translationBall.columns.3.z = -10
//        translationBall.columns.3.y = 5
//        ballNode!.simdTransform = matrix_multiply(sceneView.session.currentFrame!.camera.transform, translationBall)
//
//        sceneView.scene = scene
//    }


//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        guard !gameHasStarted else { return } // if game has started, then app will exit from this code
//        guard let hitTest = sceneView.hitTest(CGPoint(x: view.frame.midX, y: view.frame.midY), types: [.existingPlane, .featurePoint, .estimatedHorizontalPlane]).last else { return }
//
//        let trans = SCNMatrix4(hitTest.worldTransform)
//        gamePos = SCNVector3Make(trans.m41,trans.m42,trans.m43)
//
//        if !foundSurface {
//            let trackerPlane = SCNPlane(width: 0.3, height: 0.3)
//            trackerPlane.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/trackerDuck.png")
//            trackerNode = SCNNode(geometry: trackerPlane)
//            trackerNode.eulerAngles.x = .pi * -0.5
//            sceneView.scene.rootNode.addChildNode(trackerNode)
//        }
//        trackerNode.position = gamePos
//        foundSurface = true
//    }

/* 7-7-2019 */
//func resetScene() {
//    if inputVolume > 0.35 {
//        print("Both disappear")
//        //            ballNode.isHidden = true
//        //            platformNode.isHidden = true
//
//    } else if inputVolume < 0.20 {
//        print("Ball disappear")
//        //            ballNode.isHidden = true
//    } else {
//        print("Platform disappear")
//        //            platformNode.isHidden = true
//    }
//}
//
//func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//    resetScene()
//}

/* 18-7-2019 */
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let location = touches.first!.location(in: sceneView)
//
//        // Let's test if a 3D Object was touch
//        var hitTestOptions = [SCNHitTestOption: Any]()
//        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
//
//        let hitResults: [SCNHitTestResult]  = sceneView.hitTest(location, options: hitTestOptions)
//
//        if hitResults.first != nil {
//            if(idle) {
////                print(123123123)
////                print(idle)
//                playAnimation(key: "dancing")
//            } else {
////                print(456456456)
////                print(idle)
//                stopAnimation(key: "dancing")
//            }
//            idle = !idle
//            return
//        }
//    }

/* 19-7-2019 */
//    func resetScene() {
//    if startDancing {
//        counter += 1 }
//    if counter > 1200 {
//        counter = 0
//        stopAnimation(key: "dancing")
//        startDancing = false
//        print("Dancing End")
//    }
//    if tempo > 90 && !startDancing {
//        startDancing = true
//        playAnimation(key: "dancing")
//    }
//}
//func loadAnimations () {
//    // Load the character in the idle animation
//    let idleScene = SCNScene(named: "art.scnassets/goast/idleFixed.dae")!
//
//    // This node will be parent of all the animation models
//    let node = SCNNode()
//
//    // Add all the child nodes to the parent node
//    for child in idleScene.rootNode.childNodes {
//        node.addChildNode(child)
//    }
//
//    // Set up some properties
//    node.position = SCNVector3(0, -1, -2)
//    node.scale = SCNVector3(0.2, 0.2, 0.2)
//
//    // Add the node to the scene
//    sceneView.scene.rootNode.addChildNode(node)
//
//    // Load all the DAE animations
//    loadAnimation(withKey: "dancing", sceneName: "art.scnassets/goast/sambaFixed", animationIdentifier: "sambaFixed-1")
//}
//
//func loadAnimation(withKey: String, sceneName:String, animationIdentifier:String) {
//    let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "dae")
//    let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
//
//    if let animationObject = sceneSource?.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self) {
//        // The animation will only play once
//        animationObject.repeatCount = 1
//        // To create smooth transitions between animations
//        animationObject.fadeInDuration = CGFloat(1)
//        animationObject.fadeOutDuration = CGFloat(0.5)
//
//        // Store the animation for later use
//        animations[withKey] = animationObject
//    }
//}
//    @objc func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
//        let translation = panGesture.translation(in: view)
//
//        if panGesture.state == .began {
//            originalPosition = view.center
//            currentPositionTouched = panGesture.location(in: view)
//        } else if panGesture.state == .changed {
//            view.frame.origin = CGPoint(
//                x: translation.x,
//                y: translation.y
//            )
//        } else if panGesture.state == .ended {
//            let velocity = panGesture.velocity(in: view)
//
//            if velocity.y >= 1500 {
//                UIView.animate(withDuration: 0.2
//                    , animations: {
//                        self.view.frame.origin = CGPoint(
//                            x: self.view.frame.origin.x,
//                            y: self.view.frame.size.height
//                        )
//                }, completion: { (isCompleted) in
//                    if isCompleted {
//                       self.dismiss(animated: false, completion: nil)
//                    }
//                })
//            } else {
//                UIView.animate(withDuration: 0.2, animations: {
//                    self.view.center = self.originalPosition!
//                })
//            }
//        }
//    }




//        if tempo > 90 && tempo <= 100 {
//            print("Tempo: \(tempo)")
//            let scene = SCNScene(named: "art.scnassets/mutant/90-100 bpm/90-100.scn")
//            sceneView.scene = scene!
//            bellydancingNode = sceneView.scene.rootNode.childNode(withName: "BellyDancingNode", recursively: false)!
//            jazzdancingNode = sceneView.scene.rootNode.childNode(withName: "JazzDancingNode", recursively: false)!
//            unnameddanceNode = sceneView.scene.rootNode.childNode(withName: "UnnamedDanceNode", recursively: false)!
//            bellydancingNode.position = SCNVector3Make(0,-1.25,-3)
//            bellydancingNode.scale = SCNVector3Make(0.01,0.01,0.01)
//            jazzdancingNode.position = SCNVector3Make(0,-1.25,-3)
//            jazzdancingNode.scale = SCNVector3Make(0.01,0.01,0.01)
//            unnameddanceNode.position = SCNVector3Make(0,-1.25,-3)
//            unnameddanceNode.scale = SCNVector3Make(0.01,0.01,0.01)
//        } else if tempo > 100 && tempo <= 110 {
//            print("Tempo: \(tempo)")
//            let scene = SCNScene(named: "art.scnassets/mutant/100-110 bpm/100-110.scn")
//            sceneView.scene = scene!
//            cancanNode = sceneView.scene.rootNode.childNode(withName: "CanCanNode", recursively: false)!
//            swingdancingNode = sceneView.scene.rootNode.childNode(withName: "SwingDancingNode", recursively: false)!
//            swingdancing2Node = sceneView.scene.rootNode.childNode(withName: "SwingDancing2Node", recursively: false)!
//            cancanNode.position = SCNVector3Make(0,-1.25,-3)
//            cancanNode.scale = SCNVector3Make(0.01,0.01,0.01)
//            swingdancingNode.position = SCNVector3Make(0,-1.25,-3)
//            swingdancingNode.scale = SCNVector3Make(0.01,0.01,0.01)
//            swingdancing2Node.position = SCNVector3Make(0,-1.25,-3)
//            swingdancing2Node.scale = SCNVector3Make(0.01,0.01,0.01)
//        } else if tempo > 110 && tempo < 120 {
//            print("Tempo: \(tempo)")
//            let scene = SCNScene(named: "art.scnassets/mutant/110-120 bpm/110-120.scn")
//            sceneView.scene = scene!
//            bboyhiphopmoveNode = sceneView.scene.rootNode.childNode(withName: "BboyHipHopMoveNode", recursively: false)!
//            hiphopdancingNode = sceneView.scene.rootNode.childNode(withName: "HipHopDancingNode", recursively: false)!
//            macarenadanceNode = sceneView.scene.rootNode.childNode(withName: "MacarenaDanceNode", recursively: false)!
//            bboyhiphopmoveNode.position = SCNVector3Make(0,-1.25,-3)
//            bboyhiphopmoveNode.scale = SCNVector3Make(0.01,0.01,0.01)
//            hiphopdancingNode.position = SCNVector3Make(0,-1.25,-3)
//            hiphopdancingNode.scale = SCNVector3Make(0.01,0.01,0.01)
//            macarenadanceNode.position = SCNVector3Make(0,-1.25,-3)
//            macarenadanceNode.scale = SCNVector3Make(0.01,0.01,0.01)
//        } else {
//            print("Tempo out of range")
//        }

