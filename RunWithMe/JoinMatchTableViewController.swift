//
//  JoinMatchTableViewController.swift
//  RunWithMe
//
//  Created by Lukasz Pik on 23/12/2018.
//  Copyright © 2018 Łukasz Pik. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class JoinMatchTableViewController: UITableViewController {
    
    var dbRef: DatabaseReference!
    var matchesNumber: Int = 0
    var matches: [Match] = [Match]()
    var refHandle: UInt!
    var match_id: Int = 0
    var distance: Int!
    var opponent: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        dbRef = Database.database().reference()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        downloadMatchData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath) as? MatchTableViewCell else {
            fatalError("Cannot initiate MatchTableViewCell")
        }

        let match = matches[indexPath.row]
        if match.distance < 100 {
            cell.distanceLabel.text = String(match.distance) + " km"
        } else {
            cell.distanceLabel.text = String(match.distance) + " m"
        }
        cell.opponentLabel.text = match.creator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected match id: " + String(matches[indexPath.row].id))
        
        let username = Auth.auth().currentUser?.displayName ?? "Oppo 1"
        let match = dbRef.child("matches").child(String(matches[indexPath.row].id))
        match.updateChildValues(["init": 1, "opponent": username])
        
        let ref = dbRef.child("matches").child(String(matches[indexPath.row].id))
        refHandle = ref.observe(.value) { (snapshot) in
            if !snapshot.exists() {
                print("Do not exists")
            }
            let val = snapshot.value as? NSDictionary
            //let text = String((val ?? 0))
            
            print("Value changed to: ")
            print(val ?? NSDictionary())
            
            print(val ?? NSDictionary())
            if let match = val {
                print("Match print " + match.descriptionInStringsFileFormat)
                if match["init"] as! Int == 2 {
                    let dist_str = match["dist"] as! String
                    if dist_str.contains("k") {
                        self.distance = Int(dist_str.dropLast().dropLast()) ?? 1 * 1000
                    } else {
                        self.distance = Int(dist_str.dropLast()) ?? 0
                    }
                    print(self.distance)
                    print("Before segue to match")
                    self.match_id = Int(snapshot.key) ?? 0
                    self.opponent = match["creator"] as? String
                    self.performSegue(withIdentifier: "joinMatchSegue", sender: self)
                } else if match["init"] as! Int == 0 {
                    self.createAlert(title: "Match canceled", message: "Another user canceled match with you.")
                    self.dbRef.removeObserver(withHandle: self.refHandle)
                }
            } else {
                self.createAlert(title: "Match canceled", message: "Another user canceled match with you.")
            }
            
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "joinMatchSegue" {
            let nextScene = segue.destination as? LocationViewController
            nextScene?.mode = 1
            nextScene?.match_id = match_id
            nextScene?.raceDistance = Float(distance)
            nextScene?.opponent = opponent
            dbRef.child("matches").child(String(match_id)).removeValue()
            dbRef.removeObserver(withHandle: refHandle)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    func downloadMatchData() {
        print("Downloading data .....")
        matches.removeAll()
        dbRef.child("matches").observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? NSDictionary {
                print(dict)
                for match in dict {
                    var dist_str = String((match.value as! NSDictionary)["dist"] as! String).dropLast()
                    if dist_str.last != "0" {
                        dist_str = dist_str.dropLast()
                    }
                    let dist = Int(dist_str)
                    print(match.key)
                    let match_details = match.value as! NSDictionary
                    let toAdd = Match(opponent: match_details["opponent"] as! String, distance: dist ?? 0, id: Int(match.key as! String) ?? 0,
                                      creator: match_details["creator"] as! String)
                    self.matches.append(toAdd)
                }
                self.matchesNumber = self.matches.count
                self.tableView.reloadData()
            } else {
                print("nil")
            }
        }
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        downloadMatchData()
        /*alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil) */
    }

}
