//
//  WorkoutMetadataResponse.swift
//  Training calendar
//
//  Created by Madi Sharipov on 11.12.2025.
//

import Foundation

struct WorkoutMetadataResponse: Codable {
    let description: String
    let workouts: [String: WorkoutMetadata]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        description = try container.decode(String.self, forKey: .description)
        workouts = try container.decode([String: WorkoutMetadata].self, forKey: .workouts)
    }
}


