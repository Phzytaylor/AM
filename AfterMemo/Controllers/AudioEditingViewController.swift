//
//  AudioEditingViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 12/21/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MaterialComponents

class AudioEditingViewController: UIViewController {
    //This is passed from the recording controller
    var originalAudioFile: URL?
    //This assest is made from the url passed
    var originalAVAsset: AVAsset?
    var newAVAsset: AVAsset?
    var segueSender:Any?
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    var isPaused: Bool = false
    var tempURL: URL = URL(string: "tempFile")!
    var audioStatus: AudioStatus =  AudioStatus.Stopped
    var finalURL:URL?
    var updater : CADisplayLink! = nil
    var assetLength: Double?
    let buttonScheme = MDCButtonScheme()
 
    
    
    var outputFileURL = URL(string:"outputURL")!
    
   
    
    var recordingSession: AVAudioSession!
    let session = AVAudioSession.sharedInstance()
    

    @IBOutlet weak var timeFinderSlider: UISlider!
    
    
    @IBAction func pausedRecording(_ sender: UIButton) {
        
        audioPlayer?.pause()
    }
    @IBAction func saveEdit(_ sender: UIButton) {
        stopRecording()
         let composition = AVMutableComposition()
       let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        guard let urlAsset = originalAudioFile else {
            
            print("Nothing there")
            return
        }
        let fileURL = getURLforMemo()
        compositionAudioTrack?.append(url: urlAsset, isSecondFile: false, "0.0")
        
        let fileManger = FileManager.default
        
        do{
            try fileManger.removeItem(at: urlAsset)
        } catch let error {
            print("Could not remove: \(error)")
        }
        
        var timeRangeToRemoveStart = Double(currentTimeValue.text!)
        var timeRangeToRemoveEnd = originalAVAsset?.duration.seconds
        
        composition.removeTimeRange(CMTimeRangeFromTimeToTime(start: CMTime(seconds: timeRangeToRemoveStart ?? 0.0, preferredTimescale: 10000), end: CMTime(seconds: timeRangeToRemoveEnd ?? 0.0, preferredTimescale: 10000)))
        
        compositionAudioTrack?.append(url: getURLforMemo() as URL, isSecondFile: false,currentTimeValue.text ?? "0.0" )
        
        
        
        finalURL = getURLforExport() as URL
        
        guard let exportURL = originalAudioFile else {return}
        if let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A){
            assetExport.outputFileType = AVFileType.m4a
            assetExport.outputURL = exportURL
            assetExport.exportAsynchronously {
                
            }
        }
    
        
    }
    
    @IBOutlet weak var pauseButton: MDCButton!
    @IBOutlet weak var saveButton: MDCButton!
    @IBOutlet weak var playButton: MDCButton!
    @IBOutlet weak var editRecordingButton: MDCButton!
    @IBAction func editRecordingFunction(_ sender: Any) {
        
        record()
        
    }
    
    @IBAction func playAction(_ sender: Any) {
        
        guard let playBackFile = originalAudioFile else {
            return
        }
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: playBackFile)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            updater = CADisplayLink(target: self, selector: #selector(trackAudio))
            updater.preferredFramesPerSecond = 1
            updater.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
            
        }catch let error{print(error.localizedDescription)}
        
       
        
    }
    @IBAction func currentSelectedValue(_ sender: UISlider) {
        currentTimeValue.text = String(sender.value)
    }
    
    @IBOutlet weak var currentTimeValue: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        self.navigationController?.navigationBar.isHidden = false
        guard let urlAsset = originalAudioFile else {
            
            print("Nothing there")
            return
        }
        
        originalAVAsset = AVAsset(url: urlAsset)
        guard let assetTime = originalAVAsset?.duration.seconds else {
            return
        }
        print(originalAVAsset?.duration.seconds)
        var newThing:AVMutableComposition = AVMutableComposition(url: urlAsset)
        
    timeFinderSlider.value = 0
        timeFinderSlider.minimumValue = 0
        timeFinderSlider.maximumValue = Float(assetTime)
        assetLength = assetTime
        
        setupRecorder()
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(imageLiteralResourceName: "iStock-174765643 (2)"),
                                                                    for: .default)
        
        self.navigationController?.navigationBar.tintColor = .white
        
        buttonScheme.colorScheme = ApplicationScheme().myButtoncolorScheme
        
        MDCContainedButtonThemer.applyScheme(buttonScheme, to: playButton)
        MDCContainedButtonThemer.applyScheme(buttonScheme, to: editRecordingButton)
        MDCContainedButtonThemer.applyScheme(buttonScheme, to: saveButton)
        MDCContainedButtonThemer.applyScheme(buttonScheme, to: pauseButton)
        
        let layer = CAGradientLayer()
        layer.colors = [#colorLiteral(red: 0.04111137241, green: 0.394802928, blue: 0.5176765919, alpha: 1).cgColor, #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        layer.frame = self.view.bounds
        self.view.layer.insertSublayer(layer, at: 0)
        
        
    }
    
    @objc func trackAudio() {
       
        guard let currentTime = audioPlayer?.currentTime else {
            return
        }
        
        guard let duration = audioPlayer?.duration else {
            return
        }
        
        timeFinderSlider.value = Float(currentTime)
        currentTimeValue.text = "\(currentTime)"
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
        return input.rawValue
    }
    
    

}
extension AVMutableCompositionTrack {
    /* This function appends an audiofile to the end of a mutable compostion*/
    func append(url: URL,isSecondFile: Bool, _ selectedTime:String) {
        let newAsset = AVURLAsset(url: url)
        //This range is the range of the inputed Reording from start to finish
        //To edit the time in which a recording is added may want to mess with the range.
        let range = CMTimeRangeMake(start: CMTime.zero, duration: newAsset.duration)
        let end = timeRange.end
        if isSecondFile == true {
            if let track = newAsset.tracks(withMediaType: AVMediaType.audio).first {
                do {try insertTimeRange(range, of: track, at: CMTime(seconds: Double(selectedTime) ?? 0, preferredTimescale: 10000))} catch {
                    print("There was an error")
                }
            }
        } else {
            print(end)
            if let track = newAsset.tracks(withMediaType: AVMediaType.audio).first {
                do {try insertTimeRange(range, of: track, at: end) } catch {
                    print("there was an error")
                }
            }
        }
      
        
        
    }
}

// MARK: - AVFoundation Methods
extension AudioEditingViewController: AVAudioPlayerDelegate, AVAudioRecorderDelegate  {
    
    // MARK: Recording
    func setupRecorder() {
        let theFileURL = getURLforMemo()
        
      /*  let recordSettings = [
            AVFormatIDKey: Int(kAudioFileM4AType),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ] as [String : Any] */
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 1200,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try session.setActive(true)
            audioRecorder = try AVAudioRecorder(url: theFileURL as URL, settings: settings as [String : AnyObject])
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
        } catch let error {
            
            print("There error is: \(error.localizedDescription)")
            print("Error creating audioRecorder.")
        }
    }
    
    func record() {
        audioRecorder?.record()
        audioStatus = .Recording
        print("I am recording")
    }
    
    func stopRecording() {
        
        audioStatus = .Stopped
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    // MARK: Playback
    func  play() {
        
        audioStatus = .Playing
    }
    
    func stopPlayback() {
        
        audioStatus = .Stopped
        updater.invalidate()
    }
    
    // MARK: Delegates
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        audioStatus = .Stopped
        updater.invalidate()
    }
    // MARK: Notifications
    
    // MARK: - Helpers
    
    func getURLforMemo() -> NSURL {
        let tempDir = NSTemporaryDirectory()
        let filePath = tempDir + "/TempMemo.m4a"
        
        return NSURL.fileURL(withPath: filePath) as NSURL
    }
    
    func getURLforExport()-> NSURL {
        let tempDir = NSTemporaryDirectory()
        let filepath = tempDir + "/myFile2.m4a"
        return NSURL.fileURL(withPath: filepath) as NSURL
    }
}
