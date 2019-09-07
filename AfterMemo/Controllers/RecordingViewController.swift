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
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class RecordingViewController: UIViewController, AVAudioPlayerDelegate {

    
    @IBOutlet weak var progressView: CircularLoaderView!
    
    var fileName = ""
    var audioFileToBeSaved = ""
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    var selectedPerson: Recipient?
    var appBar = MDCAppBar()
    let memoHeaderView = GeneralHeaderView()
    var audioStorageURL = ""
    var audioTag = ""
    var releaseDate: Date = Date()
    var releaseTime: Date = Date()
    var lovedOne = ""
    var uuID = ""
    var audioOnDeviceURL = ""
    var createdDate: Date = Date()
    var lovedOneEmail = ""
    let buttonScheme = MDCButtonScheme()
    var lastTime: TimeInterval?
    var isPaused:Bool = false
    //TODO: MAKRE SURE TO IMPLEMENT THIS SO THIS VIEW CAN BE PROPERLY DISMISSED.
    var passedSender:Any?
    var audioPlayer : AVAudioPlayer?
    
    func configureAppBar(){
        self.addChild(appBar.headerViewController)
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
    
   
    
    @IBOutlet weak var resetButton: MDCButton!
    
    
    @IBAction func resetAction(_ sender: Any) {
    }
    
    @IBOutlet weak var saveButton: MDCButton!
    
    @IBAction func saveAction(_ sender: Any) {
        finishRecording(success: true)
        save()
    }
    
    
    @IBAction func recordAudio(_ sender: Any){
        recordTapped()
        
    }
    
    
    @IBOutlet weak var recordButton: MDCButton!
    
    @IBOutlet weak var elapsedTime: UILabel!
    // MARK: - Properties
    
  
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder?
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func setupPlot() {
        let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
        plot.plotType = .buffer
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = UIColor.red
        plot.backgroundColor = .clear
        
        audioInputPlot.addSubview(plot)
    }
    
    func removePlot(){
        let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
       
        plot.clear()
        
    }
    
    
   
    func saveFunction (audioTag: String, releaseDate: Date, releaseTime: Date, uuID: String) {
    
        progressView.isHidden = false
        
        guard let managedContext = selectedPerson?.managedObjectContext else {return}
    
   let audio = VoiceMemos(context: managedContext)
    guard let theSelectedPerson = selectedPerson else {return}
 
    
    audio.urlPath = self.fileName
    audio.isVoiceMemo = true
    audio.isWrittenMemo = false
    audio.isVideo = false
    audio.creationDate = NSDate()
    audio.mileStone = audioTag
    audio.dateToBeReleased = releaseDate as NSDate
    audio.releaseTime = releaseTime as NSDate
   audio.uuID = uuID
    
    //voiceMemoToBeSent = audio
    
    if let audios = theSelectedPerson.voice?.mutableCopy() as?NSMutableOrderedSet {
        audios.add(audio)
        theSelectedPerson.latestMemoDate = NSDate()
        theSelectedPerson.voice = audios
    }
    
    
    
    do {
        try managedContext.save()
        
        print(" I saved")
        
        guard let audioURL = audio.urlPath else {return}
        
        let audioFile = self.getDocumentsDirectory().appendingPathComponent(audioURL)
        
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        let uploadLink = Storage.storage().reference().child(userID).child("voiceMemos").child(audioURL + audioTag)
        
        let uploadTask = uploadLink.putFile(from: audioFile, metadata: nil) { (metadata, error) in
            if error != nil {
                print("Could not upload voice memo")
                return
            } else {
                uploadLink.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print("url not available")
                        
                        let uploadError = UIAlertController(title: "Error!", message: "The download url could not be grabbed", preferredStyle: .alert)
                        
                        uploadError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        
                        self.present(uploadError, animated: true, completion: nil)
                        
                    } else {
                        let dataBasePath = Database.database().reference().child("audioMemos").child(userID).childByAutoId()
                        
                        guard let auidoURLString = url?.absoluteString else {return}
                        
                        guard let creationDate = audio.creationDate as Date? else {return}
                        
                        let dateFormat = DateFormatter()
                        dateFormat.dateFormat = "M-d-yyyy"
                        let dateString = dateFormat.string(from: releaseDate)
                        let createdDateString = dateFormat.string(from: creationDate)
                        
                        
                        let timeFormat = DateFormatter()
                        
                        timeFormat.dateFormat = "h:mm a"
                        
                        let timeString = timeFormat.string(from: releaseTime)
                        
                        guard let lovedOneName = self.selectedPerson?.name else {return}
                        guard let lovedOneEmail = self.selectedPerson?.email else {return}
                        guard let lovedOneRelation = self.selectedPerson?.relation else {return}
                        
                        dataBasePath.updateChildValues(["audioStorageURL": auidoURLString,"audioTag": audioTag, "releaseDate": dateString, "releaseTime": timeString, "lovedOne": lovedOneName, "uuID": uuID, "audioOnDeviceURL": audioURL,"createdDate": createdDateString, "lovedOneEmail": lovedOneEmail, "relation": lovedOneRelation], withCompletionBlock: { (error, ref) in
                            if error != nil {
                                
                                let databaseError = UIAlertController(title: "Database Error", message: error?.localizedDescription, preferredStyle: .alert)
                                
                                databaseError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                
                                self.present(databaseError, animated: true, completion: nil)
                                
                                print("failed to update Database")
                                return
                            } else {
                                
                                if let memoKey = ref.key {
                                    Database.database().reference().child("users").child(userID).child("lovedOnes").child(lovedOneName).child("memos").updateChildValues([memoKey : memoKey])
                                    
                                }
                                
                                let successAlert = UIAlertController(title: "Success", message: "Your voice memo and it's attributes were uploaded successfully", preferredStyle: .alert)
                                
                                successAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (Action) in
//                                    self.performSegue(withIdentifier: "done", sender: self)
                                    if self.passedSender is VoiceMemoAtrributeViewController {
                                         //self.dismiss(animated: true, completion: nil)
                                        self.performSegue(withIdentifier: "toSelectionMenu", sender: self)
                                    } else{
                                        self.navigationController?.popToRootViewController(animated: true)
                                        
                                    }
                                }))
                                
                                self.present(successAlert, animated: true, completion: nil)
                                
                                
                            }
                        })
                        
                    }
                })
            }
        }
        uploadTask.observe(.progress) { (snapshot) in
            // Upload reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            
            self.progressView.progress = CGFloat(percentComplete)
        }
        
        
        
      
        
    }
    catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
    }
    }
    
    
    @objc func save(){
        saveFunction(audioTag: audioTag, releaseDate: releaseDate, releaseTime: releaseTime, uuID: uuID)
    }
    
    @objc func editFunction(){
        finishRecording(success: true)
        performSegue(withIdentifier: "editRecording", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
   @objc func dismissME(){
       self.dismiss(animated: true, completion: nil)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppBar()
        appBar.navigationBar.tintColor = .white
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = true
        recordButton.setTitle("Record Audio", for: .normal)
        resetButton.setTitle("Reset", for: .normal)
        saveButton.setTitle("Save", for: .normal)
        buttonScheme.colorScheme = ApplicationScheme().myButtoncolorScheme
        
        MDCContainedButtonThemer.applyScheme(buttonScheme, to: recordButton)
        MDCContainedButtonThemer.applyScheme(buttonScheme, to: resetButton)
        MDCContainedButtonThemer.applyScheme(buttonScheme, to: saveButton)
        
        

        let rightButton = UIBarButtonItem(title: "Edit Memo", style: .plain, target: self, action: #selector(self.editFunction))
        self.navigationItem.rightBarButtonItem = rightButton
        
        if self.navigationController?.viewControllers == nil {
            self.appBar.navigationBar.backItem = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(dismissME))
        }
        
       
        

        
        recordButton.isEnabled = false
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playAndRecord)), mode: .default)
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
            
            AKSettings.audioInputEnabled = true
            mic = AKMicrophone()
            tracker = AKFrequencyTracker(mic)
            silence = AKBooster(tracker, gain: 0)
        } catch {
            
            //failed
        }
        
        self.view.bringSubviewToFront(progressView)

        // Do any additional setup after loading the view.
    }



    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "voiceAttributes" {
            
            guard let nextVC = segue.destination as? VoiceMemoAtrributeViewController else {
                return
            }
            guard let theSelectedPerson = selectedPerson else {return}
            nextVC.audioURL = self.fileName
            nextVC.selectedPerson = theSelectedPerson
            nextVC.sentVoiceMemo = voiceMemoToBeSent
        }
        
        if segue.identifier == "editRecording" {
            guard let nextVC = segue.destination as? AudioEditingViewController else {return}
            
            guard let audioFileToPass:URL = self.getDocumentsDirectory().appendingPathComponent(fileName) else {return
                print("There was  no file to be sent")
            }
            print("----------")
            print(audioFileToPass)
            print("//////*****///////")
            
            nextVC.originalAudioFile = audioFileToPass
            nextVC.segueSender = sender
           
            /*Theory here: When this transition happens the audioFile needs to be in a finshed recording state then sent
             do the seguge. That way the file is written to.
            */
        }
        
        
    }
 
    @objc func updateUI() {
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        
        
        if self.audioRecorder != nil {
            var currentTime = self.audioRecorder?.currentTime
            elapsedTime.text = formatter.string(from: currentTime ?? 0)
            lastTime = currentTime
        } else {
            elapsedTime.text = formatter.string(from: lastTime ?? 0)
        }
        
        
        
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
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "M-d-yyyy"
        let dateString = dateFormat.string(from: releaseDate)

        self.fileName = lovedOne + "_" + audioTag + "_" + dateString + ".m4a"
            
            
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
                self.audioRecorder?.delegate = self
                self.audioRecorder?.record()
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
                
                
                
                self.recordButton.setTitle("Tap to Pause", for: .normal)
            } catch {
                self.finishRecording(success: false)
            }
       
        
        
        
    }
    
    func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil
        
        if success {
           // recordButton.isEnabled = false
            recordButton.setTitle("Record Audio", for: .normal)
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
        }  else if audioRecorder?.isRecording ?? true && isPaused == false {
            //finishRecording(success: true)
            audioRecorder?.pause()
            self.recordButton.setTitle("Paused", for: .normal)
            do {
                try AudioKit.stop()
                
            } catch {
                print("couldn't stop")
            }
            
        } else {
            audioRecorder?.record()
            isPaused = false
            self.recordButton.setTitle("Tap to Pause", for: .normal)
            do {
                try AudioKit.start()
                
            } catch {
                print("couldn't stop")
            }
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
