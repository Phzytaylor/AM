//
//  SettingsViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 7/30/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import FanMenu
import Macaw


class SettingsViewController: UIViewController {

    @IBOutlet var settingsView: FanMenu!
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //settingsView.backgroundColor  = .blue
        
        
        
        settingsView.button = FanMenuButton(id: "main", image: "sharp_settings_white_36pt", color: Color(val:0xADADAD))
        settingsView.items = [FanMenuButton(id: "Downloads", image:"sharp_cloud_download_white_36pt",color: Color(val: 0x9F85FF))]
        settingsView.menuRadius = 100.0
        
        settingsView.duration = 0.35
        
        settingsView.delay = 0.05
        settingsView.interval = (0, 2.0 * .pi)
        
        settingsView.menuBackground = Color.red
        
        settingsView.open()
        
        settingsView.onItemDidClick = { button in
            if button.id == "Downloads"{
                self.performSegue(withIdentifier: "toDownloads", sender: self)
            }
        }
        
       

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
        
        guard let nextVC = segue.destination as? LovedOneSelectionTableViewController else {
            return
        }
        
        nextVC.mediaSelected = "downloads"
    }


}
