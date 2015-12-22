//
//  Product+CoreDataProperties.swift
//  Black-Fu
//
//  Created by Li Chen wei on 2015/12/22.
//  Copyright © 2015年 TWML. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Product {

    @NSManaged var name: String?
    @NSManaged var imageUrl: String?
    @NSManaged var detail: String?
    @NSManaged var product_id: NSNumber?
    @NSManaged var barcodeRelationship: NSManagedObject?
    @NSManaged var brandRelationship: NSManagedObject?

}
