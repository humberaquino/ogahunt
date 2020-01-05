//
//  TeamSyncher.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/29/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import Foundation
import Promises

class TeamSyncher: BaseSyncher {
    let queue: DispatchQueue
    private let backend: Backend
    private let teamAPI: TeamAPI

    init(queue: DispatchQueue, backend: Backend) {
        self.queue = queue
        self.backend = backend
        teamAPI = TeamAPI(queue: queue, backend: backend)
        super.init(syncType: .team)
    }

    func sync(intent: SyncIntent, context: NSManagedObjectContext) -> Promise<SyncResult> {
        return Promise<SyncResult>(on: queue) { fulfill, reject in

            // 1. Fetch all contacts, map them
            guard let team = self.backend.currentTeam() else {
                reject(SyncError.noTeamConfigured)
                return
            }

            let result = self.shouldRun(intent: intent)
            if !result.yes {
                fulfill(SyncResult.skipped(reason: result.reason!))
                return
            }

            self.teamAPI.fetchTeamUsers(teamId: team.id).then(on: self.queue) { teamUsersResponse in
                do {
                    guard let responseUsers = teamUsersResponse.users else {
                        fulfill(SyncResult.failed(reason: "No users in response"))
                        return
                    }

                    let usersSaved = try self.mergeTeamUsers(users: responseUsers, context: context)
                    log.debug("New users: \(usersSaved)")

                    self.markSyncWith(result: SyncResult.runned)
                    fulfill(SyncResult.runned)
                } catch {
                    self.markSyncWith(result: SyncResult.error(error: error))
                    reject(error)
                }
            }.catch { error in
                self.markSyncWith(result: SyncResult.error(error: error))
                reject(error)
            }
        }
    }

    func mergeTeamUsers(users: [TeamUserResponse], context: NSManagedObjectContext) throws -> Int {
        // Get users from the DB
        let userService = UserService(managedObjectContext: context)
        let dbUsers = userService.allUsers() ?? []
        var dbUsersMap: [Int64: User] = [:]
        dbUsers.forEach { user in
            dbUsersMap[user.id] = user
        }

        var saved = 0
        // For each user from the request, check if it exists and update
        try users.forEach { responseUser in
            guard let id = responseUser.id else {
                return // skip
            }

            if let dbUser = dbUsersMap[id] {
                // A DB user already exists. Skip for now
                log.debug("User already exists: \(dbUser.id). Skip merge for now")
            } else {
                // Save the user
                let user = try userService.saveUser(user: responseUser)
                log.debug("USer saved: \(user.id)")
                saved += 1
            }
        }

        return saved
    }
}
