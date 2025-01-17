import CoreData
import Foundation

class DBController {
    static let shared = DBController()

    private let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "RepRiteUser")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Failed to load CoreData store: \(error)")
            }
        }
    }

    var context: NSManagedObjectContext {
        return container.viewContext
    }

    func saveUser(
        userName: String, firstName: String, lastName: String, sex: String,
        age: Int, email: String, phoneNumber: String, password: String
    ) -> Bool {
        let user = RepRiteAuthUser(context: context)
        user.userName = userName
        user.firstName = firstName
        user.lastName = lastName
        user.sex = sex
        user.age = Int16(age)
        user.email = email
        user.phoneNumber = phoneNumber
        user.password = password

        do {
            try context.save()
            return true
        } catch {
            print("Failed to save user: \(error)")
            return false
        }
    }

    func validateUser(userName: String, password: String) -> Bool {
        let fetchRequest: NSFetchRequest<RepRiteAuthUser> =
            RepRiteAuthUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "userName == %@ AND password == %@", userName, password)

        do {
            let users = try context.fetch(fetchRequest)
            return !users.isEmpty
        } catch {
            print("Error validating user: \(error)")
            return false
        }
    }
    func doesUsernameExist(userName: String) -> Bool {
        let fetchRequest: NSFetchRequest<RepRiteAuthUser> =
            RepRiteAuthUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userName == %@", userName)

        do {
            let users = try context.fetch(fetchRequest)
            return !users.isEmpty
        } catch {
            print("Error checking username: \(error)")
            return false
        }
    }
    func saveGoogleId(forEmail email: String, googleId: String) -> Bool {
        let fetchRequest: NSFetchRequest<RepRiteAuthUser> =
            RepRiteAuthUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)

        do {
            let users = try context.fetch(fetchRequest)

            if let user = users.first {
                // Update the user's Google ID
                user.googleId = googleId
                try context.save()
                return true
            } else {
                print("No user found with the specified email.")
                return false
            }
        } catch {
            print("Error saving Google ID: \(error)")
            return false
        }
    }
    func doesEmailExist(email: String) -> Bool {
        let fetchRequest: NSFetchRequest<RepRiteAuthUser> =
            RepRiteAuthUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)

        do {
            let users = try context.fetch(fetchRequest)
            return !users.isEmpty
        } catch {
            print("Error checking username: \(error)")
            return false
        }
    }
    func getUserByEmail(email: String) -> RepRiteAuthUser? {
        let fetchRequest: NSFetchRequest<RepRiteAuthUser> = RepRiteAuthUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)

        do {
            let users = try context.fetch(fetchRequest)
            return users.first // Return the first user if found
        } catch {
            print("Error fetching user by email: \(error)")
            return nil // Return nil in case of an error
        }
    }
    func deleteUserByEmail(email: String) -> Bool {
        let fetchRequest: NSFetchRequest<RepRiteAuthUser> = RepRiteAuthUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)

        do {
            let users = try context.fetch(fetchRequest)
            if let user = users.first {
                context.delete(user) // Delete the user object
                try context.save() // Save the context to persist changes
                print("User with email \(email) deleted successfully.")
                return true
            } else {
                print("No user found with the specified email: \(email).")
                return false
            }
        } catch {
            print("Failed to delete user: \(error)")
            return false
        }
    }
    func updateUserDetails(
        email: String,
        userName: String,
        firstName: String,
        lastName: String?,
        age: Int,
        phoneNumber: String?,
        sex: String?
    ) -> Bool {
        guard let user = getUserByEmail(email: email) else {
            print("User not found.")
            return false
        }

        user.userName = userName
        user.firstName = firstName
        user.lastName = lastName
        user.age = Int16(age)
        user.phoneNumber = phoneNumber
        user.sex = sex

        do {
            try context.save()
            print("User details updated successfully.")
            return true
        } catch {
            print("Failed to update user details: \(error)")
            return false
        }
    } 
}
