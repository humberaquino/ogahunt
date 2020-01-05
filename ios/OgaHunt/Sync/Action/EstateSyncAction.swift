//
//  EstateSyncAction.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/2/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

import CoreData
import Foundation
import Promises

class EstateSyncAction {
    let queue: DispatchQueue
    let backend: Backend
    let estateAPI: EstateAPI
    let context: NSManagedObjectContext
    let uploadAPI: UploadAPI
    let estateService: EstateService

    init(context: NSManagedObjectContext) {
        queue = .main
        backend = Backend.global
        estateAPI = EstateAPI(queue: queue, backend: backend)
        uploadAPI = UploadAPI(queue: queue, backend: backend)
        self.context = context
        estateService = EstateService(managedObjectContext: context)
    }

//    init(queue: DispatchQueue, backend: Backend) {
//        self.queue = queue
//        self.backend = backend
//        estateAPI = EstateAPI(queue: queue, backend: backend)
//        uploadAPI = UploadAPI(queue: queue, backend: backend)
//        estateService = EstateService(managedObjectContext: context)
//
//        super.init(syncType: .estate)
//    }

    func assignEstate(estate: Estate, to user: User) -> Promise<OPResult> {
        return Promise<OPResult>(on: queue) { fulfill, reject in

            guard let team = self.backend.currentTeam() else {
                reject(SyncError.noTeamConfigured)
                return
            }

            self.estateAPI.assignEstate(teamId: team.id, estateId: estate.id, userId: user.id).then { _ in
                do {
                    // TODO: Assignment also updates the version
                    estate.assignedTo = user
                    try self.context.save()

                    fulfill(OPResult(success: true, reason: nil))

                } catch {
                    print(error)
                    reject(error)
                }

            }.catch { error in
                print(error)
                reject(error)
            }
        }
    }

    func unassignEstate(estate: Estate) -> Promise<OPResult> {
        return Promise<OPResult>(on: queue) { fulfill, reject in

            guard let team = self.backend.currentTeam() else {
                reject(SyncError.noTeamConfigured)
                return
            }

            self.estateAPI.assignEstate(teamId: team.id, estateId: estate.id, userId: nil).then { _ in
                do {
                    // TODO: Assignment also updates the version
                    estate.assignedTo = nil
                    try self.context.save()

                    fulfill(OPResult(success: true, reason: nil))

                } catch {
                    print(error)
                    reject(error)
                }

            }.catch { error in
                print(error)
                reject(error)
            }
        }
    }

    func updateEstateRemotelly(estateResponse: EstateResponse) -> Promise<Estate> {
        return Promise<Estate>(on: queue) { fulfill, reject in

            guard let team = self.backend.currentTeam() else {
                reject(SyncError.noTeamConfigured)
                return
            }

            self.estateAPI.updateEstate(teamId: team.id, estateResponse: estateResponse).then { updatedEstateResponse in
                // 2. Save all contacts if they don't exist: last update time for each, with contact_id

                do {
                    // let estateService = EstateService(managedObjectContext: self.context)
                    let estate = try self.estateService.mergeWithExistingEstate(estateResponse: updatedEstateResponse)

                    fulfill(estate)

                } catch {
                    print(error)
                    reject(error)
                }

            }.catch { error in
                print(error)
                reject(error)
            }
        }
    }

    func deleteEstateRemotelly(estate: Estate) -> Promise<OPResult> {
        return Promise<OPResult>(on: queue) { fulfill, reject in

            guard let team = self.backend.currentTeam() else {
                reject(SyncError.noTeamConfigured)
                return
            }

            let estateResponse = estate.toEstateResponse()
            self.estateAPI.deleteEstate(teamId: team.id, estateResponse: estateResponse).then { _ in

                do {
                    try self.estateService.delete(estate: estate)
                    fulfill(OPResult(success: true, reason: nil))

                } catch {
                    print(error)
                    reject(error)
                }

            }.catch { error in
                print(error)
                reject(error)
            }
        }
    }

    func saveEstateRemotelly(estateResponse: EstateResponse) -> Promise<Estate> {
        return Promise<Estate>(on: queue) { fulfill, reject in

            guard let team = self.backend.currentTeam() else {
                reject(SyncError.noTeamConfigured)
                return
            }

            self.estateAPI.createEstate(teamId: team.id, estateResponse: estateResponse).then { updatedEstateResponse in
                // 2. Save all contacts if they don't exist: last update time for each, with contact_id

                do {
                    // let estateService = EstateService(managedObjectContext: self.context)
                    let estate = try self.estateService.mergeWithExistingEstate(estateResponse: updatedEstateResponse)

                    fulfill(estate)

                } catch {
                    print(error)
                    reject(error)
                }

            }.catch { error in
                print(error)
                reject(error)
            }
        }
    }

    func updateLocationRemotelly(estate: Estate, locationResponse: LocationResponse) -> Promise<Estate> {
        return Promise<Estate>(on: queue) { fulfill, reject in

            guard let team = self.backend.currentTeam() else {
                reject(SyncError.noTeamConfigured)
                return
            }

            self.estateAPI.updateLocation(teamId: team.id, estateId: estate.id, locationResponse: locationResponse).then { updatedEstateResponse in
                // 2. Save all contacts if they don't exist: last update time for each, with contact_id

                do {
                    // let estateService = EstateService(managedObjectContext: self.context)
                    let estate = try self.estateService.mergeWithExistingEstate(estateResponse: updatedEstateResponse)

                    fulfill(estate)

                } catch {
                    print(error)
                    reject(error)
                }

            }.catch { error in
                print(error)
                reject(error)
            }
        }
    }

    func toogleEstateRemotelly(estate: Estate) -> Promise<String> {
        return Promise<String>(on: queue) { fulfill, reject in

            guard let team = self.backend.currentTeam() else {
                reject(SyncError.noTeamConfigured)
                return
            }

            let newStatus = estate.toogleStatus()

            self.estateAPI.updateStatus(teamId: team.id, estateId: estate.id, status: newStatus).then { _ in
                // 2. Save all contacts if they don't exist: last update time for each, with contact_id

                do {
                    // let estateService = EstateService(managedObjectContext: self.context)
                    try self.estateService.setEstateStatus(estate: estate, status: newStatus)

                    fulfill(newStatus)

                } catch {
                    print(error)
                    reject(error)
                }

            }.catch { error in
                print(error)
                reject(error)
            }
        }
    }

    func saveEstateAndImagesRemotelly(estateResponse: EstateResponse) -> Promise<[OPResult]> {
        return Promise<[OPResult]>(on: queue) { fulfill, reject in

            self.saveEstateRemotelly(estateResponse: estateResponse).then { updatedEstate in

                return self.uploadAndSaveImages(estate: updatedEstate)
            }.then { result in

                fulfill(result)
            }.catch { error in
                reject(error)
            }
        }
    }

    func uploadAndSaveImages(estate: Estate, saveEvent: Bool = true) -> Promise<[OPResult]> {
        return Promise<[OPResult]>(on: queue) { fulfill, reject in

            guard let imageOrderedSet = estate.images else {
                log.debug("No images associated with this estate")
                fulfill([])
                return
            }

            guard let images = imageOrderedSet.array as? [Image] else {
                reject(EstateError.nonImageSaved)
                return
            }

            if images.isEmpty {
                log.debug("No images associated with this estate")
                fulfill([])
                return
            }

            var imageUploadPromises: [Promise<OPResult>] = []
            images.forEach({ image in

                // Upload only the ones not yet uploaded: imageURL == nil
                // Upload, save and update locally
                if image.imageURL == nil {
                    let uploadPromise = self.uploadAndSaveImage(estate: estate, image: image, saveEvent: saveEvent)
                    imageUploadPromises.append(uploadPromise)
                }
            })

            if imageUploadPromises.isEmpty {
                log.debug("No images to upload")
                fulfill([])
                return
            }

            all(imageUploadPromises).then { results in
                fulfill(results)
            }.catch { error in
                reject(error)
            }
        }
    }

    func uploadAndSaveImage(estate: Estate, image: Image, saveEvent: Bool = true) -> Promise<OPResult> {
        return Promise<OPResult>(on: queue) { fulfill, reject in
            if let path = image.localPath {
                let dataManager = DataManager()
                dataManager.imageSize(path: path)

                if let data = dataManager.dataFromImage(string: path) {
                    // 1. Upload to GCS
                    self.uploadAPI.upload(estateId: estate.id, imageName: path, imageData: data).then { uploadResult in
                        log.debug("Image uploaded to GCS")

                        do {
                            // 2. Save upload state locally
                            try self.estateService.updateImage(image: image, uploadResult: uploadResult)

                            // 3. Save image into the server for the estate
                            self.uploadAPI.saveUploadedImage(estateId: estate.id, resourceName: uploadResult.resourceName, saveEvent: saveEvent).then { res in
                                // TODO: 4. Update locally as complete
                                let success = res.success ?? false
                                fulfill(OPResult(success: success, reason: "Resource: \(uploadResult.resourceName)"))
                            }.catch { error in
                                reject(error)
                            }
                        } catch {
                            reject(error)
                        }
                    }.catch { error in
                        reject(error)
                    }
                }
            } else {
                log.debug("Skipping upload for non-local image: \(image)")
                fulfill(OPResult(success: true, reason: "Skip non local path"))
            }
        }
    }
}
