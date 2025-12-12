//
//  CalendarViewModel.swift
//  Training calendar
//
//  Created by Madi Sharipov on 11.12.2025.
//

import Foundation
import Combine

class CalendarViewModel: ObservableObject {
    @Published var currentMonth: Date = Date()
    @Published var selectedDate: Date?
    @Published var workouts: [Workout] = []
    @Published var isLoading = false

    private let apiService = MockAPIService.shared
    private let calendar = Calendar.current

    var monthWorkouts: [Date: [Workout]] {
        var result: [Date: [Workout]] = [:]

        for workout in workouts {
            let date = calendar.startOfDay(for: workout.workoutStartDate)
            if result[date] == nil {
                result[date] = []
            }
            result[date]?.append(workout)
        }

        return result
    }

    var daysInCurrentMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return []
        }

        let startDate = monthInterval.start
        let endDate = monthInterval.end

        var dates: [Date] = []
        var currentDate = startDate

        while currentDate < endDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? Date()
        }

        return dates
    }

    var monthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: currentMonth).capitalized
    }

    var today: Date {
        calendar.startOfDay(for: Date())
    }

    init() {
        loadWorkouts()
    }

    func loadWorkouts() {
        isLoading = true
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.workouts = self.apiService.getListWorkouts(email: "test@gmail.com", lastDate: "2020-01-01")
            self.isLoading = false
            
            // Debugging monthWorkouts - Removed debug print block
            // print("Month workouts debug:")
            // for (date, workouts) in self.monthWorkouts {
            //     print("  Date: \(date), Workouts count: \(workouts.count)")
            //     for workout in workouts {
            //         print("    Workout: \(workout.workoutKey), Start Date: \(workout.workoutStartDate)")
            //     }
            // }
        }
    }

    func goToPreviousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    func goToNextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    func selectDate(_ date: Date) {
        selectedDate = date
    }

    func getWorkoutsForDate(_ date: Date) -> [Workout] {
        let dateKey = calendar.startOfDay(for: date)
        return monthWorkouts[dateKey] ?? []
    }

    func hasWorkoutsOnDate(_ date: Date) -> Bool {
        return !getWorkoutsForDate(date).isEmpty
    }

    func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: today)
    }

    func isSelectedDate(_ date: Date) -> Bool {
        guard let selectedDate = selectedDate else { return false }
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }

    func isCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }

    func getWeekdayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).capitalized
    }

    func getDayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}
