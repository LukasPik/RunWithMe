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
    var raceDistance: Int!
    var opponent: String!
    var counter = 0
    var timer = Timer()

    @IBOutlet weak var waitingLabel: UILabel!
    
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
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerCall), userInfo: nil, repeats: true)
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
            if let match = val {
                if match["init"] as! Int == 1 {
                    self.opponent = match["opponent"] as? String
                    self.createAlert(title: "Opponent found", message: "Do you wanna start a match?")
                    
                }
            }
            
        }
        
    }
    
    @objc func timerCall() {
        counter = (counter + 1) % 3
        var text = "Waiting for opponent"
        for _ in 0...(counter + 1) {
            text += "."
        }
        waitingLabel.text = text
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        timer.invalidate()
        if segue.identifier == "cancelWaitingSegue" {
            dbRef.child("matches").child(matchRef!).removeValue()
        }
        if segue.identifier == "startMatchSegue" {
            let vc = segue.destination as! LocationViewController
            vc.mode = 2
            vc.match_id = Int(matchRef!) ?? 0
            vc.raceDistance = Float(raceDistance)
            vc.opponent = opponent
        }
        dbRef.removeObserver(withHandle: refHandle)
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (action) in
            print("Yes clicked")
            let match = self.dbRef.child("matches").child(self.matchRef!)
            match.updateChildValues(["init": 2])
            //tworzymy miejsce dla danych na ten mecz
            self.dbRef.child("current_matches").child(self.matchRef!).setValue(["master": ["distance" : "0", "speed": "0", "finished" : 0], "oppo": ["distance": "0", "speed": "0", "finished": 0]])
            
            self.performSegue(withIdentifier: "startMatchSegue", sender: self)
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { (action) in
            print("No clicked")
            let match = self.dbRef.child("matches").child(self.matchRef!)
            match.updateChildValues(["init": 0])
            self.performSegue(withIdentifier: "cancelWaitingSegue", sender: self)
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
