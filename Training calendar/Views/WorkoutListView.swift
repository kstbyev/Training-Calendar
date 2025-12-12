//
//  WorkoutListView.swift
//  Training calendar
//
//  Created by Madi Sharipov on 11.12.2025.
//

import SwiftUI

struct WorkoutListView: View {
    var coordinator: AppCoordinator
    let selectedDate: Date
    @Binding var path: NavigationPath

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject private var viewModel = CalendarViewModel()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .medium
        return formatter
    }()

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(spacing: 0) {
            // Header with selected date
            headerView

            // Workouts list
            if viewModel.isLoading {
                ProgressView("Загрузка тренировок...")
                    .padding()
            } else if workoutsForSelectedDate.isEmpty {
                emptyStateView
            } else {
                workoutsList
            }
        }
        .navigationTitle("Тренировки")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            viewModel.loadWorkouts()
        }
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            Text(dateFormatter.string(from: selectedDate))
                .font(.title2)
                .fontWeight(.semibold)

            Text("Тренировки за день")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.largeTitle)
                .foregroundColor(.secondary)

            Text("Нет тренировок")
                .font(.title3)
                .foregroundColor(.secondary)

            Text("В этот день тренировок не было")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var workoutsList: some View {
        List(workoutsForSelectedDate) { workout in
            WorkoutListRow(workout: workout, coordinator: coordinator, path: $path)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }

    private var workoutsForSelectedDate: [Workout] {
        viewModel.getWorkoutsForDate(selectedDate)
    }
}

struct WorkoutListRow: View {
    let workout: Workout
    var coordinator: AppCoordinator
    @Binding var path: NavigationPath

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        HStack(spacing: horizontalSizeClass == .compact ? 12 : 16) {
            // Activity icon
            ZStack {
                Circle()
                    .fill(Color(workout.workoutActivityType.color))
                    .frame(width: horizontalSizeClass == .compact ? 40 : 48, height: horizontalSizeClass == .compact ? 40 : 48)

                Image(systemName: workout.workoutActivityType.iconName)
                    .foregroundColor(.white)
                    .font(.system(size: horizontalSizeClass == .compact ? 16 : 20))
            }

            // Workout details
            VStack(alignment: .leading, spacing: horizontalSizeClass == .compact ? 2 : 4) {
                Text(workout.workoutActivityType.displayName)
                    .font(horizontalSizeClass == .compact ? .subheadline : .headline)
                    .fontWeight(.semibold)

                Text(timeFormatter.string(from: workout.workoutStartDate))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.system(size: horizontalSizeClass == .compact ? 12 : 14))
        }
        .padding(horizontalSizeClass == .compact ? 12 : 16)
        .padding(.vertical, horizontalSizeClass == .compact ? 10 : 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 2, x: 0, y: 1)
        .onTapGesture {
            coordinator.navigateToWorkoutDetail(workoutKey: workout.workoutKey, path: $path)
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutListView(
            coordinator: AppCoordinator(),
            selectedDate: Date(),
            path: .constant(NavigationPath())
        )
    }
}
