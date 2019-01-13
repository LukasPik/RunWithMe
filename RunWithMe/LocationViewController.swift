//
//  LocationViewController.swift
//  
//
//  Created by Lukasz Pik on 13/12/2018.
//

import UIKit
import CoreLocation
import FirebaseDatabase
import FirebaseAuth

class LocationViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var opponentLabel: UILabel!
    @IBOutlet weak var oppDistanceLabel: UILabel!
    @IBOutlet weak var oppSpeedLabel: UILabel!
    
    @IBOutlet weak var startCounterLabel: UILabel!
    
    @IBOutlet weak var oppProgressBar: UIProgressView!
    
    var mode: Int = 0
    var match_id: Int = 0
    var dbRef: DatabaseReference!
    var refHandle: UInt!
    var opponent: String!
    
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var traveledDistance: Double = 0
    var counter: Double = 0.0
    var startCounter = 3
    var timer = Timer()
    var isDistanceUpdating = false
    var raceDistance: Float = 100.0
    var is_finished = false
    
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!


    
    
    var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //progressBar.trackTintColor = UIColor.blue
        opponentLabel.text = opponent
        dbRef = Database.database().reference()
        transformProgressBar(bar: progressBar)
        transformProgressBar(bar: oppProgressBar)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("DidAppear")
        super.viewDidAppear(animated)
        
        startCounterLabel.isHidden = false
        startBtn.isHidden = true
        stopBtn.isHidden = true
        startCounterLabel.text = "3"
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(startCountingTimer), userInfo: nil, repeats: true)
        
        if raceDistance < 10 {
            raceDistance *= 1000
        }
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkCLPermission()
        
    }
    
    func checkCLPermission() {
        print("check permi")
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            print("Test start updating")
            locationManager.startUpdatingLocation()
            print("after start updating")
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .restricted {
            // Cant use location on this device
            print("Location is fucked")
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location update")
        if !isDistanceUpdating {
            return
        }
        var distanceStr: String = "0"
        // Calculating traveled distance
        if startLocation == nil {
            startLocation = locations.first
        } else if let location = locations.last {
            traveledDistance += lastLocation.distance(from: location)
            distanceStr = String(format: "%.1f", traveledDistance)
            distanceLabel.text = distanceStr + " m"
        }
        lastLocation = locations.last
        
        var speed: CLLocationSpeed? = CLLocationSpeed()
        speed = manager.location?.speed
        
        guard speed != nil else {
            return
        }
        
        let speedStr = String(format: "%.1f", speed!)
        
        if Double(speedStr) ?? 0.0 > 13.0 {
            createAlert(title: "You are moving too fast!", message: "You can't run that fast", mode: 0)
            return
        }
        
        speedLabel.text = speedStr + " m/s"
        updateTable(speed: speedStr, distance: distanceStr)
    }
    
    @objc func updateTimer() {
        counter += 0.1
        timeLabel.text = String(format:"%.1f", counter) + " s"
        let progress = Float(traveledDistance) / raceDistance
        if progress >= 1.0 {
            is_finished = true
            //endOfRace(player: 1)
        }
        progressBar.progress = progress
    }
    
    @objc func startCountingTimer() {
        if startCounter == 0 {
            timer.invalidate()
            startCounterLabel.isHidden = true
            startMatch()
            return
        }
        startCounter -= 1
        startCounterLabel.text = String(startCounter)
    }
    
    func transformProgressBar(bar: UIProgressView) {
        bar.layer.cornerRadius = 6.5
        bar.clipsToBounds = true
        bar.transform = CGAffineTransform(rotationAngle: .pi / -2)
        bar.transform = bar.transform.scaledBy(x: 1.5, y: 8)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.progress = 0.0
    }
    
    func updateTable(speed: String, distance: String) {
        var match: DatabaseReference = DatabaseReference()
        
        if mode == 2 {
            match = dbRef.child("current_matches").child(String(match_id)).child("master")
        }
        else if mode == 1 {
            match = dbRef.child("current_matches").child(String(match_id)).child("oppo")
        }
        if is_finished {
            match.updateChildValues(["distance": distance, "speed": speed, "finished": 1])
            endOfRace(player: 1)
            return
        }
        match.updateChildValues(["distance": distance, "speed": speed, "finished": 0])
    }
    
    func updateOpponent() {
        var side: String  = "oppo"
        if mode == 1 {
            side = "master"
        }
        let ref = dbRef.child("current_matches").child(String(match_id)).child(side)
        refHandle = ref.observe(.value) { (snapshot) in
            if !snapshot.exists() {
                print("Do not exists")
            }
            let val = snapshot.value as? NSDictionary
            //let text = String((val ?? 0))
            let dist = val?["distance"] as? String
            if dist == nil {
                return
            }
            self.oppSpeedLabel.text = (val?["speed"] as? String ?? "0") + " m/s"
            self.oppDistanceLabel.text = (dist ?? "0") + " m"
            let progress = Float(dist!)! / self.raceDistance
            self.oppProgressBar.progress = progress
            
            if val?["finished"] as! Int == 1 {
                self.endOfRace(player: 0)
            }
        }
    }
    
    func endOfRace(player: Int) {
        timer.invalidate()
        //locationManager.stopUpdatingLocation()
        isDistanceUpdating = false
        traveledDistance = 0.0
        counter = 0.0
        startLocation = nil
        dbRef.removeObserver(withHandle: refHandle)
        let date = Date()
        let dff = DateFormatter()
        dff.dateFormat = "yyyy-MM-dd HH:mm"
        
     
        let username = Auth.auth().currentUser?.displayName ?? ""
        if raceDistance >= 1000 {
            raceDistance /= 1000
        }
        if player == 1 {
            dbRef.child("history").child(username).child(dff.string(from: date)).setValue(["opponent": opponent, "distance": raceDistance, "result": 1, "time": timeLabel.text ?? "0s"])
            createAlert(title: "You won!", message: "Go back to menu", mode: 1)
            //dodanie wygranej do historii meczow uzytkownika

        }
        else if player == 0 {
            dbRef.child("history").child(username).child(dff.string(from: date)).setValue(["opponent": opponent, "distance": raceDistance, "result": 0, "time": timeLabel.text ?? "0s"])
            dbRef.child("current_matches").child(String(match_id)).removeValue()
            createAlert(title: "You lost :(", message: "Go back to menu", mode: 1)
            
        }
    }
    
    func startMatch() {
        isDistanceUpdating = true
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        updateOpponent()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func stopBtn(_ sender: Any) {
        timer.invalidate()
        //locationManager.stopUpdatingLocation()
        isDistanceUpdating = false
        traveledDistance = 0.0
        counter = 0.0
        startLocation = nil
        
    }
    
    @IBAction func startBtn(_ sender: Any) {
        print("Start updating locations")
        //locationManager.startUpdatingLocation()
        isDistanceUpdating = true
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        updateOpponent()
    }
    
    
    
    func createAlert(title: String, message: String, mode: Int) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            if mode == 1 {
                self.performSegue(withIdentifier: "endOfMatchSegue", sender: self)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
