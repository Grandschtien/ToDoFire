//
//  Task.swift
//  ToDoFire
//
//  Created by Егор Шкарин on 16.06.2021.
//

import Foundation
import Firebase

struct Task {
    let title: String
    let userId: String
    let ref: FirebaseDatabase.DatabaseReference?
    var isCompleted: Bool = false
    
    init(title: String, userId: String) {
        self.title = title
        self.userId = userId
        self.ref = nil
    }
    init(snapshot: FirebaseDatabase.DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        title = snapshotValue["title"] as! String
        userId = snapshotValue["userId"] as! String
        isCompleted = snapshotValue["completed"] as! Bool
        ref = snapshot.ref
    }
    
    func makeDictionary() -> Any{
        return ["title": self.title, "userId": self.userId, "completed": self.isCompleted]
    }
}
