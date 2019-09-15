//
//  ViewController.swift
//  HTN19
//
//  Created by Pranav Panchal on 2019-09-15.
//  Copyright © 2019 Pranav Panchal. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation
import Vision

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
//    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var sceneView: ARSCNView!
    //@IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var speechText: UILabel!
    //    @IBOutlet weak var speechText: UILabel!
    private var planeNode: SCNNode?
    private var imageNode: SCNNode?
    private var animationInfo: AnimationInfo?
    // The pixel buffer being held for analysis; used to serialize Vision requests.
    private var currentBuffer: CVPixelBuffer?
    //    Queue for dispatching vision classification requests
    private let visionQueue = DispatchQueue(label: "com.example.apple-samplecode.ARKitVision.serialVisionQueue")
    // Vision requests
    private var detectionRequests: [VNDetectFaceRectanglesRequest]?
    private var trackingRequests: [VNTrackObjectRequest]?
    lazy var sequenceRequestHandler = VNSequenceRequestHandler()
    var captureDevice: AVCaptureDevice?
    var captureDeviceResolution: CGSize = CGSize()
    private var bounding:CGRect?
    
    
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Do not enqueue other buffers for processing while another Vision t
        //ask is still running.
        // The camera stream has only a finite amount of buffers available; holding too many buffers for analysis would starve the camera.
        
        //case .normal = frame.camera.trackingState
        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
            return
        }
        // Retain the image buffer for Vision processing.
        self.currentBuffer = frame.capturedImage
        classifyCurrentImage()
        // here add function to accept info from the backend API
        speechText.text = "hello"
    }
    
    
    
    let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: { (request, error) in
        if error != nil {
            print("FaceDetection error: \(String(describing: error)).")
        }
        guard let faceDetectionRequest = request as? VNDetectFaceRectanglesRequest,
            let results = faceDetectionRequest.results as? [VNFaceObservation] else {
                print("results nil")
                return
        }
        if(results.count == 0){
            print("no faces")
            
        }
        else{
            print("face detected")
            // switch to listening to people speaking and start the ARSession
            // display start listening symbol on the screen
        }
    })
    
    private func classifyCurrentImage() {
        
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(UIDevice.current.orientation.rawValue))
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentBuffer!, orientation: orientation!)
        visionQueue.async {
            do {
                
                defer { self.currentBuffer = nil }
                try requestHandler.perform([self.faceDetectionRequest])
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
                return
            }
            //faceDetectionRequest.re bounding box
            //                let pt_text = SCNText(string: "gjg", extrusionDepth: 0.1)
            //                           //setting the basic properties of text
            //                pt_text.font = UIFont.systemFont(ofSize: 12)
            //                pt_text.flatness = 0.005
            //                pt_text.isWrapped = true
            //                pt_text.firstMaterial?.diffuse.contents = UIColor.white
            //               // pt_text.firstMaterial?.transparency = 0.0
            //                let pt_textNode = SCNPlane(geometry: pt_text)
            //                let fontScale: Float = 0.01
            //                pt_textNode.scale = SCNVector3(fontScale, fontScale, fontScale)
            //                pt_textNode.position = SCNVector3(0, 0, -1)
            let plane = SCNPlane(width:  0.05, height: 0.05)
            plane.cornerRadius = 1.0
            plane.firstMaterial?.transparency = 1.0
            let background_image = UIImage(named: "happy.png")
            let planeNode = SCNNode(geometry: plane)
            planeNode.geometry?.firstMaterial?.diffuse.contents = background_image
            planeNode.position = SCNVector3(0, 0, -1)
            //pt_textNode.addChildNode(planeNode)
            self.sceneView.scene.rootNode.addChildNode(planeNode)
            if (self.faceDetectionRequest.results!.count == 0){
                print("1")
                self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                    node.removeFromParentNode()}
                //self.sceneView.session.run(ARWorldTrackingConfiguration(), options: [.resetTracking, .removeExistingAnchors])
            }
            else{
                
                //speechText.text = "hello"
            }
        }
    }
    
    
    //self.setupVisionDrawingLayers()
    
    // ------- prepare to change --------------------
    
    
    // MARK: Drawing Vision Observations
    
    
    
    
    
    
    
    //-------------  AR component -------------
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.session.delegate = self
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //-----added---
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        //----close------
        
        
        
        // Load reference images to look for from "AR Resources" folder
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        // Add previously loaded images to ARScene configuration as detectionImages
        configuration.detectionImages = referenceImages
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("this being called")
        super.viewWillDisappear(animated)
        // Removing the textNode from parentNode without resetting the entire scene
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()}
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    
    
    
    
    
    
}
func centerNode(node: SCNNode) {
    let (min, max) = node.boundingBox
    let dx = min.x + 0.5 * (max.x - min.x)
    let dy = min.y + 0.5 * (max.y - min.y)
    let dz = min.z + 0.5 * (max.z - min.z)
    node.pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

fileprivate func radiansForDegrees(_ degrees: CGFloat) -> CGFloat {
    return CGFloat(Double(degrees) * Double.pi / 180.0)
}
