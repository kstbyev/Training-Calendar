//
//  Training_calendarTests.swift
//  Training calendarTests
//
//  Created by Madi Sharipov on 11.12.2025.
//

import XCTest
@testable import Training_calendar

final class Training_calendarTests: XCTestCase {

    var viewModel: CalendarViewModel!
    var mockAPIService: MockAPIService!

    override func setUpWithError() throws {
        viewModel = CalendarViewModel()
        mockAPIService = MockAPIService.shared
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }

    func testLoadWorkouts() throws {
        // Given
        let expectation = XCTestExpectation(description: "Workouts loaded")

        // When
        viewModel.loadWorkouts()

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertFalse(self.viewModel.workouts.isEmpty, "Workouts should be loaded")
            XCTAssertEqual(self.viewModel.workouts.count, 9, "Should load 9 workouts")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testMonthNavigation() throws {
        // Given
        let initialMonth = viewModel.currentMonth
        let calendar = Calendar.current

        // When - Go to next month
        viewModel.goToNextMonth()

        // Then
        if let expectedNextMonth = calendar.date(byAdding: .month, value: 1, to: initialMonth) {
            XCTAssertEqual(viewModel.currentMonth, expectedNextMonth, "Should navigate to next month")
        }

        // When - Go to previous month
        viewModel.goToPreviousMonth()

        // Then
        XCTAssertEqual(viewModel.currentMonth, initialMonth, "Should navigate back to initial month")
    }

    func testDateSelection() throws {
        // Given
        let testDate = Date()

        // When
        viewModel.selectDate(testDate)

        // Then
        XCTAssertEqual(viewModel.selectedDate, testDate, "Selected date should be set")
    }

    func testWorkoutsFilteringByDate() throws {
        // Given
        viewModel.loadWorkouts()

        // When
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Test date with workouts (25 ноября 2025)
            let dateWithWorkouts = self.createDate("2025-11-25")
            let workoutsForDate = self.viewModel.getWorkoutsForDate(dateWithWorkouts)

            // Then
            XCTAssertEqual(workoutsForDate.count, 2, "Should have 2 workouts on Nov 25")

            // Test date without workouts
            let dateWithoutWorkouts = self.createDate("2025-11-26")
            let noWorkouts = self.viewModel.getWorkoutsForDate(dateWithoutWorkouts)

            XCTAssertEqual(noWorkouts.count, 0, "Should have no workouts on Nov 26")
        }
    }

    func testHasWorkoutsOnDate() throws {
        // Given
        viewModel.loadWorkouts()

        // When
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let dateWithWorkouts = self.createDate("2025-11-25")
            let dateWithoutWorkouts = self.createDate("2025-11-26")

            // Then
            XCTAssertTrue(self.viewModel.hasWorkoutsOnDate(dateWithWorkouts), "Should have workouts on Nov 25")
            XCTAssertFalse(self.viewModel.hasWorkoutsOnDate(dateWithoutWorkouts), "Should not have workouts on Nov 26")
        }
    }

    func testDateFormatting() throws {
        // Given
        let date = createDate("2025-11-25")

        // Then
        XCTAssertEqual(viewModel.getDayNumber(for: date), "25", "Should format day number correctly")
        XCTAssertEqual(viewModel.getWeekdayName(for: date), "Вт", "Should format weekday correctly")
    }

    func testTodayDetection() throws {
        // Given
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        // Then
        XCTAssertTrue(viewModel.isToday(today), "Should detect today correctly")
        XCTAssertFalse(viewModel.isToday(yesterday), "Should not detect yesterday as today")
    }

    // MARK: - Helper Methods

    private func createDate(_ dateString: String) -> Date {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        if let isoDate = isoFormatter.date(from: dateString) {
            return isoDate
        }
        
        // Fallback to custom formatter
        if let date = DateFormatter.iso8601CustomFormatter.date(from: dateString) {
            return date
        }
        
        // If all fails, return current date or throw an error
        return Date()
    }
}
