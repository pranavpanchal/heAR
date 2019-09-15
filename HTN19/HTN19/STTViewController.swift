//
//  ViewController.swift
//  HTN19
//
//  Created by Pranav Panchal on 2019-09-14.
//  Copyright © 2019 Pranav Panchal. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

extension String{
    func toDouble()-> Double?{
        return NumberFormatter().number(from:self)?.doubleValue
    }
}
class STTViewController: UIViewController {
    var label: UILabel!
    var fromMicButton: UIButton!
    
    var sub: String!
    var region: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load subscription information
        sub = "a0bf277b2c9f4b139bb755f522e41cbd"
        region = "canadacentral"
        
        label = UILabel(frame: CGRect(x: 50, y: 50, width: 200, height: 200))
        label.textColor = UIColor.black
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        
        label.text = "Recognition Result"
        
        fromMicButton = UIButton(frame: CGRect(x: 100, y: 200, width: 200, height: 50))
        fromMicButton.setTitle("Recognize", for: .normal)
        fromMicButton.addTarget(self, action:#selector(self.fromMicButtonClicked), for: .touchUpInside)
        fromMicButton.setTitleColor(UIColor.black, for: .normal)
        
        self.view.addSubview(label)
        self.view.addSubview(fromMicButton)
    }
    
    
    @objc func fromMicButtonClicked() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.recognizeFromMic()
        }
    }
    
   
    
    func recognizeFromMic() ->String {
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
            self.updateLabel(text: evt.result.text, color: .gray, emoji: nil)
        }
        
        updateLabel(text: "Listening ...", color: .gray, emoji: nil)
        print("Listening...")
        
        let result = try! reco.recognizeOnce()
        
//        Alamofire.request(urlString!).responseJSON { response in
//            print(response)
//            print(response.request)   // original url request
//            print(response.response) // http url response
//            print(response.result)  // response serialization result
//            if let json = JSON(response.result.value) {
//                print("JSON: \(json)") // serialized json response
//            }
//        }
        
        print("recognition result: \(result.text ?? "(no result)")")
        updateLabel(text: result.text, color: .black, emoji: nil)
        
        return result.text!
    }
    
    func getEmotion() {
        var text = recognizeFromMic()
        
        let originalString = "https://htn2019-253000.appspot.com/sentiment?text=\(text)"
        
        let urlString = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        var  sentimentNum :Double = 2.0
        var emotion: String = ""
        
        Alamofire.request(urlString!).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                print(swiftyJsonVar["results"]["sentiment"])
                let sentimentStr = swiftyJsonVar["results"]["sentiment"].stringValue
                print(sentimentStr)
                sentimentNum = sentimentStr.toDouble()!
                // print(sentimentNum)
                if (sentimentNum >= 0 && sentimentNum <= 0.33) {
                    emotion = "😡"
                } else if (sentimentNum >= 0.33 && sentimentNum <= 0.66) {
                    emotion = "😐"
                } else if (sentimentNum >= 0.66 && sentimentNum <= 1.0) {
                    emotion = "😀"
                } else {
                    emotion = "❓"
                }
                
                print(emotion)
            }
        }
    }
    
    func updateLabel(text: String?, color: UIColor, emoji: String?) {
        DispatchQueue.main.async {
            self.label.text = text
            self.label.textColor = color
        }
    }
}

