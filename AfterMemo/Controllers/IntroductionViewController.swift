//
//  IntroductionViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 3/4/19.
//  Copyright © 2019 Taylor Simpson. All rights reserved.
//

import UIKit

class IntroductionViewController: UIViewController {

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var RecoverButton: UIButton!
    
    @IBOutlet weak var createAccountButton: UIButton!
    
    @IBAction func recoverAccountAction(_ sender: Any) {
    }
    
    
    
    @IBAction func createAccountAction(_ sender: Any) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RecoverButton.layer.cornerRadius = 20
        RecoverButton.clipsToBounds = true
        RecoverButton.layer.borderColor = UIColor.white.cgColor
        RecoverButton.layer.borderWidth = 2
        createAccountButton.layer.cornerRadius = 20
        createAccountButton.clipsToBounds = true
        createAccountButton.layer.borderColor = UIColor.white.cgColor
        createAccountButton.layer.borderWidth = 2
        
        let hover = CABasicAnimation(keyPath: "position")
        
        hover.isAdditive = true
        hover.fromValue = NSValue(cgPoint: CGPoint.zero)
        hover.toValue = NSValue(cgPoint: CGPoint(x: 0.0, y: 25.0))
        hover.autoreverses = true
        hover.duration = 3
        hover.repeatCount = Float.infinity
        logoImage.layer.add(hover, forKey: "position")
       // self.navigationController?.setNavigationBarHidden(true, animated: true)


        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
