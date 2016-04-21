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
        let caught1 = instance.entityPokemon()
        caught1.setValue(4, forKey: "pokedexId")
        
        let caught2 = instance.entityPokemon()
        caught2.setValue(7, forKey: "pokedexId")
        
        let caught3 = instance.entityPokemon()
        caught3.setValue(122, forKey: "pokedexId")

        
        let caught4 = instance.entityPokemon()
        caught4.setValue(384, forKey: "pokedexId")

        
        let caught5 = instance.entityPokemon()
        caught5.setValue(151, forKey: "pokedexId")
        
        // set active & caught relationship
        starter.setValue(user, forKey: "owned")
        caught2.setValue(user, forKey: "owned")
        caught1.setValue(user, forKey: "owned")
        caught3.setValue(user, forKey: "owned")
        caught4.setValue(user, forKey: "owned")
        caught5.setValue(user, forKey: "owned")

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
}