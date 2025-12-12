//
//  CalendarView.swift
//  Training calendar
//
//  Created by Madi Sharipov on 11.12.2025.
//

import SwiftUI

struct CalendarView: View {
    var coordinator: AppCoordinator
    @Binding var path: NavigationPath
    @StateObject private var viewModel = CalendarViewModel()

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        VStack(spacing: 16) {
            // Month navigation header
            monthNavigationHeader

            // Weekday headers
            weekdayHeaders

            // Calendar grid
            calendarGrid

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .navigationTitle("Календарь тренировок")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadWorkouts()
        }
    }

    private var monthNavigationHeader: some View {
        HStack {
            Button(action: {
                viewModel.goToPreviousMonth()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .font(.title2)
            }

            Spacer()

            Text(viewModel.monthName)
                .font(.title2)
                .fontWeight(.semibold)

            Spacer()

            Button(action: {
                viewModel.goToNextMonth()
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
                    .font(.title2)
            }
        }
        .padding(.horizontal)
    }

    private var weekdayHeaders: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"], id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(height: 32)
            }
        }
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(viewModel.daysInCurrentMonth, id: \.self) { date in
                DayCell(
                    date: date,
                    viewModel: viewModel,
                    coordinator: coordinator,
                    path: $path
                )
            }
        }
    }
}

struct DayCell: View {
    let date: Date
    @ObservedObject var viewModel: CalendarViewModel
    var coordinator: AppCoordinator
    @Binding var path: NavigationPath

    private let calendar = Calendar.current

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
                .frame(minHeight: 44, maxHeight: 48)

            VStack(spacing: horizontalSizeClass == .compact ? 4 : 6) { // Увеличенный отступ
                Text(viewModel.getDayNumber(for: date))
                    .font(.system(horizontalSizeClass == .compact ? .callout : .body, design: .rounded, weight: .medium))
                    .foregroundColor(textColor)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                    .accessibilityLabel("\(viewModel.getDayNumber(for: date)) \(viewModel.getWeekdayName(for: date))")
                    .accessibilityAddTraits(viewModel.isToday(date) ? .isSelected : [])

                if viewModel.hasWorkoutsOnDate(date) {
                    Capsule()
                        .fill(Color.red) // Более яркий цвет
                        .frame(width: horizontalSizeClass == .compact ? 16 : 20, height: horizontalSizeClass == .compact ? 3 : 4) // Шире и заметнее
                        .accessibilityHidden(true) // Purely decorative
                }
            }
        }
        .onTapGesture {
            viewModel.selectDate(date)
            path.append(date)
        }
    }

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var backgroundColor: Color {
        let opacity = colorScheme == .dark ? 0.3 : 0.2
        if viewModel.isSelectedDate(date) {
            return Color.accentColor.opacity(opacity)
        } else if viewModel.isToday(date) {
            return Color.green.opacity(colorScheme == .dark ? 0.25 : 0.15)
        } else {
            return Color(.systemGray6).opacity(colorScheme == .dark ? 0.3 : 0.5)
        }
    }

    private var textColor: Color {
        if viewModel.isSelectedDate(date) {
            return .accentColor
        } else if viewModel.isToday(date) {
            return .green
        } else if viewModel.isCurrentMonth(date) {
            return .primary
        } else {
            return .secondary
        }
    }
}

#Preview {
    CalendarView(coordinator: AppCoordinator(), path: .constant(NavigationPath()))
}
