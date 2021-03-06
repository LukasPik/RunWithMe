//
//  ViewController.swift
//  RunWithMe
//
//  Created by Lukasz Pik on 13/12/2018.
//  Copyright © 2018 Łukasz Pik. All rights reserved.
//

import UIKit
import FirebaseAuthUI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let authUI = FUIAuth.defaultAuthUI()
        guard authUI != nil else {
            //Log the error
            return
        }
        
        authUI?.delegate = self
        let authViewController = authUI!.authViewController()
        
        present(authViewController, animated: true, completion: nil)
    }

    @IBAction func loginBtn(_ sender: UIButton) {
        
        let authUI = FUIAuth.defaultAuthUI()
        guard authUI != nil else {
            //Log the error
            return
        }
        
        authUI?.delegate = self
        let authViewController = authUI!.authViewController()
        
        present(authViewController, animated: true, completion: nil)
    }
    
}

extension ViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        guard error == nil else {
            // Log the error
            return
        }
        //AuthDataResult.user.uid
        performSegue(withIdentifier: "loginSegue", sender: self)
    }
}

extension UIViewController {
    
    func applyShadowBtn(elem: UIButton, radius: CGFloat) {
        elem.layer.cornerRadius = radius
        elem.backgroundColor = UIColor(named: "barClr")
        elem.layer.shadowColor = UIColor.darkGray.cgColor
        elem.layer.shadowRadius = 5
        elem.layer.shadowOpacity = 0.7
        elem.layer.shadowOffset = CGSize(width: 5, height: 0)
    }
    
    func applyRadiusLabel(elem: UILabel) {
        elem.layer.cornerRadius = 5
        elem.backgroundColor = UIColor.lightGray
    }
    
}

