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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        opponentPokemon.downloadPokemonDetails { () -> () in
            self.updateStats()
        }
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entityPokemon = NSEntityDescription.entityForName("Pokemon", inManagedObjectContext: managedContext)
        let activePokemonNSObject = NSManagedObject(entity: entityPokemon!, insertIntoManagedObjectContext: managedContext)
        
        
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        do {
            let result = try managedContext.executeFetchRequest(fetchRequest)
            
            if let active = result[0].valueForKey("active") {
                if let pokedexId = active.valueForKey("pokedexId") as? Int {
                    activePokemonNSObject.setValue(pokedexId, forKey: "pokedexId")
                    if let poke = activePokemonNSObject as? Pokemon {
                        poke.downloadPokemonDetails { () -> () in
                            self.activePokemon = poke
                            self.updateStats()
                        }
                    }
                }
            }
        } catch {
            print("Step error")
            let fetchError = error as NSError
            print(fetchError)
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
        activeImg.image = UIImage(named: "\(activePokemon.valueForKey("pokedexId")!.integerValue)")
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
    
    func battleLoop() {
        while opponentHP > 0 {
            
        }
    }
    
    func randomizer() -> Int {
        return Int(arc4random_uniform(UInt32(15))) + 85
    }
    
    // MARK: Attacks
    func heavyAttack() {
        /*opponentHP = opponentHP -
            (((( 2 * 10 / 5 + 2) * attackPowerHere * 60 / opponentDefence) / 50 ) * 1 * randomizer() / 100 )*/
    }
    
    func lightAttack() {
        /*opponentHP = opponentHP -
            (((( 2 * 10 / 5 + 2) * attackPowerHere * 40 / opponentDefence) / 50 ) * Resistance * RandomNumber / 100 )*/
    }
}
