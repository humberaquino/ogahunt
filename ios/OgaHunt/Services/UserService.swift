//
//  UserService.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/29/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import Foundation

class UserService {
    let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    func allUsers() -> [User]? {
        let request: NSFetchRequest<User> = User.fetchRequest()

        do {
            let users = try managedObjectContext.fetch(request)
            return users
        } catch {
            log.error(error)
            return nil
        }
    }

    func saveUser(user: TeamUserResponse) throws -> User {
        let newUser = User(context: managedObjectContext)

        guard let id = user.id, let email = user.email else {
            throw UserError.noIdProvided
        }

        newUser.id = id
        newUser.email = email
        newUser.name = user.name
        newUser.roleId = user.roleId ?? -1

        try managedObjectContext.save()
        return newUser
    }

    func findBy(id userId: Int64) -> User? {
        let predicate = NSPredicate(format: "id == %lld", userId)
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.fetchLimit = 1
        request.predicate = predicate

        let users = try! managedObjectContext.fetch(request)

        return users.first
    }
}

enum UserError: Error {
    case noIdProvided
}
