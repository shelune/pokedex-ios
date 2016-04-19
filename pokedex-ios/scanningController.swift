//
//  scanningController.swift
//  pokedex-ios
//
//  Created by Hasse Sarin on 8.4.2016.
//  Copyright © 2016 iosdev. All rights reserved.
//

import CoreLocation
import UIKit
import CoreData

class scanningController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: Properties
    var locationManager: CLLocationManager!
    var foundBeacon = false
    var opponentId = 0
    
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
    
    @IBAction func onBattleTriggered(sender: AnyObject) {
        opponentId = Int(arc4random_uniform(UInt32(719)))
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entityPokemon = NSEntityDescription.entityForName("Pokemon", inManagedObjectContext: managedContext)
        let poke = NSManagedObject(entity: entityPokemon!, insertIntoManagedObjectContext: managedContext)
        
        poke.setValue(opponentId, forKey: "pokedexId")
        
        performSegueWithIdentifier("BattleViewController", sender: poke)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "BattleViewController" {
            if let battleVC = segue.destinationViewController as? BatttleViewController {
                if let poke = sender as? Pokemon {
                    battleVC.opponentPokemon = poke
                }
            }
        }
        
        /*
        if segue.identifier == "ViewController" {
            if let collectionVC = segue.destinationViewController as? ViewController {
                
            }
        }
         */
    }
    @IBAction func activePokemonPressed(sender: AnyObject) {
        performSegueWithIdentifier("ViewController", sender: nil)
    }
    
    
}