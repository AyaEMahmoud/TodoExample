//
//  Data.swift
//  TodoeyApp
//
//  Created by Aya Mahmoud on 19/03/2024.
//

import Foundation
import RealmSwift

class Item: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var createdAt: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
