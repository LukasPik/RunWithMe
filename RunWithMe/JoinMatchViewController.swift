//
//  JoinMatchViewController.swift
//  RunWithMe
//
//  Created by Lukasz Pik on 23/12/2018.
//  Copyright © 2018 Łukasz Pik. All rights reserved.
//

import UIKit
import FirebaseDatabase

class JoinMatchViewController: UIViewController {
    
    
    var dbRef: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        dbRef = Database.database().reference()

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
