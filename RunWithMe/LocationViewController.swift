//
//  LocationViewController.swift
//  
//
//  Created by Lukasz Pik on 13/12/2018.
//

import UIKit
import CoreLocation

class LocationViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    /*let progressBar: UIProgressView = {
        let prgsView = UIProgressView()
        prgsView.trackTintColor = UIColor.blue
        prgsView.layer.cornerRadius = 6.5
        prgsView.clipsToBounds = true
        prgsView.transform = CGAffineTransform(rotationAngle: .pi / -2)
        prgsView.translatesAutoresizingMaskIntoConstraints = false
        return prgsView
    }()*/
    
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var traveledDistance: Double = 0
    var counter: Double = 0.0
    var timer = Timer()
    var isDistanceUpdating = false
    var raceDistance: Float = 2000.0
    
    
    var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //progressBar.trackTintColor = UIColor.blue
        progressBar.layer.cornerRadius = 6.5
        progressBar.clipsToBounds = true
        progressBar.transform = CGAffineTransform(rotationAngle: .pi / -2)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.progress = 0.0

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("DidAppear")
        super.viewDidAppear(animated)
        
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
        // Calculating traveled distance
        if startLocation == nil {
            startLocation = locations.first
        } else if let location = locations.last {
            traveledDistance += lastLocation.distance(from: location)
            distanceLabel.text = String(format: "%.1f", traveledDistance) + " m"
        }
        lastLocation = locations.last
        
        var speed: CLLocationSpeed? = CLLocationSpeed()
        speed = manager.location?.speed
        
        guard speed != nil else {
            return
        }
        
        speedLabel.text = String(format: "%.1f", speed!)
        
    }
    
    @objc func updateTimer() {
        counter += 0.1
        timeLabel.text = String(format:"%.1f", counter) + " s"
        let progress = Float(traveledDistance) / raceDistance
        progressBar.progress = progress
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
    }
}
