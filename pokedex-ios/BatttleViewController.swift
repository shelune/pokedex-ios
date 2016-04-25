//
//  BatttleViewController.swift
//  pokedex-ios
//
//  Created by iosdev on 17.4.2016.
//  Copyright © 2016 iosdev. All rights reserved.
//

import CoreData
import UIKit

class BatttleViewController: UIViewController {
    
    // properties
    var opponentPokemon: Pokemon!
    var activePokemon: Pokemon!
    
    var opponentHP: Int!
    var opponentDefence: Int!
    var opponentAttack: Int!
    
    var activeId: Int!
    var activeHP: Int!
    var activeDefence: Int!
    var activeAttack: Int!
    
    
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
    
    override func viewWillAppear(animated: Bool) {
        opponentPokemon.downloadPokemonDetails { () -> () in
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let instance = CoreDataInit.instance
        let user = instance.entityUser()
        
        let activePokemon = instance.entityPokemon()
        let activePokemonId = instance.searchForActive()
        activePokemon.setValue(activePokemonId, forKey: "pokedexId")
        if let poke = activePokemon as? Pokemon {
            poke.downloadPokemonDetails { () -> () in
                self.activePokemon = poke
                self.updateStats()
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func updateStats() {
        opponentImg.image = UIImage(named: "\(opponentPokemon.valueForKey("pokedexId")!.integerValue)")
        //print(activePokemon.valueForKey("pokedexId"))
        print(activePokemon)
        
        if let active = activePokemon.valueForKey("pokedexId") as? Int {
            activeImg.image = UIImage(named: "\(active)")
            print(active)
        } else {
            print("NOOOOO!")
        }
        if let name = self.opponentPokemon.valueForKey("name") {
            opponentName.text = "\(name as! String)"
        }
        if let nameActive = self.activePokemon.valueForKey("name") {
            activeName.text = "\(nameActive as! String)"
        }
        
        if let attack = self.opponentPokemon.valueForKey("attack") as? String {
            opponentAtkValue.text = "\(attack)"
            opponentAttack = Int(attack)
        }
        if let attackActive = self.activePokemon.valueForKey("attack") as? String {
            activeAtkValue.text = "\(attackActive)"
            activeAttack = Int(attackActive)
        }
        
        if let defense = self.opponentPokemon.valueForKey("defense") as? String {
            opponentDefValue.text = "\(defense)"
            opponentDefence = Int(defense)
        }
        if let defenseActive = self.activePokemon.valueForKey("defense") as? String {
            activeDefValue.text = "\(defenseActive)"
            activeDefence = Int(defenseActive)
        }
        
        if let hp = self.opponentPokemon.valueForKey("hp") as? String {
            opponentHPValue.text = "\(hp)"
            opponentHP = Int(hp)
        }
        if let hpActive = self.activePokemon.valueForKey("hp") as? String {
            activeHPValue.text = "\(hpActive)"
            activeHP = Int(hpActive)
        }
    }
    func updateHealth() {
        opponentHPValue.text = "\(opponentHP)"
        activeHPValue.text = "\(activeHP)"
    }
    
    func randomizer() -> Int {
        return Int(arc4random_uniform(UInt32(15))) + 85
    }
    func hitChance() -> Int {
        return Int(arc4random_uniform(UInt32(100)))
    }
    func attackRandomizer() {
        if Int(arc4random_uniform(UInt32(100))) < 50 {
            opponentHeavyAttack()
        } else {
            opponentLightAttack()
        }
    }
    
    // MARK: Attacks
    @IBAction func lightAttack(sender: UIButton) {
        if opponentHP <= 0 {
            print("You win!")
        } else if activeHP <= 0 {
            print("You lose!")
        } else {
            activeLightAttack()
            attackRandomizer()
        }
    }
    
    @IBAction func heavyAttack(sender: UIButton) {
        if opponentHP <= 0 {
            print("You win!")
        } else if activeHP <= 0 {
            print("You lose!")
        } else {
            if hitChance() <= 75 {
                activeHeavyAttack()
            } else {
                print("You missed!")
            }
            if hitChance() <= 75 {
                attackRandomizer()
            } else {
                print("Opponent missed!")
            }
        }
    }
    
    func activeLightAttack() {
        opponentHP = opponentHP - ((((( 2 * 10 / 5 + 2) * activeAttack * 40 / opponentDefence) / 50 ) * 1 * randomizer() / 100 ) + 1 )
        updateHealth()
    }
    
    func activeHeavyAttack() {
        opponentHP = opponentHP - ((((( 2 * 10 / 5 + 2) * activeAttack * 60 / opponentDefence) / 50 ) * 1 * randomizer() / 100 ) + 1 )
        updateHealth()
    }
    
    func opponentLightAttack() {
        activeHP = activeHP - ((((( 2 * 10 / 5 + 2) * opponentAttack * 40 / activeDefence) / 50 ) * 1 * randomizer() / 100 ) + 1 )
        updateHealth()
    }
    
    func opponentHeavyAttack() {
        activeHP = activeHP - ((((( 2 * 10 / 5 + 2) * opponentAttack * 60 / activeDefence) / 50 ) * 1 * randomizer() / 100 ) + 1 )
        updateHealth()
    }
}
