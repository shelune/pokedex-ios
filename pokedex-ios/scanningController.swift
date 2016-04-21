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
    var activeId = 0
    var pokemons = [NSManagedObject]()
    
    @IBOutlet weak var detectionLabel: UILabel!
    @IBOutlet weak var activePokemonBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        initUser()
        
        setActive()
    }
    
    override func viewWillAppear(animated: Bool) {
        setActive()
        print("View re appear now")
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
    
    func setActive() {
        let cdInstance = CoreDataInit.instance
        
        let allPoke = cdInstance.searchEntity("Pokemon")
        var activeId: Int!
        
        for poke in allPoke {
            if let poke = poke as? NSManagedObject {
                if poke.valueForKey("chosen") != nil {
                    if let pokemonId = poke.valueForKey("pokedexId") as? Int {
                        activeId = pokemonId
                        self.activeId = pokemonId
                    }
                }
            }
        }
        
        let activeImg = UIImage(named: "\(activeId)")
        activePokemonBtn.setBackgroundImage(activeImg, forState: .Normal)
    }
    
    @IBAction func onBattleTriggered(sender: AnyObject) {
        opponentId = Int(arc4random_uniform(UInt32(718))) + 1
        
        let cdInstance = CoreDataInit.instance
        let poke = cdInstance.entityPokemon()
        
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
        
        if segue.identifier == "ViewController" {
            if let dexVC = segue.destinationViewController as? ViewController {
                if let activeId = sender as? Int {
                    dexVC.activeId = activeId
                }
            }
        }
    }
    @IBAction func activePokemonPressed(sender: AnyObject) {
        performSegueWithIdentifier("ViewController", sender: activeId)
    }
    
    func initUser() {
        let instance = CoreDataInit.instance
        
        // declare user
        let user = instance.entityUser()
        
        // declare starter
        let bulbasaur = instance.entityPokemon()
        bulbasaur.setValue(1, forKey: "pokedexId")
        bulbasaur.setValue("Bulbasaur", forKey: "name")
        
        // declare caught
        let charmander = instance.entityPokemon()
        charmander.setValue(4, forKey: "pokedexId")
        charmander.setValue("Charmander", forKey: "name")
        
        let squirtle = instance.entityPokemon()
        squirtle.setValue(7, forKey: "pokedexId")
        squirtle.setValue("Squirtle", forKey: "name")
        
        // set active & caught relationship
        bulbasaur.setValue(user, forKey: "owned")
        squirtle.setValue(user, forKey: "owned")
        charmander.setValue(user, forKey: "owned")
        user.setValue(bulbasaur, forKey: "active")
    }
}