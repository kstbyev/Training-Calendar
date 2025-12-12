//
//  DiagramData.swift
//  Training calendar
//
//  Created by Madi Sharipov on 11.12.2025.
//

import Foundation

struct DiagramData: Codable {
    let description: String
    let workouts: [String: WorkoutDiagramData]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        description = try container.decode(String.self, forKey: .description)
        workouts = try container.decode([String: WorkoutDiagramData].self, forKey: .workouts)
    }
}

struct WorkoutDiagramData: Codable {
    let description: String
    let data: [DiagramDataPoint]
    let states: [String] // Empty array in provided data

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        description = try container.decode(String.self, forKey: .description)
        data = try container.decode([DiagramDataPoint].self, forKey: .data)
        states = try container.decode([String].self, forKey: .states)
    }
}

struct DiagramDataPoint: Codable, Identifiable {
    let id = UUID()
    let timeNumeric: Int // minutes from start
    let heartRate: Int // bpm
    let speedKmh: Double
    let distanceMeters: Int
    let steps: Int
    let elevation: Double
    let latitude: Double
    let longitude: Double
    let temperatureCelsius: Double
    let currentLayer: Int
    let currentSubLayer: Int
    let currentTimestamp: Date

    var formattedTime: String {
        let minutes = timeNumeric % 60
        let hours = timeNumeric / 60
        if hours > 0 {
            return String(format: "%d:%02d", hours, minutes)
        } else {
            return "\(minutes) мин"
        }
    }

    var formattedSpeed: String {
        String(format: "%.1f км/ч", speedKmh)
    }

    var formattedDistance: String {
        String(format: "%.0f м", Double(distanceMeters))
    }

    var formattedElevation: String {
        String(format: "%.1f м", elevation)
    }

    var formattedTemperature: String {
        String(format: "%.1f°C", temperatureCelsius)
    }

    init(timeNumeric: Int, heartRate: Int, speedKmh: Double, distanceMeters: Int, steps: Int, elevation: Double, latitude: Double, longitude: Double, temperatureCelsius: Double, currentLayer: Int, currentSubLayer: Int, currentTimestamp: Date) {
        self.timeNumeric = timeNumeric
        self.heartRate = heartRate
        self.speedKmh = speedKmh
        self.distanceMeters = distanceMeters
        self.steps = steps
        self.elevation = elevation
        self.latitude = latitude
        self.longitude = longitude
        self.temperatureCelsius = temperatureCelsius
        self.currentLayer = currentLayer
        self.currentSubLayer = currentSubLayer
        self.currentTimestamp = currentTimestamp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timeNumeric = try container.decode(Int.self, forKey: .timeNumeric)
        heartRate = try container.decode(Int.self, forKey: .heartRate)
        speedKmh = try container.decode(Double.self, forKey: .speedKmh)
        distanceMeters = try container.decode(Int.self, forKey: .distanceMeters)
        steps = try container.decode(Int.self, forKey: .steps)
        elevation = try container.decode(Double.self, forKey: .elevation)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        temperatureCelsius = try container.decode(Double.self, forKey: .temperatureCelsius)
        currentLayer = try container.decode(Int.self, forKey: .currentLayer)
        currentSubLayer = try container.decode(Int.self, forKey: .currentSubLayer)
        let timestampString = try container.decode(String.self, forKey: .currentTimestamp)
        currentTimestamp = ISO8601DateFormatter().date(from: timestampString) ?? Date()
    }

    private enum CodingKeys: String, CodingKey {
        case timeNumeric = "time_numeric"
        case heartRate = "heartRate"
        case speedKmh = "speed_kmh"
        case distanceMeters = "distanceMeters"
        case steps
        case elevation
        case latitude
        case longitude
        case temperatureCelsius = "temperatureCelsius"
        case currentLayer = "currentLayer"
        case currentSubLayer = "currentSubLayer"
        case currentTimestamp = "currentTimestamp"
    }
}