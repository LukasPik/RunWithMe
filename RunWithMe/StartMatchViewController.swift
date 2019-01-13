//
//  StartMatchViewController.swift
//  RunWithMe
//
//  Created by Lukasz Pik on 23/12/2018.
//  Copyright © 2018 Łukasz Pik. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class StartMatchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {


    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var distanceSelector: UIPickerView!
    
    var pickerData: [String] = [String]()
    var dbRef: DatabaseReference!
    var id: String!
    var distance: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbRef = Database.database().reference()
        self.distanceSelector.delegate = self
        self.distanceSelector.dataSource = self
        applyShadowBtn(elem: createBtn, radius: 10)
        
        pickerData = ["100m", "200m", "500m", "1km", "2km"]
        // Do any additional setup after loading the view.
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
   /* func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }*/
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = pickerData[row]
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "textClr") ?? UIColor.white])
    }
    
    @IBAction func createMatch(_ sender: UIButton) {
        let selection = pickerData[distanceSelector.selectedRow(inComponent: 0)]
        print("Create a match for " + selection)
        if distanceSelector.selectedRow(inComponent: 0) < 3 {
            distance = Int(selection.dropLast())
        } else {
            distance = Int(selection.dropLast().dropLast()) ?? 1 * 1000
        }
        
        var creator = "Test123"
        if let user = Auth.auth().currentUser {
            creator = user.displayName ?? "Temp"
            
        }
        
        id = String(Int.random(in: 0..<100))
        dbRef.child("matches").child(id).setValue(["dist": selection, "opponent": "None", "init": 0, "creator": creator])
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let receiverVC = segue.destination as? WaitingMatchViewController {
            receiverVC.matchRef = id
            receiverVC.raceDistance = distance
        }
        
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
