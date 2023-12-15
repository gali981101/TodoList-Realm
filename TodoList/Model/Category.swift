//
//  Category.swift
//  TodoList
//
//  Created by Terry Jason on 2023/12/11.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var dateCreated: Date?
    let items = List<Item>()
}
