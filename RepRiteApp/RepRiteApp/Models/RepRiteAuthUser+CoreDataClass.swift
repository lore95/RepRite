//
//  RepRiteAuthUser+CoreDataClass.swift
//  RepRiteApp
//
//  Created by lorewnzo  on 2024-12-20.
//
//

import Foundation
import CoreData

@objc(RepRiteAuthUser)
public class RepRiteAuthUser: NSManagedObject {
    static var defaultUser: RepRiteAuthUser {
            let user = RepRiteAuthUser(context: DBController.shared.context)
            user.userName = "Unknown"
            user.email = "unknown@example.com"
            // Set other default properties if needed
            return user
        }
}
