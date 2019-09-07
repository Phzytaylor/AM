//
//  OptionsViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 8/27/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {
    
    var passedPerson: Recipient?
    
    //NOTE: Filter is now done in a segment bar so now the filterbutton and lable will now function as back.

    @IBOutlet weak var newWrittenButton: UIButton!
    @IBOutlet weak var newAudioButton: UIButton!
    @IBOutlet weak var newVideoButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    
    
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var newVideoLabel: UILabel!
    @IBOutlet weak var newAudioLabel: UILabel!
    @IBOutlet weak var newTextLabel: UILabel!
    
    
    @IBOutlet weak var newVideoButtonBottomCon: NSLayoutConstraint!
    @IBOutlet weak var newAudioBottonBottomCon: NSLayoutConstraint!
    @IBOutlet weak var newWrittenMemoBottomCon: NSLayoutConstraint!
    
    @IBAction func filterAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func newVideoAction(_ sender: Any) {
        performSegue(withIdentifier: "createNewVid", sender: self)
    }
    
    
    @IBAction func newAudioAction(_ sender: Any) {
        
        performSegue(withIdentifier: "createNewVoice", sender: self)
    }
    @IBAction func newWrittenAction(_ sender: Any) {
        
        performSegue(withIdentifier: "createNewText", sender: self)
    }
    
   
    
    
    @objc func labelTapped(tapGestureRecognizer: UITapGestureRecognizer){
        print("I AM WORKING I THINK?")
        
        guard let labelTag = tapGestureRecognizer.view?.tag else {
            return
        }
        
        switch labelTag {
        case 100:
            self.dismiss(animated: true, completion: nil)
        case 101:
            performSegue(withIdentifier: "createNewVid", sender: self)
        case 102:
            performSegue(withIdentifier: "createNewVoice", sender: self)
        case 103:
            performSegue(withIdentifier: "createNewText", sender: self)
        default:
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
      
        
        newVideoButton.setImage(UIImage(imageLiteralResourceName: "outline_videocam_white_36pt"), for: .normal)
        
        //newVideoButton.backgroundColor = .red
        newVideoButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        newVideoButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        
        newAudioButton.setImage(UIImage(imageLiteralResourceName: "sharp_mic_none_white_36pt"), for: .normal)
       
        //newAudioButton.backgroundColor = .red
        newAudioButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        newAudioButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
       
        newWrittenButton.setImage(UIImage(imageLiteralResourceName: "sharp_edit_white_36pt"), for: .normal)
       
        //newWrittenButton.backgroundColor = .red
        newWrittenButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        newWrittenButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
       
        filterButton.setImage(UIImage(imageLiteralResourceName: "outline_arrow_back_ios_white_36pt"), for: .normal)
       
        //filterButton.backgroundColor = .red
        filterButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        filterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.filterLabel.text = "Back"
            self.newVideoLabel.text = "New Video Memo"
            self.newVideoButtonBottomCon.constant = -100.0
            self.newAudioLabel.text = "New Auido Memo"
            self.newAudioBottonBottomCon.constant = -100.0
            self.newTextLabel.text = "New Text Memo"
            self.newWrittenMemoBottomCon.constant = -100.0
             self.view.layoutIfNeeded()
        }, completion: nil)
        
  
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       self.filterLabel.tag = 100
        self.newVideoLabel.tag = 101
        self.newAudioLabel.tag = 102
        self.newTextLabel.tag = 103
        self.filterLabel.isUserInteractionEnabled = true
        self.newVideoLabel.isUserInteractionEnabled = true
        self.newAudioLabel.isUserInteractionEnabled = true
        self.newTextLabel.isUserInteractionEnabled = true
         let filterLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(tapGestureRecognizer:)))
        let videoLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(tapGestureRecognizer:)))
        let audioLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(tapGestureRecognizer:)))
        let textLabelTapGesture = UITapGestureRecognizer(target: self, action:#selector(labelTapped(tapGestureRecognizer:)))
        self.filterLabel.addGestureRecognizer(filterLabelTapGesture)
        self.newVideoLabel.addGestureRecognizer(videoLabelTapGesture)
        self.newAudioLabel.addGestureRecognizer(audioLabelTapGesture)
        self.newTextLabel.addGestureRecognizer(textLabelTapGesture)
        
        self.navigationController?.navigationBar.isHidden = true
       
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "createNewVid" {
            
            let destinationVC = segue.destination as! VideoAtrributesViewController
            
            destinationVC.selectedPerson = passedPerson
            destinationVC.passedSender = sender
            
            
        } else if segue.identifier == "createNewVoice" {
            let destinationVC = segue.destination as! VoiceMemoAtrributeViewController
            destinationVC.selectedPerson = passedPerson
            destinationVC.passedSender = sender
            
        } else if segue.identifier == "createNewText" {
            let destinationVC = segue.destination as! WrittenMemoViewController
            destinationVC.selectedPerson = passedPerson
            destinationVC.passedSender = sender
        }
        
    }
    

}
