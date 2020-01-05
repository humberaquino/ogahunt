//
//  SyncMaster.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/25/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import Foundation
import Promises

class SyncMaster {
    static let global = SyncMaster()

    let queue = DispatchQueue(label: "me.humberaquino.queues.syncmaster")
    let downloadQueue = DispatchQueue(label: "me.humberaquino.queues.download-images")

    var timer: Timer?

    var backend: Backend!
    var coreDataStack: CoreDataStack!

    var periodicSyncEnable = true

    var lastRun: Date?

    var configured: Bool {
        return backend != nil
    }

    var estateImageDownload: [Int64: Bool] = [:]

    init() {
        configObservers()
    }

    func configObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(fireSync(notification:)), name: .fireSync, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopSync(notification:)), name: .stopSync, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(downloadEstateImages(notification:)), name: .downloadEstateImages, object: nil)
    }

    func startTimer(timeInterval: TimeInterval) {
        // Stop in case one is already running
        stopTimer()

        log.info("Timer started. Runs every \(timeInterval) secs")
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }

    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
            log.info("Timer invalidated")
            queue.async {
                self.jobQueue.clean()
            }
        }
    }

    func setup(backend: Backend, coreDataStack: CoreDataStack) {
        self.backend = backend
        self.coreDataStack = coreDataStack

        syncTracker = SyncTracker(queue: queue, backend: self.backend)
    }

    @objc func fireSync(notification: NSNotification) {
        queue.async {
            guard let userInfo = notification.userInfo,
                let syncType = userInfo[SyncNotifier.Keys.syncType] as? SyncType,
                let force = userInfo[SyncNotifier.Keys.force] as? Bool else {
                log.error("Sync without intention")
                return
            }

            if syncType == .all {
                self.jobQueue.clean()
            }

            self.jobQueue.enqueue(item: SyncIntent(type: syncType, force: force))
        }
    }

    @objc func stopSync(notification _: NSNotification) {
        stopSync()
    }

    @objc func fireTimer() {
        start()
    }

    func stopSync() {
        log.info("Stopped sync master")
        stopTimer()
    }

    private var jobQueue = Queue<SyncIntent>()
    private var syncTracker: SyncTracker!

    private var lastFullRan: Date?
    let globalFullRunThreshold: TimeInterval = 5 * 60 // 5 min

    private var processing = false

    func start() {
        queue.async {
            if self.processing {
                log.debug("Currently processing. Skip this timer turn")
                return
            }

            self.processing = true

            let auth = AuthService()
            if auth.requiresLogin() {
                log.info("Sync skipped. Requires log in")
                self.processing = false
                return
            }

            if self.jobQueue.isEmpty {
                if self.periodicSyncEnable {
                    // Check last time it ran
                    let fullRun = self.shouldFullRan()
                    if fullRun.yes {
                        self.lastFullRan = Date() // Add this to avoid having it running multiple times
                        log.info("Enqueing intent 'all' forced after")
                        let allIntent = SyncIntent(type: SyncType.all, force: true)
                        self.process(intent: allIntent)
                    } else {
                        log.debug("Job queue empty. Full run in \(fullRun.reason!) secs")
                        self.processing = false
                    }
                } else {
//                    log.debug("No jobs to process. Skip to next round")
                    self.processing = false
                }
            } else {
                // Process
                if let intent = self.jobQueue.dequeue() {
                    // Process job
                    log.info("--> Processing intent: \(intent). Queue: \(self.jobQueue.count)")
                    self.process(intent: intent)
                } else {
                    log.debug("No more jobs in the queue. Skipping")
                    self.processing = false
                }
            }
        }
    }

    func process(intent: SyncIntent) {
        // Here we process depending on the type
        let bgContext = coreDataStack.newBackgroundContext()

        let startTime = CFAbsoluteTimeGetCurrent()
        let prefix = "[\(DispatchQueue.currentLabel)]"

        syncTracker.processSync(intent: intent, context: bgContext).then(on: queue) { result in
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

            if result.success {
                log.info("\(prefix) Done!")
            } else {
                // TODO: Report this issue
                log.info("\(prefix) Failure. Reason: \(result.reason ?? "no-reason")")
            }

            log.info("\(prefix) It took \(timeElapsed) secs")
            self.markAsNoRunning()
            self.processing = false

            // Try to consume the rest of the queue
            self.start()
        }.catch { error in
            log.error("\(prefix) Error trying to sync: \(error)")
            self.markAsNoRunning(error: error)
            self.processing = false

            // Try to consume the rest of the queue
            self.start()
        }

        // After is compelte we mark the completion and the times
    }

    private func shouldFullRan() -> Result {
        guard let lastFullRan = lastFullRan else {
            return Result(yes: true, reason: nil)
        }

        let duration = Date().timeIntervalSince(lastFullRan)
        if duration > globalFullRunThreshold {
            return Result(yes: true, reason: nil)
        } else {
            return Result(yes: false, reason: "\(Int(globalFullRunThreshold - duration))")
        }
    }

    private func markAsNoRunning(error: Error? = nil) {
        DispatchQueue.main.async {
            // Notify listeners
            if let error = error {
                // TODO: Save error
                let userInfo = [
                    "error": error,
                ]
                NotificationCenter.default.post(name: .syncFailure, object: self, userInfo: userInfo)
            } else {
                NotificationCenter.default.post(name: .syncSuccess, object: self)
            }

            self.lastRun = Date()
//            self.isRunning = false
        }
    }
}

extension SyncMaster {
    private func markAsDownloading(estateId: Int64) {
        estateImageDownload[estateId] = true
    }

    private func markAsDownloadComplete(estateId: Int64) {
        DispatchQueue.main.async {
            self.estateImageDownload.removeValue(forKey: estateId)

            let userInfo = [
                "estateId": estateId,
            ]
            NotificationCenter.default.post(name: .syncImagesDownloaded, object: self, userInfo: userInfo)
        }
    }

    @objc func downloadEstateImages(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let estateId = userInfo["estateId"] as? Int64 else {
            log.error("No estateId provided when requesting image download")
            return
        }

        if let isDownloading = estateImageDownload[estateId], isDownloading {
            log.debug("Skip sync for estate \(estateId). Already downloading")
            return
        }

        markAsDownloading(estateId: estateId)

        downloadQueue.async {
            let bgContext = self.coreDataStack.newBackgroundContext()
            // Get estate by id
            let estateService = EstateService(managedObjectContext: bgContext)
            guard let estate = estateService.findBy(id: estateId) else {
                log.error("Estate with id \(estateId) doesn't exit. Skip image download")
                return
            }

            // For each image, download using the signed URL with alamofire
            guard let images = estate.images?.array as? [Image],
                !images.isEmpty else {
                log.error("No images for estate \(estateId). Skip download")
                return
            }

            let downloadAPI = DownloadAPI(queue: self.downloadQueue, backend: self.backend)
            let dataManager = DataManager()

            var promises: [Promise<DownloadResult>] = []
            var processedImages: [Image] = []
            // Store the image in he FS and associate it to the estate image
            images.forEach({ image in

                if image.localPath != nil {
                    log.debug("Image already downloaded")
                    return
                }

                guard let signedImageURL = image.signedImageURL,
                    let contentType = image.contentType,
                    let imageName = image.imageURL,
                    image.imageURL != nil else {
                    log.error("No signed url for estate image")
                    return
                }

                let promise = downloadAPI.downloadSignedRequestImage(imageName: imageName, signedURL: signedImageURL, contentType: contentType)
                promises.append(promise)
                processedImages.append(image)
            })

            all(promises).then(on: self.downloadQueue) { results in

                for index in 0 ..< results.count {
                    let downloadResult = results[index]
                    let image = processedImages[index]
                    guard let resourceName = image.imageURL else {
                        log.error("No signed url for estate image")
                        return
                    }

                    do {
                        if let data = downloadResult.data {
                            // Save in the local path
                            let path = try dataManager.saveImage(data: data, filename: resourceName)
                            // update the estate's local path
                            image.localPath = path
                        } else {
                            // with the signature. Just remove it
                            image.signedImageURL = nil
                        }
                    } catch {
                        log.error("Error saving image: \(resourceName): \(error)")
                        //                        self.markAsDownloadComplete(estateId: estateId)
                    }
                }

                // At the end do a save
                try bgContext.save()
                log.info("Images for estate \(estateId) downloaded")
                self.markAsDownloadComplete(estateId: estateId)

            }.catch { error in

                log.error("Error downloading images for estate \(estateId): \(error)")
                self.markAsDownloadComplete(estateId: estateId)
            }
        }
    }
}

enum SyncError: Error {
    case noTeamConfigured
    case settingSyncFailed(reason: String?)
    case teamSyncFailed(reason: String?)
    case contactsSyncFailed(reason: String?)
    case estateMappingError
    case apiResponseWithoutId
}
