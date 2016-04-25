//
//  User.swift
//  pokedex-ios
//
//  Created by iosdev on 8.4.2016.
//  Copyright © 2016 iosdev. All rights reserved.
//

import Foundation
import CoreData


class User: NSManagedObject {

    func capture(pokedexId: Int) {
        let cdInstance = CoreDataInit.instance
        let poke = cdInstance.entityPokemon()
        poke.setValue(pokedexId, forKey: "pokedexId")
        poke.setValue(self, forKey: "owned")
    }
}
