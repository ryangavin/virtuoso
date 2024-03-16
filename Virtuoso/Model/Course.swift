//
//  Course.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 3/10/24.
//

import Foundation

struct Course: Codable, Identifiable {
    var id: String
    var title: String
    var description: String
    var difficulty: Int

    var lessons: [Song]
}
