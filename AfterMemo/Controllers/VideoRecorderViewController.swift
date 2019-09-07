//
//  VideoRecorderViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/18/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import AVKit
import  MobileCoreServices

class VideoRecorderViewController: UIViewController {

    var fileName = ""
    
    @IBAction func record(_ sender: Any) {
        
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

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
        if segue.identifier == "playVideo" {
            
            let nextViewCon = segue.destination as! TestViewController
            
            nextViewCon.passedURL = fileName
        }
        
        
    }
    

}

extension VideoRecorderViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        dismiss(animated: true, completion: nil)
        
        let nameFileAlert = UIAlertController(title: "File Name", message: "Create a name for your video.", preferredStyle: .alert)
        
        nameFileAlert.addTextField { (textField) -> Void in
            textField.placeholder = "enter a file name"
            textField.textAlignment = .center
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (UIAlertAction) in
            let fileToBeNamed = nameFileAlert.textFields![0] as UITextField
            
            self.fileName = fileToBeNamed.text! + ".mp4"
            
            
            guard
                let mediaType = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaType)] as? String,
                mediaType == (kUTTypeMovie as String),
                let url = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? URL
                else {
                    return
            }
            
            let videoData = try? Data(contentsOf: url )
            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            
            let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
            let dataPath =
                documentsDirectory.appendingPathComponent(self.fileName)
            do {
                let videoSaved = try videoData?.write(to: dataPath, options: [])
                DispatchQueue.main.async {
                     self.performSegue(withIdentifier: "playVIdeo", sender: self)
                }
               
            }
            catch {
                print("The video did not save")
                return
            }
            print("saved!")
            
            
            
        }
        
        nameFileAlert.addAction(saveAction)
        
        
        self.present(nameFileAlert, animated: true, completion: nil)
    }

    
}

extension VideoRecorderViewController: UINavigationControllerDelegate{}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
