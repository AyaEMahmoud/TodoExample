//
//  Category.swift
//  TodoeyApp
//
//  Created by Aya Mahmoud on 19/03/2024.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var bgColor: String?
    
    var items = List<Item>()
}
