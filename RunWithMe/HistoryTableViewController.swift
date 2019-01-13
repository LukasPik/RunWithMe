//
//  HistoryTableViewController.swift
//  RunWithMe
//
//  Created by Lukasz Pik on 12/01/2019.
//  Copyright © 2019 Łukasz Pik. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class HistoryTableViewController: UITableViewController {

    var dbRef: DatabaseReference!
    var matches: [Match] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbRef = Database.database().reference()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        downloadData()
    }
    
    
    func downloadData() {
        print("Downloading data .....")
        let username = Auth.auth().currentUser?.displayName ?? ""
        print(username)
        dbRef.child("history").child(username).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? NSDictionary {
                print(dict)
                for match in dict {
                    print(match.value)
                    var dist_str = String((match.value as! NSDictionary)["distance"] as! Int)
                    if dist_str.last != "0" {
                        dist_str = String(dist_str.dropLast())
                    }
                    let dist = Int(dist_str)
                    print(match.key)
                    let match_details = match.value as! NSDictionary
                    let toAdd = Match(opponent: match_details["opponent"] as! String, distance: dist ?? 0, id: match_details["result"] as! Int, creator: match_details["time"] as! String ,date: match.key as! String)
                    self.matches.append(toAdd)
                }
                self.tableView.reloadData()
            } else {
                print("nil")
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return matches.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryTableViewCell
        
        let match = matches[indexPath.row]
        if match.distance < 100 {
            cell.distanceLabel.text = String(match.distance) + " km"
        } else {
            cell.distanceLabel.text = String(match.distance) + " m"
        }
        cell.opponentLabel.text = match.opponent
        cell.dateLabel.text = match.date
        cell.timeLabel.text = match.creator
        cell.resultIndicator.progress = 1.0
        cell.resultIndicator = transformResultBar(bar: cell.resultIndicator,res: match.id)

        return cell

    }
    
    
    func transformResultBar(bar: UIProgressView, res: Int) -> UIProgressView {
        bar.layer.cornerRadius = 6.5
        bar.clipsToBounds = true
        bar.transform = bar.transform.scaledBy(x: 1.0, y: 1.2)
        if res == 0 {
            bar.progressTintColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.6)
        } else {
            bar.progressTintColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.6)
        }
        
        return bar
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

}
