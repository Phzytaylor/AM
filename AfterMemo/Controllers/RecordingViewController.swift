//
//  RecordingViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/20/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import CoreData
import AudioKit
import AudioKitUI
import MaterialComponents

class RecordingViewController: UIViewController {

    
    
    var fileName = ""
    var audioFileToBeSaved = ""
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    var selectedPerson: Recipient?
    var appBar = MDCAppBar()
    let memoHeaderView = GeneralHeaderView()
    
    func configureAppBar(){
        self.addChildViewController(appBar.headerViewController)
        appBar.navigationBar.backgroundColor = .clear
        appBar.navigationBar.title = nil
        
        let headerView = appBar.headerViewController.headerView
        headerView.backgroundColor = .clear
        headerView.maximumHeight = MemoHeaderView.Constants.maxHeight
        headerView.minimumHeight = MemoHeaderView.Constants.minHeight
        
        memoHeaderView.frame = headerView.bounds
        headerView.insertSubview(memoHeaderView, at: 0)
        
        
        
        appBar.addSubviewsToParent()
        
        //appBar.headerViewController.layoutDelegate = self
        
        
    }
    var voiceMemoToBeSent: VoiceMemos?
    
    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
    
    @IBOutlet weak var audioInputPlot: EZAudioPlot!
    
    
    
    @IBAction func recordAudio(_ sender: Any){
        
        recordTapped()
        
    }
    
    @IBOutlet weak var recordButton: UIButton!
    
    // MARK: - Properties
    
  
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func setupPlot() {
        let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = UIColor.white
        plot.backgroundColor = .black
        audioInputPlot.addSubview(plot)
    }
    
    func removePlot(){
        let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
       
        plot.clear()
        
    }
    
    
   
  @objc func saveFunction () {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
   let audio = VoiceMemos(context: managedContext)
    guard let theSelectedPerson = selectedPerson else {return}
 
    
    audio.urlPath = self.fileName
    audio.isVoiceMemo = true
    audio.isWrittenMemo = false
    audio.isVideo = false
    audio.creationDate = NSDate()
    
    voiceMemoToBeSent = audio
    
    if let audios = theSelectedPerson.voice?.mutableCopy() as?NSMutableOrderedSet {
        audios.add(audio)
        theSelectedPerson.latestMemoDate = NSDate()
        theSelectedPerson.voice = audios
    }
    
    
    
    do {
        try managedContext.save()
        
        let addAudioAtrributesAlert = UIAlertController(title: "Add Attributes", message: "Would you like to add attributes to the audio recording", preferredStyle: .alert)
        
        addAudioAtrributesAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: "voiceAttributes", sender: self)
        }))
        
        addAudioAtrributesAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        print("I saved as: \(audioFileToBeSaved)")
        DispatchQueue.main.async {
            self.present(addAudioAtrributesAlert, animated: true, completion: nil)
        }
        
        
        
      
        
    }
    catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
    }
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppBar()
        appBar.navigationBar.tintColor = .white
//        self.addChildViewController(appBar.headerViewController)
//       // self.appBar.headerViewController.headerView.trackingScrollView = self.view
//        appBar.addSubviewsToParent()
//
//        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
        
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
        
        let rightButton = UIBarButtonItem(title: "Save Memo", style: .plain, target: self, action: #selector(self.saveFunction))
        self.navigationItem.rightBarButtonItem = rightButton
        
        recordButton.isEnabled = false
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission(){[unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        //yaya
                        self.recordButton.isEnabled = true
                    } else {
                        // failed
                    }
                }
            }
        } catch {
            
            //failed
        }

        // Do any additional setup after loading the view.
    }



    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "voiceAttributes" {
            
            let nextVC = segue.destination as! VoiceMemoAtrributeViewController
            guard let theSelectedPerson = selectedPerson else {return}
            nextVC.audioURL = self.fileName
            nextVC.selectedPerson = theSelectedPerson
            nextVC.sentVoiceMemo = voiceMemoToBeSent
        }
        
        
    }
 
    @objc func updateUI() {
        
        
        
        if tracker.amplitude > 0.1 {
            
            
            var frequency = Float(tracker.frequency)
            while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
                frequency /= 2.0
            }
            while frequency < Float(noteFrequencies[0]) {
                frequency *= 2.0
            }
            
            var minDistance: Float = 10_000.0
            var index = 0
            
            for i in 0..<noteFrequencies.count {
                let distance = fabsf(Float(noteFrequencies[i]) - frequency)
                if distance < minDistance {
                    index = i
                    minDistance = distance
                }
            }
           
        }
      
    }


}
extension RecordingViewController: AVAudioRecorderDelegate {
    func startRecording() {
        // TODO: - Make sure to ask the user what they want to name the recording before actually recording!
        
        let nameTheFileAlert = UIAlertController(title: "Name the audio File", message: "Type a name for the audio file.", preferredStyle: .alert)
        
        nameTheFileAlert.addTextField { (textField) -> Void in
            textField.placeholder = "enter a file name"
            textField.textAlignment = .center
        }
        
        nameTheFileAlert.addAction(UIAlertAction(title: "Save Name", style: .default, handler: { (UIAlertAction) in
            let fileToBeNamed = nameTheFileAlert.textFields![0] as UITextField
            
            self.fileName = fileToBeNamed.text! + ".m4a"
            
            
            let audioFilename = self.getDocumentsDirectory().appendingPathComponent(self.fileName)
            
            self.audioFileToBeSaved = audioFilename.absoluteString
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 1200,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            do {
                
               
                
                self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                self.audioRecorder.delegate = self
                self.audioRecorder.record()
                //AudioKit.output = self.silence
                do {
                    try AudioKit.start()
                } catch {
                    AKLog("AudioKit did not start!")
                }
                self.setupPlot()
                Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(RecordingViewController.updateUI),
                                     userInfo: nil,
                                     repeats: true)
                
                self.recordButton.setTitle("Tap to Stop", for: .normal)
            } catch {
                self.finishRecording(success: false)
            }
        }))
        
        self.present(nameTheFileAlert,animated: true, completion: nil)
        
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
           // recordButton.isEnabled = false
            recordButton.setTitle("Done", for: .disabled)
            do {
                try AudioKit.stop()
                
            } catch {
                print("couldn't stop")
            }
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            
            // The recording failed
        }
    }
    
    @objc func recordTapped() {
        
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
            
        }
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
            print("SHOOT")
        }
        
        print("I RAN!")
        // MARK: - Reset
        //Very important to reset the mic, or the app will crash.
        mic.outputNode.removeTap(onBus: 0)
            }
    
}






















