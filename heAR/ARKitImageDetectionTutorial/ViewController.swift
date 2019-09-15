//
//  ViewController.swift
//  ARKitImageDetectionTutorial
//
//  Created by Ivan Nesterenko on 28/5/18.
//  Copyright © 2018 Ivan Nesterenko. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation
import Vision
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, ARSCNViewDelegate,ARSessionDelegate {

    
    private var planeNode: SCNNode?
    private var imageNode: SCNNode?
    private var animationInfo: AnimationInfo?
    
    var finalText:String?
    var emotion: String = ""
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var speechText: UILabel!
    
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
        
        
        var sub: String!
        var region: String!
    


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
            speechText.text = finalText
            
            print(finalText)
        }
    
    // Set the shouldAutorotate to False
    override open var shouldAutorotate: Bool {
        return false
    }
    
    // Specify the orientation.
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
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
                var imageName: String?
                var lastImage: String?
                var temp: String?
                    let plane = SCNPlane(width:  0.2, height: 0.2)
                    plane.cornerRadius = 1.0
                    plane.firstMaterial?.transparency = 1.0
                    temp = imageName
                    imageName = self.getEmotion()
                    lastImage = temp
                if (lastImage != imageName){
                    self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                        node.removeFromParentNode()}
                    self.sceneView.session.run(ARWorldTrackingConfiguration(), options: [.resetTracking, .removeExistingAnchors])
                }
                    print(imageName)
                let background_image = UIImage(named: imageName ?? "")
                    let planeNode = SCNNode(geometry: plane)
                    planeNode.geometry?.firstMaterial?.diffuse.contents = background_image
                planeNode.position = SCNVector3(0, 0, -1)
                    //pt_textNode.addChildNode(planeNode)
                    self.sceneView.scene.rootNode.addChildNode(planeNode)
                
                if (self.faceDetectionRequest.results!.count == 0){
                    print("1")
                    self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                              node.removeFromParentNode()}
                    self.sceneView.session.run(ARWorldTrackingConfiguration(), options: [.resetTracking, .removeExistingAnchors])
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
            // load subscription information
            sub = "a0bf277b2c9f4b139bb755f522e41cbd"
            region = "canadacentral"
            
            let scene = SCNScene()
            sceneView.scene = scene
            sceneView.delegate = self
            sceneView.session.delegate = self
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.recognizeFromMic()
            }
        
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
        
       
        func recognizeFromMic() {
            var speechConfig: SPXSpeechConfiguration?
            do {
                try speechConfig = SPXSpeechConfiguration(subscription: sub, region: region)
            } catch {
                print("error \(error) happened")
                speechConfig = nil
            }
            speechConfig?.speechRecognitionLanguage = "en-US"

            let audioConfig = SPXAudioConfiguration()

            let reco = try! SPXSpeechRecognizer(speechConfiguration: speechConfig!, audioConfiguration: audioConfig!)

            reco.addRecognizingEventHandler() {reco, evt in
                print("intermediate recognition result: \(evt.result.text ?? "(no result)")")
                DispatchQueue.main.async {
                    self.finalText = evt.result.text
                }
                //self.updateLabel(text: evt.result.text, color: .gray, emoji: nil)
            }

            //updateLabel(text: "Listening ...", color: .gray, emoji: nil)
            print("Listening...")

            let result = try! reco.startContinuousRecognition()



//            print("recognition result: \(result.text ?? "(no result)")")
            //updateLabel(text: result.text, color: .black, emoji: nil)

        }

        func getEmotion() ->String {
              var text = finalText

              let originalString = "https://htn2019-253000.appspot.com/sentiment?text=\(text)"

              let urlString = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

              var  sentimentNum :Double = 2.0

              Alamofire.request(urlString!).responseJSON { (responseData) -> Void in
                  if((responseData.result.value) != nil) {
                      let swiftyJsonVar = JSON(responseData.result.value!)
                      print(swiftyJsonVar["results"]["sentiment"])
                      let sentimentStr = swiftyJsonVar["results"]["sentiment"].stringValue
                      print(sentimentStr)
                      sentimentNum = Double(sentimentStr)!
                      if (sentimentNum >= 0 && sentimentNum <= 0.143) {
                          self.emotion = "1.png"
                      } else if (sentimentNum >= 0.143 && sentimentNum <= 0.286) {
                          self.emotion = "2.png"
                      } else if (sentimentNum >= 0.286 && sentimentNum <= 0.429) {
                          self.emotion = "3.png"
                      } else if (sentimentNum >= 0.429 && sentimentNum <= 0.572) {
                        self.emotion = "4.png"
                      } else if (sentimentNum >= 0.572 && sentimentNum <= 0.715) {
                        self.emotion = "5.png"
                      } else if (sentimentNum >= 0.715 && sentimentNum <= 0.858) {
                        self.emotion = "6.png"
                      } else if (sentimentNum >= 0.858 && sentimentNum <= 1.0) {
                        self.emotion = "7.png"
                      } else {
                          self.emotion = "❓"
                      }
                  }
              }
             //print(emotion)
             return(emotion)
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


