//
//  RepRiteAuthUser+CoreDataProperties.swift
//  RepRiteApp
//
//  Created by lorewnzo  on 2024-12-20.
//
//

import Foundation
import CoreData


extension RepRiteAuthUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RepRiteAuthUser> {
        return NSFetchRequest<RepRiteAuthUser>(entityName: "RepRiteAuthUser")
    }

    @NSManaged public var userName: String
    @NSManaged public var password: String
    @NSManaged public var lastName: String?
    @NSManaged public var firstName: String
    @NSManaged public var age: Int16
    @NSManaged public var email: String
    @NSManaged public var phoneNumber: String?
    @NSManaged public var sex: String?


}

extension RepRiteAuthUser : Identifiable {

}
