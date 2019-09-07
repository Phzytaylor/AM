//
//  TextMemoPreviewViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 6/3/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import MaterialComponents
import CoreData
class TextMemoPreviewViewController: UIViewController {

    var textForMemo:String?
    var appBar = MDCAppBar()
    let memoHeaderView = GeneralHeaderView()
    
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
        
//        headerView.trackingScrollView = self.collectionView
        
        appBar.addSubviewsToParent()
        
        //appBar.headerViewController.layoutDelegate = self
        
        
    }
    var lovedOneSelected: Recipient?
    public var textMemoPreviewView: TextMemoPreviewView! {
        guard isViewLoaded else { return nil }
        return view as! TextMemoPreviewView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Written Memo Preview"
        self.textMemoPreviewView.textMemoTextView.isUserInteractionEnabled = false
        
        guard let lovedOneAvatar = lovedOneSelected?.avatar  as Data? else {return}
        
        let avatarImage = UIImage(data: lovedOneAvatar)
        textMemoPreviewView.avatarImage.translatesAutoresizingMaskIntoConstraints = false
        textMemoPreviewView.avatarImage.clipsToBounds = true
        textMemoPreviewView.avatarImage.contentMode = .scaleAspectFill
        
        textMemoPreviewView.avatarImage.image = avatarImage
        
       // self.title = "AfterMemo"
        configureAppBar()
        appBar.navigationBar.tintColor = .white
        appBar.navigationBar.titleTextColor = .white
        
//        self.addChildViewController(appBar.headerViewController)
//
//        appBar.addSubviewsToParent()
//
//
//
//        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
        
        guard let memoText = textForMemo else {return}
        
        textMemoPreviewView.textMemoTextView.text = memoText
        
        

        // Do any additional setup after loading the view.
    }
    
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
