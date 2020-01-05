//
//  BaseManagedViewController.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 5/5/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import UIKit

class BaseManagedViewController: UIViewController {
    var managedContext: NSManagedObjectContext!

    func setupContext(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
    }
}
