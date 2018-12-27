//
//  StartMatchViewController.swift
//  RunWithMe
//
//  Created by Lukasz Pik on 23/12/2018.
//  Copyright © 2018 Łukasz Pik. All rights reserved.
//

import UIKit
import FirebaseDatabase

class StartMatchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {


    @IBOutlet weak var distanceSelector: UIPickerView!
    
    var pickerData: [String] = [String]()
    var dbRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbRef = Database.database().reference()
        self.distanceSelector.delegate = self
        self.distanceSelector.dataSource = self
        
        pickerData = ["100m", "200m", "500m", "1km", "2km"]
        // Do any additional setup after loading the view.
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    @IBAction func createMatch(_ sender: UIButton) {
        let selection = pickerData[distanceSelector.selectedRow(inComponent: 0)]
        print("Create a match for " + selection)
        
        
        dbRef.child("matches").child(String(Int.random(in: 0..<100))).setValue(selection)
        
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
