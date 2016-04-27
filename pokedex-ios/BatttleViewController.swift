//
//  BatttleViewController.swift
//  pokedex-ios
//
//  Created by iosdev on 17.4.2016.
//  Copyright © 2016 iosdev. All rights reserved.
//

import CoreData
import UIKit
import AVFoundation

class BatttleViewController: UIViewController {
    
    // properties
    let level = 10
    let lightPower = 40
    let heavyPower = 60
    let lightAccuracy = 100
    let heavyAccuracy = 70
    
    var opponentPokemon: Pokemon!
    var activePokemon: Pokemon!
    
    var opponentHP: Int!
    var opponentDefence: Int!
    var opponentAttack: Int!
    
    var activeId: Int!
    var activeHP: Int!
    var activeDefence: Int!
    var activeAttack: Int!
    
    var musicPlayer: AVAudioPlayer!
    
    // interaction properties
    @IBOutlet weak var opponentImg: UIImageView!
    @IBOutlet weak var opponentName: UILabel!
    @IBOutlet weak var opponentDefValue: UILabel!
    @IBOutlet weak var opponentHPValue: UILabel!
    @IBOutlet weak var opponentAtkValue: UILabel!
    
    @IBOutlet weak var activeImg: UIImageView!
    @IBOutlet weak var activeName: UILabel!
    @IBOutlet weak var activeAtkValue: UILabel!
    @IBOutlet weak var activeHPValue: UILabel!
    @IBOutlet weak var activeDefValue: UILabel!
    
    @IBOutlet weak var heavyAtkBtn: UIButton!
    @IBOutlet weak var lightAtkBtn: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        
        let instance = CoreDataInit.instance
        let user = instance.entityUser()
        let userFind = instance.searchEntity("User")
        
        // set active stats
        if let userFind = userFind as? [NSManagedObject] {
            print(userFind[0].valueForKey("active"))
            if let poke = user.valueForKey("active") as? Pokemon {
                if let pokedexId = poke.valueForKey("pokedexId") as? Int {
                    activeId = pokedexId
                }
                poke.downloadPokemonDetails { () -> () in
                    self.activePokemon = poke
                    self.updateStats(self.activePokemon)
                    
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set opponent stats
        print("opponent: \(opponentPokemon.valueForKey("pokedexId"))")
        opponentPokemon.downloadPokemonDetails { () -> () in
            self.updateStats(self.opponentPokemon)
            
            self.lightAtkBtn.userInteractionEnabled = true
            self.heavyAtkBtn.userInteractionEnabled = true
        }
        initAudio()
    }
    
    func initAudio() {
        let path = NSBundle.mainBundle().pathForResource("battle-theme", ofType: "mp3")
        do {
            musicPlayer = try AVAudioPlayer(contentsOfURL: NSURL(string: path!)!)
            musicPlayer.prepareToPlay()
            musicPlayer.numberOfLoops = -1
            musicPlayer.play()
        } catch _ as NSError {
            print("Error with Audio?")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ViewController" {
            if let dexVC = segue.destinationViewController as? ViewController {
                if let activeId = sender as? Int {
                    dexVC.activeId = activeId
                    dexVC.musicPlayer = musicPlayer
                }
            }
            //musicPlayer.stop()
        }
    }
    
    func updateStats(target: Pokemon) {
        
        if target.valueForKey("chosen") != nil {
            if let activeId = target.valueForKey("pokedexId") as? Int {
                activeImg.image = UIImage(named: "\(activeId)")
            }

            if let activePokemonName = target.valueForKey("name") as? String {
                activeName.text = activePokemonName
            }
            
            if let activePokemonAtk = target.valueForKey("attack") as? String {
                activeAtkValue.text = activePokemonAtk
                activeAttack = Int(activePokemonAtk)
            }
            
            if let activePokemonDef = target.valueForKey("defense") as? String {
                activeDefValue.text = activePokemonDef
                activeDefence = Int(activePokemonDef)
            }
            
            if let activePokemonHP = target.valueForKey("hp") as? String {
                activeHP = Int(activePokemonHP)
                activeHPValue.text = activePokemonHP
            }
        } else {
            if let opponentId = target.valueForKey("pokedexId") as? Int {
                opponentImg.image = UIImage(named: "\(opponentId)")
            }
            
            if let opponentPokemonName = target.valueForKey("name") as? String {
                opponentName.text = opponentPokemonName
            }
            
            if let opponentPokemonAtk = self.opponentPokemon.valueForKey("attack") as? String {
                opponentAtkValue.text = "\(opponentPokemonAtk)"
                opponentAttack = Int(opponentPokemonAtk)
            }
            
            if let opponentPokemonDef = self.opponentPokemon.valueForKey("defense") as? String {
                opponentDefValue.text = "\(opponentPokemonDef)"
                opponentDefence = Int(opponentPokemonDef)
            }
            
            if let opponentPokemonHp = self.opponentPokemon.valueForKey("hp") as? String {
                opponentHPValue.text = "\(opponentPokemonHp)"
                opponentHP = Int(opponentPokemonHp)
            }
        }
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
    
    @IBAction func forfeitBtnPressed(sender: UIButton) {
        // create alert
        let alert = UIAlertController(title: "Battle Is Still On!", message: "Would you like to forfeit this battle?", preferredStyle: UIAlertControllerStyle.Alert)
        
        // add actions
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Forfeit", style: UIAlertActionStyle.Cancel, handler: { action in self.forfeitConfirmed() }))
        
        // show alert
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func forfeitConfirmed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func goToCollection() {
        print(activeId)
        performSegueWithIdentifier("ViewController", sender: activeId)
    }
    
    // BATTLE SECTION
    
    func uponDefeat() {
        // create alert
        let alert = UIAlertController(title: "Defeated!", message: "You were unable to capture this iBeamon...", preferredStyle: UIAlertControllerStyle.Alert)
        
        // add actions
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: { action in self.forfeitConfirmed() }))
        
        // show alert
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func uponVictory() {
        
        let cdInstance = CoreDataInit.instance
        let user = cdInstance.entityUser()
        
        if let user = user as? User {
            user.capture(opponentPokemon.valueForKey("pokedexId")!.integerValue)
        }
        
        let alert = UIAlertController(title: "Victory!", message: "You successfully defeated and captured this iBeamon!", preferredStyle: UIAlertControllerStyle.Alert)
        
        // add actions
        alert.addAction(UIAlertAction(title: "Continue Searching", style: UIAlertActionStyle.Default, handler: { action in self.forfeitConfirmed() }))
        alert.addAction(UIAlertAction(title: "Check Collection", style: UIAlertActionStyle.Cancel, handler: { action in self.goToCollection() }))
        
        // show alert
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateHealth() {
        opponentHPValue.text = "\(opponentHP)"
        activeHPValue.text = "\(activeHP)"
    }
    
    func randomizer() -> Double {
        return Double(Int(arc4random_uniform(UInt32(15))) + 85)
    }
    func hitChance() -> Int {
        return Int(arc4random_uniform(UInt32(99))) + 1
    }
    func attackRandomizer() {
        if Int(arc4random_uniform(UInt32(100))) < 50 {
            if hitChance() <= 75 {
                opponentHeavyAttack()
            } else {
                print("Opponent missed!")
            }
        } else {
            opponentLightAttack()
        }
    }
    
    // MARK: Attacks
    @IBAction func lightAttack(sender: UIButton) {
        let activeDmg = getLightAttack(activePokemon, defender: opponentPokemon)
        let opponentDmg = getLightAttack(opponentPokemon, defender: activePokemon)
        opponentHP = opponentPokemon.takeDamage(activeDmg)
        activeHP = activePokemon.takeDamage(opponentDmg)
        updateHealth()
        
        if opponentHP <= 0 {
            print("You win!")
            uponVictory()
        } else if activeHP <= 0 {
            print("You lose!")
            uponDefeat()
        } else {
            activeLightAttack()
            attackRandomizer()
        }
        print("light opp atk . \(opponentDmg)")
        print("light active atk . \(activeDmg)")
    }
    
    @IBAction func heavyAttack(sender: UIButton) {
        let activeDmg = getHeavyAttack(activePokemon, defender: opponentPokemon)
        let opponentDmg = getHeavyAttack(opponentPokemon, defender: activePokemon)
        opponentHP = opponentPokemon.takeDamage(activeDmg)
        activeHP = activePokemon.takeDamage(opponentDmg)
        updateHealth()
        
        if opponentHP <= 0 {
            print("You win!")
            uponVictory()
        } else if activeHP <= 0 {
            print("You lose!")
            uponDefeat()
        } else {
            if hitChance() <= 75 {
                activeHeavyAttack()
            } else {
                print("You missed!")
            }
            attackRandomizer()
        }
        print("heavy opp atk . \(opponentDmg)")
        print("heavy active atk . \(activeDmg)")
    }
    
    func getMatchup(attacker: Pokemon, defender: Pokemon) -> Double {
        if let effectives = attacker.valueForKey("effectiveVersus") as? String, ineffectives = attacker.valueForKey("ineffectiveVersus") as? String {
            if let defenderType = defender.valueForKey("typeFirst") as? String {
                if (effectives.rangeOfString(defenderType) != nil) {
                    print("supereffective!")
                    return 2.0
                } else if (ineffectives.rangeOfString(defenderType) != nil) {
                    print("not very effective...")
                    return 0.5
                }
            }
        }
        return 1
    }
    
    func getLightAttack(attacker: Pokemon, defender: Pokemon) -> Int {
        
        var dmg = Double((( 2 * level / 5 + 2) * (attacker.valueForKey("attack")!.integerValue) * lightPower / (defender.valueForKey("defense")!.integerValue)) / 50)
        dmg = dmg * getMatchup(attacker, defender: defender) * randomizer() / 100 + 1
        return Int(dmg)
    }
    
    func getHeavyAttack(attacker: Pokemon, defender: Pokemon) -> Int {
        
        var dmg = Double((( 2 * level / 5 + 2) * (attacker.valueForKey("attack")!.integerValue) * heavyPower / (defender.valueForKey("defense")!.integerValue)) / 50)
        dmg = dmg * getMatchup(attacker, defender: defender) * randomizer() / 100 + 1
        return Int(dmg)

    }
}
