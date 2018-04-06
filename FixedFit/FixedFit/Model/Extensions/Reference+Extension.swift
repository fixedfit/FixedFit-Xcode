//
//  DatabaseReference+Extension.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 4/5/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import Firebase

extension DatabaseReference {
    func child(_ firebaseKey: FirebaseKeys) -> DatabaseReference {
        return self.child(firebaseKey.rawValue)
    }
}

extension StorageReference {
    func child(_ firebaseKey: FirebaseKeys) -> StorageReference {
        return self.child(firebaseKey.rawValue)
    }
}
