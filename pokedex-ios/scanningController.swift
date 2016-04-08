//
//  scanningController.swift
//  pokedex-ios
//
//  Created by Hasse Sarin on 8.4.2016.
//  Copyright © 2016 iosdev. All rights reserved.
//

import CoreLocation
import UIKit

class scanningController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: Properties
    var locationManager: CLLocationManager!
    var foundBeacon = false
    @IBOutlet weak var detectionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScannig()
                }
            }
        }
    }
    
    func startScannig() {
        let uuid = NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "iBeamon")
        
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        print(beacons.count)
        if beacons.count > 0 {
            let beacon = beacons.first! as CLBeacon
            if beacon.proximity == CLProximity.Immediate {
                print("Detected")
                detectionLabel.text = "Detection"
            } else {
                print("Not close enough")
                detectionLabel.text = "Not close enough"
            }
        } else {
            
        }
    }
    
    func mainLoop() {
        
    }
}