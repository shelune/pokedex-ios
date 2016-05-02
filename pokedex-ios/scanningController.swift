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
import AVFoundation

class scanningController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: Properties
    var musicPlayer: AVAudioPlayer!
    var locationManager: CLLocationManager!
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
    }
    
    override func viewWillAppear(animated: Bool) {
        setActive()
        
        initAudio()
    }
    
    func initAudio() {
        let path = NSBundle.mainBundle().pathForResource("main-theme", ofType: "mp3")
        do {
            musicPlayer = try AVAudioPlayer(contentsOfURL: NSURL(string: path!)!)
            musicPlayer.prepareToPlay()
            musicPlayer.numberOfLoops = -1
            musicPlayer.play()
        } catch _ as NSError {
            print("Error with Audio?")
        }
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
    
    func stopScanning() {
        let uuid = NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "iBeamon")
        
        locationManager.stopMonitoringForRegion(beaconRegion)
        locationManager.stopRangingBeaconsInRegion(beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        print(beacons.count)
        if beacons.count > 0 {
            let beacon = beacons.first! as CLBeacon
            if beacon.proximity == CLProximity.Immediate {
                print("Detected")
                detectionLabel.text = "Detection"
                // create alert
                let alert = UIAlertController(title: "iBeamon detected!", message: "Would you like to forfeit this battle?", preferredStyle: UIAlertControllerStyle.Alert)
                
                // add actions
                alert.addAction(UIAlertAction(title: "Battle", style: UIAlertActionStyle.Cancel, handler: { action in self.battleTrigger() }))
                alert.addAction(UIAlertAction(title: "Ignore", style: UIAlertActionStyle.Default, handler: nil))
                
                // show alert
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                print("Not close enough")
                detectionLabel.text = "Not close enough"
            }
        } else {
            
        }
    }
    
    // set active pokemon at the footer
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
    
    func battleTrigger() {
        opponentId = Int(arc4random_uniform(UInt32(718))) + 1
        
        let cdInstance = CoreDataInit.instance
        let poke = cdInstance.entityPokemon()
        
        poke.setValue(opponentId, forKey: "pokedexId")
        
        stopScanning()
        
        performSegueWithIdentifier("BattleViewController", sender: poke)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "BattleViewController" {
            if let battleVC = segue.destinationViewController as? BatttleViewController {
                if let poke = sender as? Pokemon {
                    battleVC.opponentPokemon = poke
                }
            }
            musicPlayer.stop()
        }
        
        if segue.identifier == "ViewController" {
            if let dexVC = segue.destinationViewController as? ViewController {
                if let activeId = sender as? Int {
                    dexVC.activeId = activeId
                    dexVC.musicPlayer = musicPlayer
                }
            }
            musicPlayer.stop()
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
        let starter = instance.entityPokemon()
        starter.setValue(718, forKey: "pokedexId")
        
        // declare caught
        if let user = user as? User {
            user.capture(128)
            user.capture(111)
            user.capture(2)
            user.capture(5)
            user.capture(243)
            user.capture(244)
            user.capture(718)
        }        
        // set active & caught relationship

        user.setValue(starter, forKey: "active")
    }
    
    @IBAction func soundBtnPressed(sender: UIButton) {
        if musicPlayer.playing {
            musicPlayer.stop()
            sender.alpha = 0.2
        } else {
            musicPlayer.play()
            sender.alpha = 1.0
        }
    }
    
    @IBAction func unwindToScanner(segue: UIStoryboardSegue) {
        
    }
}