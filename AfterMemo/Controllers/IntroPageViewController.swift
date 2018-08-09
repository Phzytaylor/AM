//
//  IntroPageViewController.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 6/5/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import UIKit



class IntroPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, LastPageDelegate {
    func didSave(isSaved: Bool) {
        self.setViewControllers([viewControllerList[2]], direction: .forward, animated: true, completion: nil)
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllerList.index(of:viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard viewControllerList.count > previousIndex else {
            return nil
        }
        
        return viewControllerList[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllerList.index(of:viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let viewControllerListCount = viewControllerList.count
        
        guard viewControllerListCount != nextIndex else {
            return nil
        }
        
        guard viewControllerListCount > nextIndex else {
            return nil
        }
        
        return viewControllerList[nextIndex]
    }
    
    lazy var viewControllerList:[UIViewController] = {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc1 = storyBoard.instantiateViewController(withIdentifier: "welcomeView")
        let vc2 = storyBoard.instantiateViewController(withIdentifier: "nameView")
        let vc3 = storyBoard.instantiateViewController(withIdentifier: "pinScreen")
        
        return [vc1,vc2,vc3]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        guard let nameInfoVC = viewControllerList[1] as? NameInfoViewController else {return}
        nameInfoVC.lastPageDelegate = self
        
        if let firstViewController = viewControllerList.first {
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
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
