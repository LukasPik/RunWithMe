//
//  WaitingMatchViewController.swift
//  RunWithMe
//
//  Created by Lukasz Pik on 27/12/2018.
//  Copyright © 2018 Łukasz Pik. All rights reserved.
//

import UIKit
import FirebaseDatabase

class WaitingMatchViewController: UIViewController {
    
    var dbRef: DatabaseReference!
    var matchRef: String?
    var refHandle: UInt!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbRef = Database.database().reference()
        // Do any additional setup after loading the view.
        waitForOpponent()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func waitForOpponent() {
        print(matchRef ?? "Empty")
        let ref = dbRef.child("matches").child(matchRef!)
        refHandle = ref.observe(.value) { (snapshot) in
            if !snapshot.exists() {
                print("Do not exists")
            }
            let val = snapshot.value as? NSDictionary
            //let text = String((val ?? 0))
            
            print("Value changed to: ")
            print(val ?? NSDictionary())
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cancelWaitingSegue" {
            dbRef.child("matches").child(matchRef!).removeValue()
            dbRef.removeObserver(withHandle: refHandle)
        }
    }
}
