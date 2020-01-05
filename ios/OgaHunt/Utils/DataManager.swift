//
//  DataManager.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 4/27/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import UIKit

class DataManager {
//    func saveAsPNG(image: UIImage, with name: String) throws -> String {
//        let imagesDirectory = self.imagesDirectory()
//
//        let fileManager = FileManager.default
//        if !fileManager.fileExists(atPath: imagesDirectory.path) {
//            try fileManager.createDirectory(atPath: imagesDirectory.path, withIntermediateDirectories: true, attributes: nil)
//        }
//
//        print("Document directory is \(imagesDirectory)")
//
//        let filename = "\(name).png"
//        let imageStore = imagesDirectory.appendingPathComponent(filename)
//
//        var imageToSave = image
//        if let smallerImage = image.resizedTo1MB() {
//            imageToSave = smallerImage
//        }
//
//        let imageData = UIImagePNGRepresentation(imageToSave)
//        try imageData?.write(to: imageStore)
//
//        let path = imageStore.path
//        if let size = getImageSize(path: path) {
//            print("PNG: \(path) \(size / 1024 / 1024) MB == \(size)")
//        } else {
//            print("Can't find: \(path)")
//        }
//
//        return filename
//    }

    func saveAsJPG(image: UIImage, with name: String) throws -> String {
        let imagesDirectory = self.imagesDirectory()

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            try fileManager.createDirectory(atPath: imagesDirectory.path, withIntermediateDirectories: true, attributes: nil)
        }

        print("Document directory is \(imagesDirectory)")

        let filename = "\(name).jpg"
        let imageStore = imagesDirectory.appendingPathComponent(filename)

        var imageToSave = image
        if let smallerImage = image.resized(withPercentage: 0.8) {
            imageToSave = smallerImage
        }

        let imageData = imageToSave.jpegData(compressionQuality: 0.9)
        try imageData?.write(to: imageStore)

        let path = imageStore.path
        if let size = getImageSize(path: path) {
            print("JPG: \(path) \(size / 1024 / 1024) MB == \(size)")
        } else {
            print("Can't find: \(path)")
        }

        return filename
    }

    func saveImage(data: Data, filename: String) throws -> String {
        let imagesDirectory = self.imagesDirectory()

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            try fileManager.createDirectory(atPath: imagesDirectory.path, withIntermediateDirectories: true, attributes: nil)
        }

//        print("Document directory is \(imagesDirectory)")

//        let filename = "\(name).jpg"
        let imageStore = imagesDirectory.appendingPathComponent(filename)

//        var imageToSave = image
//        if let smallerImage = image.resized(withPercentage: 0.8) {
//            imageToSave = smallerImage
//        }

//        let imageData = UIImageJPEGRepresentation(imageToSave, 0.9)
        try data.write(to: imageStore)

//        let path = imageStore.path

        return filename
    }

    func deleteImageAt(path: String) {
        let imagesDirectory = self.imagesDirectory()

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            return
        }

        let filename = path
        let imageStore = imagesDirectory.appendingPathComponent(filename)

        do {
            try fileManager.removeItem(at: imageStore)
            print("Sweet!")
        } catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }

    func getImageSize(path: String) -> UInt64? {
        var fileSize: UInt64

        do {
            // return [FileAttributeKey : Any]

            let attr = try FileManager.default.attributesOfItem(atPath: path)
            fileSize = attr[FileAttributeKey.size] as! UInt64

            // if you convert to NSDictionary, you can get file size old way as well.
            //            let dict = attr as NSDictionary
            //            fileSize = dict.fileSize()

            return fileSize
        } catch {
            print("Error: \(error)")
            return nil
        }
    }

    func imageSize(path: String) {
        let imagesDirectory = self.imagesDirectory()

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            return
        }

        let filename = path
        let imageStore = imagesDirectory.appendingPathComponent(filename)
//
//        do {
//            try fileManager.removeItem(at: imageStore)
//            print("Sweet!")
//        } catch let error as NSError {
//            print("Ooops! Something went wrong: \(error)")
//        }

        let path = imageStore.path
        if let size = getImageSize(path: path) {
            print("----> Image \(path)\nSize: \(size / 1024 / 1024) MB == \(size)")
        } else {
            print("Can't find: \(path)")
        }
    }

    func absolutePathImageWith(filename: String) -> URL {
        let imagesDirectory = self.imagesDirectory()
        let imageStore = imagesDirectory.appendingPathComponent(filename)
        return imageStore
    }

    func imageFrom(string: String) -> UIImage? {
        let url = absolutePathImageWith(filename: string)
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }

    func dataFromImage(string: String) -> Data? {
        let url = absolutePathImageWith(filename: string)
        do {
            return try Data(contentsOf: url)
        } catch {
            return nil
        }
    }

    // MARK: Utils

    private func imagesDirectory() -> URL {
        let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first
        return documentsDirectory!.appendingPathComponent("images")
    }

    fileprivate func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
}
