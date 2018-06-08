//
//  TextMemoPreviewViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 6/3/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit
import MaterialComponents
class TextMemoPreviewViewController: UIViewController {

    var textForMemo:String?
    var appBar = MDCAppBar()
    
    public var textMemoPreviewView: TextMemoPreviewView! {
        guard isViewLoaded else { return nil }
        return view as! TextMemoPreviewView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textMemoPreviewView.textMemoTextView.isUserInteractionEnabled = false
        
        self.title = "AfterMemo"
        
        
        self.addChildViewController(appBar.headerViewController)
      
        appBar.addSubviewsToParent()
        
        
        
        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
        
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
