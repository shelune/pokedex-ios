//
//  CoreDataInit.swift
//  pokedex-ios
//
//  Created by iosdev on 20.4.2016.
//  Copyright © 2016 iosdev. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataInit {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var user: NSManagedObject?
    private init() {
        let managedContext = appDelegate.managedObjectContext
        let entityUser = NSEntityDescription.entityForName("User", inManagedObjectContext: managedContext)!
        user = NSManagedObject(entity: entityUser, insertIntoManagedObjectContext: managedContext)
    }
    
    static let instance = CoreDataInit()
    
    func entityUser() -> NSManagedObject {
        return user!
    }
    
    func entityPokemon() -> NSManagedObject {
        let managedContext = appDelegate.managedObjectContext
        let entityPokemon = NSEntityDescription.entityForName("Pokemon", inManagedObjectContext: managedContext)!
        return NSManagedObject(entity: entityPokemon, insertIntoManagedObjectContext: managedContext)
    }
    
    func searchEntity(entityName: String) -> [AnyObject] {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let managedContext = appDelegate.managedObjectContext
        
        do {
            let result = try managedContext.executeFetchRequest(fetchRequest) 
            return result
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return []
    }
    
    func searchForActive() -> Int {
        let allPoke = self.searchEntity("Pokemon")
        var activeId: Int!
        
        for poke in allPoke {
            if let poke = poke as? NSManagedObject {
                if poke.valueForKey("chosen") != nil {
                    if let pokemonId = poke.valueForKey("pokedexId") as? Int {
                        return pokemonId
                    }
                }
            }
        }
        
        return 0
    }
    
    func searchForOwned() -> [Int] {
        let allPoke = self.searchEntity("Pokemon")
        var ownedIds = [Int]()
        
        for poke in allPoke {
            if let poke = poke as? NSManagedObject {
                if poke.valueForKey("owned") != nil {
                    if let pokemonId = poke.valueForKey("pokedexId") as? Int {
                        ownedIds.append(pokemonId)
                    }
                }
            }
        }
        
        return ownedIds
    }
    
    func searchForPoke(searchId: Int) -> NSManagedObject {
        let allPoke = self.searchEntity("Pokemon")
        let result = self.entityPokemon()
        
        for poke in allPoke {
            if let poke = poke as? NSManagedObject {
                if let pokemonId = poke.valueForKey("pokedexId") as? Int {
                    if pokemonId == searchId {
                        result.setValue(searchId, forKey: "pokedexId")
                        print(result)
                    }
                }
            }
        }
        
        return result
    }
    
}
