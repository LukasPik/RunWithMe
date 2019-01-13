//
//  MenuViewController.swift
//  RunWithMe
//
//  Created by Lukasz Pik on 13/01/2019.
//  Copyright © 2019 Łukasz Pik. All rights reserved.
//

import UIKit
import FirebaseAuth

class MenuViewController: UIViewController {

    @IBOutlet weak var historyBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = Auth.auth().currentUser?.displayName
        applyShadowBtn(elem: startBtn, radius: 5.0)
        applyShadowBtn(elem: joinBtn, radius: 5.0)
        applyShadowBtn(elem: historyBtn, radius: 5.0)
        nameLabel.text = "Hello, " + (name ?? "nil")
        
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
