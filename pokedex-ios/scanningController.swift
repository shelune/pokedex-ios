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
        
        initUser()
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
    
    func initUser() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entityUser = NSEntityDescription.entityForName("User", inManagedObjectContext: managedContext)
        let entityPokemon = NSEntityDescription.entityForName("Pokemon", inManagedObjectContext: managedContext)
        
        // declare user
        let user = NSManagedObject(entity: entityUser!, insertIntoManagedObjectContext: managedContext)
        
        // declare starter
        let bulbasaur = NSManagedObject(entity: entityPokemon!, insertIntoManagedObjectContext: managedContext)
        bulbasaur.setValue(113, forKey: "pokedexId")
        bulbasaur.setValue("Bulbasaur", forKey: "name")
        user.setValue(bulbasaur, forKey: "active")
        //activePokemonImg.image = UIImage(named: "\(bulbasaur.valueForKey("pokedexId")!.integerValue)")
        
        // declare caught?
        let charmander = NSManagedObject(entity: entityPokemon!, insertIntoManagedObjectContext: managedContext)
        charmander.setValue(4, forKey: "pokedexId")
        charmander.setValue("Charmander", forKey: "name")
        
        let squirtle = NSManagedObject(entity: entityPokemon!, insertIntoManagedObjectContext: managedContext)
        squirtle.setValue(7, forKey: "pokedexId")
        squirtle.setValue("Squirtle", forKey: "name")
        
        bulbasaur.setValue(user, forKey: "owned")
        squirtle.setValue(user, forKey: "owned")
        charmander.setValue(user, forKey: "owned")
        
        // create fetch request
        let fetchRequest = NSFetchRequest(entityName: "Pokemon")
        
        // add sort descriptor
        let sortDescriptor = NSSortDescriptor(key: "pokedexId", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // do fetch request
        do {
            let result = try managedContext.executeFetchRequest(fetchRequest)
            var ownedIds = [Int]()
            
            for managedObject in result {
                if managedObject.valueForKey("owned") != nil {
                    if let ownedId = managedObject.valueForKey("pokedexId") as? Int {
                        ownedIds.append(ownedId)
                    }
                }
            }
            
            /*pokemons = pokemons.filter({
                ownedIds.contains(($0.valueForKey("pokedexId") as! Int))
            })*/
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
}