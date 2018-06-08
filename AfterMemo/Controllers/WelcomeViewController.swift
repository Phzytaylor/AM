//
//  WelcomeViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 6/5/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var animatedDirectionLabel: AnimatedMaskLabel!
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       animatedDirectionLabel.didMoveToWindow()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
