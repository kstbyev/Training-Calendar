//
//  WorkoutMetadata.swift
//  Training calendar
//
//  Created by Madi Sharipov on 11.12.2025.
//

import Foundation

struct WorkoutMetadata: Codable, Equatable {
    let workoutKey: String
    let workoutActivityType: WorkoutType
    let workoutStartDate: Date
    let distance: Double
    let duration: Double // in seconds
    let maxLayer: Int
    let maxSubLayer: Int
    let avgHumidity: Double
    let avgTemp: Double
    let comment: String?
    let photoBefore: String?
    let photoAfter: String?
    let heartRateGraph: String?
    let activityGraph: String?
    let map: String?

    var formattedDistance: String {
        if distance == 0 {
            return "0 км"
        }
        return String(format: "%.1f км", distance / 1000)
    }

    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)ч \(minutes)мин"
        } else {
            return "\(minutes) мин"
        }
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: workoutStartDate)
    }

    var formattedAvgTemp: String {
        String(format: "%.1f°C", avgTemp)
    }

    var formattedAvgHumidity: String {
        String(format: "%.0f%%", avgHumidity)
    }

    init(workoutKey: String, workoutActivityType: WorkoutType, workoutStartDate: Date, distance: Double, duration: Double, maxLayer: Int, maxSubLayer: Int, avgHumidity: Double, avgTemp: Double, comment: String?, photoBefore: String?, photoAfter: String?, heartRateGraph: String?, activityGraph: String?, map: String?) {
        self.workoutKey = workoutKey
        self.workoutActivityType = workoutActivityType
        self.workoutStartDate = workoutStartDate
        self.distance = distance
        self.duration = duration
        self.maxLayer = maxLayer
        self.maxSubLayer = maxSubLayer
        self.avgHumidity = avgHumidity
        self.avgTemp = avgTemp
        self.comment = comment
        self.photoBefore = photoBefore
        self.photoAfter = photoAfter
        self.heartRateGraph = heartRateGraph
        self.activityGraph = activityGraph
        self.map = map
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        workoutKey = try container.decode(String.self, forKey: .workoutKey)
        let activityTypeString = try container.decode(String.self, forKey: .workoutActivityType)
        workoutActivityType = WorkoutType(rawValue: activityTypeString) ?? .walkingRunning
        let dateString = try container.decode(String.self, forKey: .workoutStartDate)
        workoutStartDate = DateFormatter.iso8601CustomFormatter.date(from: dateString) ?? Date()
        distance = Double(try container.decode(String.self, forKey: .distance)) ?? 0.0
        duration = Double(try container.decode(String.self, forKey: .duration)) ?? 0.0
        maxLayer = try container.decode(Int.self, forKey: .maxLayer)
        maxSubLayer = try container.decode(Int.self, forKey: .maxSubLayer)
        avgHumidity = Double(try container.decode(String.self, forKey: .avgHumidity)) ?? 0.0
        avgTemp = Double(try container.decode(String.self, forKey: .avgTemp)) ?? 0.0
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        photoBefore = try container.decodeIfPresent(String.self, forKey: .photoBefore)
        photoAfter = try container.decodeIfPresent(String.self, forKey: .photoAfter)
        heartRateGraph = try container.decodeIfPresent(String.self, forKey: .heartRateGraph)
        activityGraph = try container.decodeIfPresent(String.self, forKey: .activityGraph)
        map = try container.decodeIfPresent(String.self, forKey: .map)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(workoutKey, forKey: .workoutKey)
        try container.encode(workoutActivityType.rawValue, forKey: .workoutActivityType)
        try container.encode(ISO8601DateFormatter().string(from: workoutStartDate), forKey: .workoutStartDate)
        try container.encode(String(distance), forKey: .distance)
        try container.encode(String(duration), forKey: .duration)
        try container.encode(maxLayer, forKey: .maxLayer)
        try container.encode(maxSubLayer, forKey: .maxSubLayer)
        try container.encode(String(avgHumidity), forKey: .avgHumidity)
        try container.encode(String(avgTemp), forKey: .avgTemp)
        try container.encodeIfPresent(comment, forKey: .comment)
        try container.encodeIfPresent(photoBefore, forKey: .photoBefore)
        try container.encodeIfPresent(photoAfter, forKey: .photoAfter)
        try container.encodeIfPresent(heartRateGraph, forKey: .heartRateGraph)
        try container.encodeIfPresent(activityGraph, forKey: .activityGraph)
        try container.encodeIfPresent(map, forKey: .map)
    }

    static func == (lhs: WorkoutMetadata, rhs: WorkoutMetadata) -> Bool {
        lhs.workoutKey == rhs.workoutKey &&
        lhs.workoutActivityType == rhs.workoutActivityType &&
        lhs.workoutStartDate == rhs.workoutStartDate &&
        lhs.distance == rhs.distance &&
        lhs.duration == rhs.duration &&
        lhs.maxLayer == rhs.maxLayer &&
        lhs.maxSubLayer == rhs.maxSubLayer &&
        lhs.avgHumidity == rhs.avgHumidity &&
        lhs.avgTemp == rhs.avgTemp &&
        lhs.comment == rhs.comment &&
        lhs.photoBefore == rhs.photoBefore &&
        lhs.photoAfter == rhs.photoAfter &&
        lhs.heartRateGraph == rhs.heartRateGraph &&
        lhs.activityGraph == rhs.activityGraph &&
        lhs.map == rhs.map
    }

    private enum CodingKeys: String, CodingKey {
        case workoutKey, workoutActivityType, workoutStartDate, distance, duration
        case maxLayer, maxSubLayer, avgHumidity = "avg_humidity", avgTemp = "avg_temp"
        case comment, photoBefore, photoAfter, heartRateGraph, activityGraph, map
    }
}