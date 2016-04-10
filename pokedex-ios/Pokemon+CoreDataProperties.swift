//
//  Pokemon+CoreDataProperties.swift
//  pokedex-ios
//
//  Created by iosdev on 10.4.2016.
//  Copyright © 2016 iosdev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pokemon {
    @NSManaged var name: String?
    @NSManaged var pokedexId: NSNumber?
    @NSManaged var height: String?
    @NSManaged var descriptionText: String?
    @NSManaged var weight: String?
    @NSManaged var attack: String?
    @NSManaged var defense: String?
    @NSManaged var hp: String?
    @NSManaged var speed: String?
    @NSManaged var nextEvoText: String?
    @NSManaged var typeFirst: String?
    @NSManaged var typeSecond: String?

}
