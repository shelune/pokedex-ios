//
//  Pokemon+CoreDataProperties.swift
//  pokedex-ios
//
//  Created by iosdev on 11.4.2016.
//  Copyright © 2016 iosdev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pokemon {

    @NSManaged var attack: String?
    @NSManaged var defense: String?
    @NSManaged var descriptionText: String?
    @NSManaged var height: String?
    @NSManaged var hp: String?
    @NSManaged var name: String?
    @NSManaged var nextEvoText: String?
    @NSManaged var pokedexId: NSNumber?
    @NSManaged var speed: String?
    @NSManaged var typeFirst: String?
    @NSManaged var typeSecond: String?
    @NSManaged var weight: String?
    @NSManaged var abilities: String?

}
