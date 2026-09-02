//
//  BaseService.swift
//  Kolesa Group
//
//  Created by Aimukambetov Sanatzhan on 15.06.2022.
//

import Foundation

class BaseService<T>: NSObject {
    let client: T

    init(client: T) {
        self.client = client
    }
}
