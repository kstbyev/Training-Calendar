import SwiftUI

final class AppCoordinator {
    func navigateToWorkoutList(for date: Date, path: Binding<NavigationPath>) {
        path.wrappedValue.append(date)
    }

    func navigateToWorkoutDetail(workoutKey: String, path: Binding<NavigationPath>) {
        path.wrappedValue.append(workoutKey)
    }

    func goBack(path: Binding<NavigationPath>) {
        path.wrappedValue.removeLast()
    }

    func goBackToRoot(path: Binding<NavigationPath>) {
        path.wrappedValue.removeLast(path.wrappedValue.count)
    }

    @ViewBuilder
    func buildRootView(path: Binding<NavigationPath>) -> some View {
        NavigationStack(path: path) {
            CalendarView(coordinator: self, path: path)
                .navigationDestination(for: Date.self) { date in
                    WorkoutListView(coordinator: self, selectedDate: date, path: path)
                }
                .navigationDestination(for: String.self) { workoutKey in
                    WorkoutDetailView(coordinator: self, workoutKey: workoutKey, path: path)
                }
        }
    }
}

