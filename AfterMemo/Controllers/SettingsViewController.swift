//
//  SettingsViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 7/30/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit

import Macaw
import MaterialComponents


class SettingsViewController: UIViewController {

    @IBOutlet var settingsView: FanMenu!
    
    let defaults = UserDefaults.standard
    // Screen width.
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    // Screen height.
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isHidden = false
//        if self.navigationController?.isNavigationBarHidden == true {
//
//            self.navigationController?.setNavigationBarHidden(false, animated: true)
//
//        }
    }
    
    var appBar = MDCAppBar()
    let memoHeaderView = GeneralHeaderView()
    
    func configureAppBar(){
        self.addChild(appBar.headerViewController)
        appBar.navigationBar.backgroundColor = .clear
        appBar.navigationBar.title = "Settings"
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        
        let headerView = appBar.headerViewController.headerView
        headerView.backgroundColor = .clear
        headerView.maximumHeight = MemoHeaderView.Constants.maxHeight
        headerView.minimumHeight = MemoHeaderView.Constants.minHeight
        
        memoHeaderView.frame = headerView.bounds
        headerView.insertSubview(memoHeaderView, at: 0)
        
        //headerView.trackingScrollView = self.tableView
        
        appBar.addSubviewsToParent()
        
        
        
        
                //appBar.headerViewController.layoutDelegate = self
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //settingsView.backgroundColor  = .blue
      
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(imageLiteralResourceName: "iStock-174765643 (2)"),
                                                                    for: .default)
        
        self.navigationController?.navigationBar.tintColor = .white
        
        settingsView.button = FanMenuButton(id: "myID", image: "sharp_settings_white_36pt", color: Color(val:0xADADAD))
       
//        settingsView.button = FanMenuButton(id: "main", image: "sharp_settings_white_36pt", color: Color(val:0xADADAD))
        settingsView.items = [FanMenuButton(id: "Downloads", image:"sharp_cloud_download_white_36pt",color: Color(val: 0x9F85FF)), FanMenuButton(id: "Account", image:"baseline_person_white_36pt" , color: .black)]
        settingsView.menuRadius = 100.0
        
        settingsView.duration = 0.35
        
        settingsView.delay = 0.05
        settingsView.interval = (0, 2.0 * .pi)
        
        settingsView.menuBackground = Color.red
        
        settingsView.open()
        
        settingsView.onItemDidClick = { button in
            if button.id == "Downloads"{
                self.performSegue(withIdentifier: "toDownloads", sender: self)
            } else if button.id == "Account" {
                self.navigationController?.pushViewController(AccountInfoViewController(), animated: true)
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
