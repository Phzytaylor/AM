//
//  LovedOneSelectionTableViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 5/28/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import CoreData
import AVKit
import AVFoundation
import MobileCoreServices
import DZNEmptyDataSet

class LovedOneSelectionTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    var mediaSelected = ""
    var fileName = ""
    var personsArray: [NSManagedObject] = []
   
    @objc func createNewLovedOne() {
        performSegue(withIdentifier: "createLovedOne", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView()
        
        let rightButton = UIBarButtonItem(title: "Add Loved One", style: .plain, target: self, action: #selector(self.createNewLovedOne))
        self.navigationItem.rightBarButtonItem = rightButton
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let recipientFetch: NSFetchRequest<Recipient> = Recipient.fetchRequest()
       
        
        do {
           personsArray = try managedContext.fetch(recipientFetch)
           
           
                
        } catch let error as NSError {
            print("Could not find videos: \(error), \(error.userInfo)")
        }

            
        }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "You haven't created any loved ones yet, but you can in just a few seconds!"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Tap Below To Add A Loved One"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "twotone_account_circle_black_48pt")
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor {
        return UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 1.0)
        
    }
    
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> NSAttributedString? {
        let str = "Tap Me To Create A Loved One"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.callout), NSAttributedStringKey.foregroundColor: UIColor.white]
        
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        /*let ac = UIAlertController(title: "Button tapped!", message: nil, preferredStyle: .alert)
         ac.addAction(UIAlertAction(title: "Hurray", style: .default))
         present(ac, animated: true)
         */
        
        performSegue(withIdentifier: "createLovedOne", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return personsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lovedOnes", for: indexPath) as! LovedOnesTableViewCell
        let lovedOne = personsArray[indexPath.row]
        guard let lovedOneImage = lovedOne.value(forKey: "avatar") as? Data else {return cell}
        guard let lovedOneName = lovedOne.value(forKey: "name") as? String else {
            return cell
        }
        
        cell.avatarImageView.image = UIImage(data: lovedOneImage)
        cell.nameLabel.text = lovedOneName

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if mediaSelected == "audio"{
            
            self.performSegue(withIdentifier: "newAudioMemo", sender: self)
            
        } else if mediaSelected == "video" {
             VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
            
        } else if mediaSelected == "written" {
            
             self.performSegue(withIdentifier: "toWrittenMemo", sender: self)
            
        } else if mediaSelected == "none" {
            self.performSegue(withIdentifier: "showMemos", sender: self)
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard  let indexPath = self.tableView.indexPathForSelectedRow else {return}
        let person = indexPath.row
        
        if segue.identifier == "newAudioMemo" {
            
            guard let desitnationVC = segue.destination as? RecordingViewController else {return}
            
            desitnationVC.selectedPerson = personsArray[person] as? Recipient
            
        } else if segue.identifier == "videoAtributes" {
            
            guard let desitnationVC = segue.destination as? VideoAtrributesViewController else {return}
            
            desitnationVC.selectedPerson = personsArray[person] as? Recipient
            
            
        } else if segue.identifier == "toWrittenMemo"{
            
            guard let desitnationVC = segue.destination as? WrittenMemoViewController else {return}
            
            desitnationVC.selectedPerson = personsArray[person] as? Recipient
            
        } else if segue.identifier == "showMemos" {
            guard let destinationVC = segue.destination as? MainCollectionViewController else {return}
            
            destinationVC.passedRecipient = personsArray[person] as? Recipient
        }
        
    }
    
    
    
    func save(url:String, _ tempFilePath: URL){
        
        
        guard let indexPath = self.tableView.indexPathForSelectedRow else {return}
        
        let cellSelected = indexPath.row
        
        
        
        var selectedPerson = personsArray[cellSelected]
        
        
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Videos", in: managedContext)!
        
        let videos = NSManagedObject(entity: entity, insertInto: managedContext)
        
        guard let savedImage = previewImageForLocalVideo(url: tempFilePath) else {
            return
        }
        let savedImageData = UIImagePNGRepresentation(savedImage) as NSData?
        videos.setValue(savedImageData, forKey: "thumbNail")
        videos.setValue(url, forKey: "urlPath")
        videos.setValue(true, forKey: "isVideo")
        videos.setValue(false, forKey: "isVoiceMemo")
        videos.setValue(false, forKey: "isWrittenMemo")
        videos.setValue(selectedPerson, forKey: "recipient")
        selectedPerson.setValue(videos, forKey: "videos")
        
        let addAtributesAlert = UIAlertController(title: "Add Now?", message: "Would you like to add detials to the video?", preferredStyle: .alert)
        
        addAtributesAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: "videoAtributes", sender: self)
        }))
        
        addAtributesAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        do {
            try managedContext.save()
            //videosArray.append(videos)
            // combinedArray.append(videos)
            //            let index = IndexPath(row: combinedArray.count - 1, section: 0)
            //            collectionView?.insertItems(at: [index])
            DispatchQueue.main.async {
                
                
                
                
                self.present(addAtributesAlert, animated: true, completion: nil)
            }
            
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    

}


extension LovedOneSelectionTableViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
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
                let mediaType = info[UIImagePickerControllerMediaType] as? String,
                mediaType == (kUTTypeMovie as String),
                let url = info[UIImagePickerControllerMediaURL] as? URL
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
                //                DispatchQueue.main.async {
                //                    self.performSegue(withIdentifier: "playVIdeo", sender: self)
                //                }
                
                self.save(url: self.fileName, dataPath)
                
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

extension LovedOneSelectionTableViewController: UINavigationControllerDelegate{}
extension LovedOneSelectionTableViewController: AVAudioPlayerDelegate {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension LovedOneSelectionTableViewController {
    func previewImageForLocalVideo(url:URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let tVal = NSValue(time: CMTimeMake(12, 1)) as! CMTime
        do {
            let imageRef = try imageGenerator.copyCGImage(at: tVal, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    
    
   

}







