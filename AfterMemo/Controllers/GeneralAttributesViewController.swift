//
//  GeneralAttributesViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 6/13/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import Eureka
import MaterialComponents

class GeneralAttributesViewController: FormViewController {
    //TODO: - SEND Variables here for viewing
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
        
        headerView.trackingScrollView = self.tableView
        
        appBar.addSubviewsToParent()
        
        //appBar.headerViewController.layoutDelegate = self
        
        
    }
    var memoTag = ""
    var releaseDate = ""
    var releaseTime = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
                configureAppBar()
        appBar.navigationBar.tintColor = .white
        title = "Attributes"
         self.appBar.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

//        self.addChildViewController(appBar.headerViewController)
//        self.appBar.headerViewController.headerView.trackingScrollView = self.tableView
//        appBar.addSubviewsToParent()
//
//        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
        
       
        
        form +++ Section(footer: "This is only a preview")
            <<< TextRow(){ row in
                row.title = "Mile Stone"
                row.value = memoTag
                row.baseCell.isUserInteractionEnabled = false
                }
            
            <<< TextRow() { row in
                row.title = "Date To Be Released"
               row.value = releaseDate
                row.baseCell.isUserInteractionEnabled = false
                }
            <<< TextRow() { row in
                row.title = "Time To Be Released"
                row.value = releaseTime
                row.baseCell.isUserInteractionEnabled = false
                
               
        }

        // Do any additional setup after loading the view.
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension GeneralAttributesViewController{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == self.appBar.headerViewController.headerView.trackingScrollView) {
            self.appBar.headerViewController.headerView.trackingScrollDidScroll()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView == self.appBar.headerViewController.headerView.trackingScrollView) {
            self.appBar.headerViewController.headerView.trackingScrollDidEndDecelerating()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        let headerView = self.appBar.headerViewController.headerView
        if (scrollView == headerView.trackingScrollView) {
            headerView.trackingScrollDidEndDraggingWillDecelerate(decelerate)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let headerView = self.appBar.headerViewController.headerView
        if (scrollView == headerView.trackingScrollView) {
            headerView.trackingScrollWillEndDragging(withVelocity: velocity,
                                                     targetContentOffset: targetContentOffset)
        }
    }

    
}
