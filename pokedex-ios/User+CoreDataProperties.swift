//
//  User+CoreDataProperties.swift
//  pokedex-ios
//
//  Created by iosdev on 21.4.2016.
//  Copyright © 2016 iosdev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var caughtCount: NSNumber?
    @NSManaged var active: Pokemon?
    @NSManaged var caught: NSSet?

}
