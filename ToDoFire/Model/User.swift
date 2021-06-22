//
//  USer.swift
//  ToDoFire
//
//  Created by Егор Шкарин on 16.06.2021.
//

import Foundation
import Firebase

struct User {
    let uid: String
    let email: String
    
    init(user: Firebase.User) {
        self.uid = user.uid
        self.email = user.email!
    }
}
