import Foundation
import SwiftUI

// MARK: - Workout Models

struct Workout: Codable, Identifiable {
    let id: String
    let workoutKey: String
    let workoutActivityType: WorkoutType
    let workoutStartDate: Date

    var date: Date {
        workoutStartDate
    }

    var day: Int {
        Calendar.current.component(.day, from: workoutStartDate)
    }

    var month: Int {
        Calendar.current.component(.month, from: workoutStartDate)
    }

    var year: Int {
        Calendar.current.component(.year, from: workoutStartDate)
    }

    var formattedTime: String {
        return DateFormatter.iso8601CustomFormatter.string(from: workoutStartDate)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        workoutKey = try container.decode(String.self, forKey: .workoutKey)
        id = workoutKey // Assign workoutKey to id
        workoutActivityType = try container.decode(WorkoutType.self, forKey: .workoutActivityType)
        let dateString = try container.decode(String.self, forKey: .workoutStartDate)
        
        if let date = DateFormatter.iso8601CustomFormatter.date(from: dateString) {
            workoutStartDate = date
        } else {
            print("Error decoding date string: \(dateString)")
            workoutStartDate = Date() // Fallback to current date
        }
    }

    private enum CodingKeys: String, CodingKey {
        case workoutKey, workoutActivityType, workoutStartDate
    }
}

enum WorkoutType: String, Codable, CaseIterable {
    case walkingRunning = "Walking/Running"
    case yoga = "Yoga"
    case water = "Water"
    case cycling = "Cycling"
    case strength = "Strength"

    var displayName: String {
        switch self {
        case .walkingRunning: return "Бег/Ходьба"
        case .yoga: return "Йога"
        case .water: return "Вода"
        case .cycling: return "Велоспорт"
        case .strength: return "Силовые"
        }
    }

    var iconName: String {
        switch self {
        case .walkingRunning: return "figure.run"
        case .yoga: return "figure.mind.and.body"
        case .water: return "drop.fill"
        case .cycling: return "bicycle"
        case .strength: return "dumbbell.fill"
        }
    }

    var color: Color { // Возвращает Color из SwiftUI
        switch self {
        case .walkingRunning: return .blue
        case .yoga: return .green
        case .water: return .cyan
        case .cycling: return .orange
        case .strength: return .red
        }
    }
}
