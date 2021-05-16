//
//  ViewController.swift
//  mySecondApp/Users/nextlab02/Desktop/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS12.2.sdk/usr/lib/libc++.tbd/Users/nextlab02/Desktop/ACRCloud-ios-sdk-1.6.1.0/ACRCloudDemoSwift/libACRCloud_IOS_SDK.a
//
//  Created by nextlab02 on 2019/6/25.
//  Copyright © 2019 Tan Shin Jie. All rights reserved.
//

import UIKit
import Foundation

var analyzedResult = SongInfo(songTitle: "",songArtist: "",playOffsetMs: 0)
var tempo: Float = 0
var gate: Bool = false

class ViewController: UIViewController {
    
    let circularPath1 = UIBezierPath(arcCenter: .zero, radius: 120, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
    let circularPath2 = UIBezierPath(arcCenter: .zero, radius: 140, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
    var pulsatingLayer1: CAShapeLayer!
    var pulsatingLayer2: CAShapeLayer!
    let colour1 = UIColor.init(red: 195/255, green: 195/255, blue: 229/145, alpha: 0.25)
    let colour2 = UIColor.init(red: 241/255, green: 240/255, blue: 255/255, alpha: 0.25)
    

    var _start = false
    var _client: ACRCloudRecognition?
    var listenButtonTapCount = 0

    // MARK: - Variables
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var playOffsetValue: UILabel!
    @IBOutlet weak var goToARButton: UIButton!
    
    @IBAction func goToARButtonTapped(_ sender: Any) {
        self._client?.stopRecordRec()
    }
    
    override func viewDidLoad() {
        pulsatingLayer2 = CAShapeLayer()
        pulsatingLayer2.path = circularPath2.cgPath
        pulsatingLayer2.fillColor = colour2.cgColor
        pulsatingLayer2.position = view.center
        pulsatingLayer2.opacity = 0.5
        
        pulsatingLayer1 = CAShapeLayer()
        pulsatingLayer1.path = circularPath1.cgPath
        pulsatingLayer1.fillColor = colour1.cgColor
        pulsatingLayer1.position = view.center
        pulsatingLayer1.opacity = 0.5


        super.viewDidLoad()
        _start = false;
        self.goToARButton.isHidden = true
        startButton.pulsate(pulse_toValue: 0.95)
        
//        self.goToARButton.startGlowing()

        let config = ACRCloudConfig();
        
        config.accessKey = "31c3018f697fb692789eaeb4042808b5";
        config.accessSecret = "CtLt3s3aXI5jixSkyWhdSZFGEBybPZptb7qpsXu8";
        config.host = "identify-cn-north-1.acrcloud.com";
        
        //if you want to identify your offline db, set the recMode to "rec_mode_local"
        config.recMode = rec_mode_remote;
        config.requestTimeout = 3;
        config.protocol = "https";
        
        /* used for local model */
        if (config.recMode == rec_mode_local || config.recMode == rec_mode_both) {
            config.homedir = Bundle.main.resourcePath!.appending("/acrcloud_local_db");
        }
        
        config.stateBlock = {[weak self] state in
            self?.handleState(state!);
        }
        config.volumeBlock = {[weak self] volume in
            //do some animations with volume
            self?.handleVolume(volume);
        };
        config.resultBlock = {[weak self] result, resType in
            self?.handleResult(result!, resType:resType);
        }
        self._client = ACRCloudRecognition(config: config);
    }
    
    func animatePulsatingLayer() {
        let animation2 = CABasicAnimation(keyPath: "transform.scale")
        animation2.toValue = 1.5
        animation2.duration = 0.8
        let animation1 = CABasicAnimation(keyPath: "transform.scale")
        animation1.toValue = 1.3
        animation1.duration = 1
//        animation.autoreverses = true
        animation1.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation1.repeatCount = Float.infinity
        animation2.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation2.repeatCount = Float.infinity
        pulsatingLayer1.add(animation1, forKey: "pulsing")
        pulsatingLayer2.add(animation2, forKey: "pulsing")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - ACRCloud
    @IBAction func startRecognition(_ sender:AnyObject) {
        listenButtonTapCount += 1
        switch listenButtonTapCount{
        case 1:
            view.layer.addSublayer(pulsatingLayer2)
            view.layer.addSublayer(pulsatingLayer1)
            self.view.bringSubviewToFront(startButton)
            animatePulsatingLayer()
            self._client?.startRecordRec();
            self.goToARButton.stopGlowing()
            self.resultLabel.text = ""
            startButton.pulsate(pulse_toValue: 1.05)
            startButton.setTitle("Listening...", for: .normal)
            self._start = true;
            if goToARButton.glowView != nil {
                print("Listening...")
                goToARButton.glowView!.stopGlowing()
            }
            goToARButton.isHidden = true
            print("Start")
        case 2:
            self.pulsatingLayer1.removeFromSuperlayer()
            self.pulsatingLayer2.removeFromSuperlayer()
            self._client?.stopRecordRec()
            startButton.pulsate(pulse_toValue: 0.95)
            startButton.setTitle("Listen", for: .normal)
            listenButtonTapCount = 0
            print("Stop")
        default:
            return
        }
    }

    @IBAction func stopRecognition(_ sender:AnyObject) {
        self._client?.stopRecordRec()
        self._start = false;
        stateLabel.isHidden = true
        startButton.isHidden = true
        stopButton.isHidden = true
        tempoLabel.isHidden = true
        playOffsetValue.isHidden = true
    }
    
    func stopListening() {
        self.pulsatingLayer1.removeFromSuperlayer()
        self.pulsatingLayer2.removeFromSuperlayer()
        self._client?.stopRecordRec()
        self.startButton.pulsate(pulse_toValue: 1)
        self.startButton.setTitle("Listen", for: .normal)
        self.listenButtonTapCount = 0
        print("Stop")
    }

    func handleResult(_ result: String, resType: ACRCloudResultType) -> Void
    {   analyzedResult = getSongInfo(result)
        listenButtonTapCount = 0
        DispatchQueue.main.async {
            print(result);
            //self._client?.stopRecordRec(); Keep recording after recognized the song
            if analyzedResult.songTitle != "" {
                self.resultLabel.fadeTransition(0.4)
                self.resultLabel.text = "\(analyzedResult.songTitle) \nBy: \(analyzedResult.songArtist)"
//                self.goToARButton.isHidden = false
                self.stopListening()
                if analyzedResult.songTitle == "Hound Dog" || analyzedResult.songTitle == "Can't Help Falling In Love" || analyzedResult.songTitle == "Can't Help Falling in Love" || analyzedResult.songTitle == "Twinkle Twinkle Little Star" || analyzedResult.songTitle == "Jingle Bells" {
                    self.goToARButton.isHidden = false
                    self.goToARButton.startGlowing()
                }
            } else {
                self.resultLabel.fadeTransition(0.4)
                self.resultLabel.text = "No results found..."
                self.goToARButton.isHidden = true
                self.stopListening()
            }
            self._start = false;
            self.playOffsetValue.text = String(analyzedResult.playOffsetMs)
            print(analyzedResult.playOffsetMs)
            gate = true
        }
        
//        if tempo == 0 {
//    makeGetCall(Endpoint: "https://api.spotify.com/v1/search?q=\(replaceSpaceWithPercentage20(analyzedResult.songTitle))&type=track", AccessToken: accessToken) { data, error in
//                let idResult = getID(data!)
//                makeGetCall(Endpoint: "https://api.spotify.com/v1/audio-features/\(idResult)", AccessToken: accessToken) { data, error in
//                    DispatchQueue.main.async {
//                        tempo = getTempo(data!)
//                        self.tempoLabel.text = String(format: "Tempo: %f", tempo)
//                }
//            }
//        }
//    }
    }
    
    func handleVolume(_ volume: Float) -> Void {
        DispatchQueue.main.async {
            return
//            self.volumeLabel.text = String(format: "Volume: %f", volume)
        }
    }
    
    func handleState(_ state: String) -> Void
    {
        DispatchQueue.main.async {
            self.stateLabel.text = String(format:"State : %@",state)
        }
    }
}

extension UIButton {

    func pulsate(pulse_toValue: Double) {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 0.95
        pulse.toValue = pulse_toValue
        pulse.autoreverses = true
        pulse.repeatCount = Float.infinity
        pulse.initialVelocity = 0.5
        pulse.damping = 1
        
        layer.add(pulse, forKey: nil)
    }
}

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}

public extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
}

import ObjectiveC
import Dispatch

private var GLOWVIEW_KEY = "GLOWVIEW"

extension UIView {
    var glowView: UIView? {
        get {
            return objc_getAssociatedObject(self, &GLOWVIEW_KEY) as? UIView
        }
        set(newGlowView) {
            objc_setAssociatedObject(self, &GLOWVIEW_KEY, newGlowView!, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func startGlowingWithColor(color:UIColor, intensity:CGFloat) {
        self.startGlowingWithColor(color: color, fromIntensity: 0.1, toIntensity: intensity, repeat: true)
    }
    
    func startGlowingWithColor(color:UIColor, fromIntensity:CGFloat, toIntensity:CGFloat, repeat shouldRepeat:Bool) {
        // If we're already glowing, don't bother
//        if self.glowView != nil {
//            print("dont bother")
//            return
//        }
        
        // The glow image is taken from the current view's appearance.
        // As a side effect, if the view's content, size or shape changes,
        // the glow won't update.
        var image:UIImage
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale); do {
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
            
            color.setFill()
            path.fill(with: .sourceAtop, alpha:1.0)
            image = UIGraphicsGetImageFromCurrentImageContext()!
        }
        
        UIGraphicsEndImageContext()
        
        // Make the glowing view itself, and position it at the same
        // point as ourself. Overlay it over ourself.
        let glowView = UIImageView(image: image)
        glowView.center = self.center
        self.superview!.insertSubview(glowView, aboveSubview:self)
        
        // We don't want to show the image, but rather a shadow created by
        // Core Animation. By setting the shadow to white and the shadow radius to
        // something large, we get a pleasing glow.
        glowView.alpha = 0
        glowView.layer.shadowColor = color.cgColor
        glowView.layer.shadowOffset = CGSize.zero
        glowView.layer.shadowRadius = 10
        glowView.layer.shadowOpacity = 1.0
        
        // Create an animation that slowly fades the glow view in and out forever.
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = fromIntensity
        animation.toValue = toIntensity
        animation.repeatCount = shouldRepeat ? .infinity : 0 // HUGE_VAL = .infinity / Thanks http://stackoverflow.com/questions/7082578/cabasicanimation-unlimited-repeat-without-huge-valf
        animation.duration = 1.0
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        glowView.layer.add(animation, forKey: "pulse")
        
        // Finally, keep a reference to this around so it can be removed later
        print("startGlowingWithColor()")
        self.glowView = glowView
    }
    
    func glowOnceAtLocation(point: CGPoint, inView view:UIView) {
        self.startGlowingWithColor(color: UIColor.white, fromIntensity: 0, toIntensity: 0.5, repeat: false)
        
        self.glowView!.center = point
        view.addSubview(self.glowView!)
        
        let delay: Double = 2 * Double(Int64(NSEC_PER_SEC))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            self.stopGlowing()
        }
    }
    
    func glowOnce() {
        self.startGlowing()
        let delay: Double = 2 * Double(Int64(NSEC_PER_SEC))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            self.stopGlowing()
        }
    }
    
    // Create a pulsing, glowing view based on this one.
    func startGlowing() {
        self.startGlowingWithColor(color: UIColor.white, intensity:0.6);
        print("startGlowing()")
    }
    
    // Stop glowing by removing the glowing view from the superview
    // and removing the association between it and this object.
    func stopGlowing() {
        self.glowView?.removeFromSuperview()
//        self.glowView = nil
        print("stopGlowing()")
    }
}

extension UIView {
    func pulse(withIntensity intensity: CGFloat, withDuration duration: Double, loop: Bool) {
        UIView.animate(withDuration: duration, delay: 0, options: [.repeat, .autoreverse,.allowUserInteraction], animations: {
            loop ? nil : UIView.setAnimationRepeatCount(1)
            self.transform = CGAffineTransform(scaleX: intensity, y: intensity)
        }) { (true) in
            self.transform = CGAffineTransform.identity
        }
    }
}

