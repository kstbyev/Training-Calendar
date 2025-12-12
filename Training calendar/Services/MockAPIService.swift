//
//  MockAPIService.swift
//  Training calendar
//
//  Created by Madi Sharipov on 11.12.2025.
//

import Foundation

class MockAPIService {
    static let shared = MockAPIService()

    private init() {}

    // MARK: - JSON Response Models

    private struct WorkoutListResponse: Codable {
        let description: String
        let data: [Workout]
    }

    private struct WorkoutMetadataResponse: Codable {
        let description: String
        let workouts: [String: WorkoutMetadata]
    }

    private struct DiagramDataResponse: Codable {
        let description: String
        let workouts: [String: WorkoutDiagramData]
    }

    // MARK: - List Workouts

    func getListWorkouts(email: String, lastDate: String) -> [Workout] {
        // Simulate API response by loading from JSON file
        guard let response: WorkoutListResponse = loadJSON(from: "list_workouts") else {
            return []
        }
        return response.data
    }

    // MARK: - Workout Metadata

    func getWorkoutMetadata(workoutId: String, email: String) -> WorkoutMetadata? {
        // Simulate API response by loading from JSON file
        guard let response: WorkoutMetadataResponse = loadJSON(from: "workout_metadata") else {
            return nil
        }
        return response.workouts[workoutId]
    }

    // MARK: - Diagram Data

    func getDiagramData(workoutId: String, email: String) -> [DiagramDataPoint]? {
        // Simulate API response by loading from JSON file
        guard let response: DiagramDataResponse = loadJSON(from: "diagram_data") else {
            return nil
        }
        return response.workouts[workoutId]?.data
    }

    // MARK: - Helper Methods

    private func loadJSON<T: Decodable>(from filename: String) -> T? {
        // First try to load from bundle with subdirectory
        if let url = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "Resources"),
           let data = try? Data(contentsOf: url) {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
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
                    
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string: \(dateString)")
                }
                return try decoder.decode(T.self, from: data)
            } catch {
                print("Error decoding \(filename).json from bundle: \(error)")
            }
        }

        // Fallback: load embedded JSON strings
        print("Loading embedded \(filename) data")
        return loadEmbeddedJSON(from: filename)
    }

    private func loadEmbeddedJSON<T: Decodable>(from filename: String) -> T? {
        let jsonString: String

        switch filename {
        case "list_workouts":
            jsonString = """
            {
                "description": "GET /list_workouts?email=test@gmail.com&lastDate=2020-01-01",
                "data": [
                    {
                        "workoutKey": "7823456789012345",
                        "workoutActivityType": "Walking/Running",
                        "workoutStartDate": "2025-11-25T09:30:00Z"
                    },
                    {
                        "workoutKey": "7823456789012346",
                        "workoutActivityType": "Yoga",
                        "workoutStartDate": "2025-11-25T18:00:00Z"
                    },
                    {
                        "workoutKey": "7823456789012347",
                        "workoutActivityType": "Water",
                        "workoutStartDate": "2025-11-24T07:15:00Z"
                    },
                    {
                        "workoutKey": "7823456789012348",
                        "workoutActivityType": "Walking/Running",
                        "workoutStartDate": "2025-11-24T17:45:00Z"
                    },
                    {
                        "workoutKey": "7823456789012349",
                        "workoutActivityType": "Cycling",
                        "workoutStartDate": "2025-11-23T10:00:00Z"
                    },
                    {
                        "workoutKey": "7823456789012350",
                        "workoutActivityType": "Walking/Running",
                        "workoutStartDate": "2025-11-22T08:30:00Z"
                    },
                    {
                        "workoutKey": "7823456789012351",
                        "workoutActivityType": "Yoga",
                        "workoutStartDate": "2025-11-22T19:00:00Z"
                    },
                    {
                        "workoutKey": "7823456789012352",
                        "workoutActivityType": "Water",
                        "workoutStartDate": "2025-11-21T06:45:00Z"
                    },
                    {
                        "workoutKey": "7823456789012353",
                        "workoutActivityType": "Strength",
                        "workoutStartDate": "2025-11-21T16:30:00Z"
                    }
                ]
            }
            """

        case "workout_metadata":
            jsonString = """
            {
                "description": "GET /metadata?workoutId={workoutKey}&email=test@gmail.com",
                "workouts": {
                    "7823456789012345": {
                        "workoutKey": "7823456789012345",
                        "workoutActivityType": "Walking/Running",
                        "workoutStartDate": "2025-11-25T09:30:00Z",
                        "distance": "5230.50",
                        "duration": "2700.00",
                        "maxLayer": 2,
                        "maxSubLayer": 4,
                        "avg_humidity": "65.00",
                        "avg_temp": "12.50",
                        "comment": "Утренняя пробежка в парке",
                        "photoBefore": null,
                        "photoAfter": null,
                        "heartRateGraph": "/static/test@gmail.com/7823456789012345/heartrate_plot.png",
                        "activityGraph": "/static/test@gmail.com/7823456789012345/activity_plot.png",
                        "map": "/static/test@gmail.com/7823456789012345/map_plot.html"
                    },
                    "7823456789012346": {
                        "workoutKey": "7823456789012346",
                        "workoutActivityType": "Yoga",
                        "workoutStartDate": "2025-11-25T18:00:00Z",
                        "distance": "0.00",
                        "duration": "3600.00",
                        "maxLayer": 1,
                        "maxSubLayer": 8,
                        "avg_humidity": "45.00",
                        "avg_temp": "22.00",
                        "comment": "Вечерняя йога для расслабления",
                        "photoBefore": null,
                        "photoAfter": null,
                        "heartRateGraph": "/static/test@gmail.com/7823456789012346/heartrate_plot.png",
                        "activityGraph": "/static/test@gmail.com/7823456789012346/activity_plot.png",
                        "map": null
                    },
                    "7823456789012347": {
                        "workoutKey": "7823456789012347",
                        "workoutActivityType": "Water",
                        "workoutStartDate": "2025-11-24T07:15:00Z",
                        "distance": "1500.00",
                        "duration": "2400.00",
                        "maxLayer": 3,
                        "maxSubLayer": 6,
                        "avg_humidity": "80.00",
                        "avg_temp": "4.50",
                        "comment": "Моржевание в озере",
                        "photoBefore": "/static/test@gmail.com/7823456789012347/photo_before.jpg",
                        "photoAfter": "/static/test@gmail.com/7823456789012347/photo_after.jpg",
                        "heartRateGraph": "/static/test@gmail.com/7823456789012347/heartrate_plot.png",
                        "activityGraph": "/static/test@gmail.com/7823456789012347/activity_plot.png",
                        "map": "/static/test@gmail.com/7823456789012347/map_plot.html"
                    },
                    "7823456789012348": {
                        "workoutKey": "7823456789012348",
                        "workoutActivityType": "Walking/Running",
                        "workoutStartDate": "2025-11-24T17:45:00Z",
                        "distance": "8120.00",
                        "duration": "4200.00",
                        "maxLayer": 3,
                        "maxSubLayer": 5,
                        "avg_humidity": "58.00",
                        "avg_temp": "8.00",
                        "comment": "Вечерний бег по набережной",
                        "photoBefore": null,
                        "photoAfter": null,
                        "heartRateGraph": "/static/test@gmail.com/7823456789012348/heartrate_plot.png",
                        "activityGraph": "/static/test@gmail.com/7823456789012348/activity_plot.png",
                        "map": "/static/test@gmail.com/7823456789012348/map_plot.html"
                    },
                    "7823456789012349": {
                        "workoutKey": "7823456789012349",
                        "workoutActivityType": "Cycling",
                        "workoutStartDate": "2025-11-23T10:00:00Z",
                        "distance": "25430.00",
                        "duration": "5400.00",
                        "maxLayer": 2,
                        "maxSubLayer": 3,
                        "avg_humidity": "55.00",
                        "avg_temp": "14.00",
                        "comment": "Велопрогулка за городом",
                        "photoBefore": null,
                        "photoAfter": "/static/test@gmail.com/7823456789012349/photo_after.jpg",
                        "heartRateGraph": "/static/test@gmail.com/7823456789012349/heartrate_plot.png",
                        "activityGraph": "/static/test@gmail.com/7823456789012349/activity_plot.png",
                        "map": "/static/test@gmail.com/7823456789012349/map_plot.html"
                    },
                    "7823456789012350": {
                        "workoutKey": "7823456789012350",
                        "workoutActivityType": "Walking/Running",
                        "workoutStartDate": "2025-11-22T08:30:00Z",
                        "distance": "10250.00",
                        "duration": "5040.00",
                        "maxLayer": 3,
                        "maxSubLayer": 6,
                        "avg_humidity": "70.00",
                        "avg_temp": "6.00",
                        "comment": "Длинная пробежка",
                        "photoBefore": null,
                        "photoAfter": null,
                        "heartRateGraph": "/static/test@gmail.com/7823456789012350/heartrate_plot.png",
                        "activityGraph": "/static/test@gmail.com/7823456789012350/activity_plot.png",
                        "map": "/static/test@gmail.com/7823456789012350/map_plot.html"
                    },
                    "7823456789012351": {
                        "workoutKey": "7823456789012351",
                        "workoutActivityType": "Yoga",
                        "workoutStartDate": "2025-11-22T19:00:00Z",
                        "distance": "0.00",
                        "duration": "2700.00",
                        "maxLayer": 1,
                        "maxSubLayer": 6,
                        "avg_humidity": "42.00",
                        "avg_temp": "21.00",
                        "comment": "Хатха-йога",
                        "photoBefore": null,
                        "photoAfter": null,
                        "heartRateGraph": "/static/test@gmail.com/7823456789012351/heartrate_plot.png",
                        "activityGraph": "/static/test@gmail.com/7823456789012351/activity_plot.png",
                        "map": null
                    },
                    "7823456789012352": {
                        "workoutKey": "7823456789012352",
                        "workoutActivityType": "Water",
                        "workoutStartDate": "2025-11-21T06:45:00Z",
                        "distance": "800.00",
                        "duration": "1800.00",
                        "maxLayer": 2,
                        "maxSubLayer": 4,
                        "avg_humidity": "85.00",
                        "avg_temp": "3.00",
                        "comment": "Утреннее закаливание",
                        "photoBefore": "/static/test@gmail.com/7823456789012352/photo_before.jpg",
                        "photoAfter": "/static/test@gmail.com/7823456789012352/photo_after.jpg",
                        "heartRateGraph": "/static/test@gmail.com/7823456789012352/heartrate_plot.png",
                        "activityGraph": "/static/test@gmail.com/7823456789012352/activity_plot.png",
                        "map": "/static/test@gmail.com/7823456789012352/map_plot.html"
                    },
                    "7823456789012353": {
                        "workoutKey": "7823456789012353",
                        "workoutActivityType": "Strength",
                        "workoutStartDate": "2025-11-21T16:30:00Z",
                        "distance": "0.00",
                        "duration": "4500.00",
                        "maxLayer": 4,
                        "maxSubLayer": 8,
                        "avg_humidity": "40.00",
                        "avg_temp": "20.00",
                        "comment": "Силовая тренировка в зале",
                        "photoBefore": null,
                        "photoAfter": null,
                        "heartRateGraph": "/static/test@gmail.com/7823456789012353/heartrate_plot.png",
                        "activityGraph": "/static/test@gmail.com/7823456789012353/activity_plot.png",
                        "map": null
                    }
                }
            }
            """

        case "diagram_data":
            jsonString = """
            {
                "description": "GET /get_diagram_data?workoutId={workoutKey}&email=test@gmail.com",
                "workouts": {
                    "7823456789012345": {
                        "description": "Walking/Running - 25 ноября, утренняя пробежка",
                        "data": [
                            {"time_numeric": 0, "heartRate": 72, "speed_kmh": 0.0, "distanceMeters": 0, "steps": 0, "elevation": 45.2, "latitude": 55.7558, "longitude": 37.6173, "temperatureCelsius": 12.5, "currentLayer": 0, "currentSubLayer": 0, "currentTimestamp": "2025-11-25T09:30:00Z"},
                            {"time_numeric": 1, "heartRate": 85, "speed_kmh": 6.2, "distanceMeters": 103, "steps": 120, "elevation": 45.5, "latitude": 55.7562, "longitude": 37.6180, "temperatureCelsius": 12.5, "currentLayer": 0, "currentSubLayer": 0, "currentTimestamp": "2025-11-25T09:31:00Z"},
                            {"time_numeric": 2, "heartRate": 92, "speed_kmh": 7.8, "distanceMeters": 233, "steps": 265, "elevation": 46.1, "latitude": 55.7568, "longitude": 37.6189, "temperatureCelsius": 12.4, "currentLayer": 0, "currentSubLayer": 1, "currentTimestamp": "2025-11-25T09:32:00Z"},
                            {"time_numeric": 3, "heartRate": 98, "speed_kmh": 8.4, "distanceMeters": 373, "steps": 420, "elevation": 46.8, "latitude": 55.7575, "longitude": 37.6198, "temperatureCelsius": 12.4, "currentLayer": 0, "currentSubLayer": 1, "currentTimestamp": "2025-11-25T09:33:00Z"},
                            {"time_numeric": 4, "heartRate": 105, "speed_kmh": 9.1, "distanceMeters": 525, "steps": 590, "elevation": 47.2, "latitude": 55.7583, "longitude": 37.6210, "temperatureCelsius": 12.3, "currentLayer": 0, "currentSubLayer": 2, "currentTimestamp": "2025-11-25T09:34:00Z"},
                            {"time_numeric": 5, "heartRate": 112, "speed_kmh": 9.5, "distanceMeters": 683, "steps": 768, "elevation": 47.5, "latitude": 55.7592, "longitude": 37.6222, "temperatureCelsius": 12.3, "currentLayer": 0, "currentSubLayer": 2, "currentTimestamp": "2025-11-25T09:35:00Z"},
                            {"time_numeric": 6, "heartRate": 118, "speed_kmh": 9.8, "distanceMeters": 846, "steps": 952, "elevation": 48.0, "latitude": 55.7601, "longitude": 37.6235, "temperatureCelsius": 12.2, "currentLayer": 1, "currentSubLayer": 0, "currentTimestamp": "2025-11-25T09:36:00Z"},
                            {"time_numeric": 7, "heartRate": 122, "speed_kmh": 10.2, "distanceMeters": 1016, "steps": 1145, "elevation": 48.3, "latitude": 55.7611, "longitude": 37.6248, "temperatureCelsius": 12.2, "currentLayer": 1, "currentSubLayer": 0, "currentTimestamp": "2025-11-25T09:37:00Z"},
                            {"time_numeric": 8, "heartRate": 128, "speed_kmh": 10.5, "distanceMeters": 1191, "steps": 1342, "elevation": 48.8, "latitude": 55.7621, "longitude": 37.6262, "temperatureCelsius": 12.1, "currentLayer": 1, "currentSubLayer": 1, "currentTimestamp": "2025-11-25T09:38:00Z"},
                            {"time_numeric": 9, "heartRate": 132, "speed_kmh": 10.8, "distanceMeters": 1371, "steps": 1548, "elevation": 49.2, "latitude": 55.7632, "longitude": 37.6276, "temperatureCelsius": 12.1, "currentLayer": 1, "currentSubLayer": 1, "currentTimestamp": "2025-11-25T09:39:00Z"},
                            {"time_numeric": 10, "heartRate": 135, "speed_kmh": 11.0, "distanceMeters": 1555, "steps": 1758, "elevation": 49.5, "latitude": 55.7643, longitude": 37.6291, "temperatureCelsius": 12.0, "currentLayer": 1, "currentSubLayer": 2, "currentTimestamp": "2025-11-25T09:40:00Z"},
                            {"time_numeric": 11, "heartRate": 138, "speed_kmh": 10.6, "distanceMeters": 1732, "steps": 1962, "elevation": 50.0, "latitude": 55.7655, "longitude": 37.6306, "temperatureCelsius": 12.0, "currentLayer": 1, "currentSubLayer": 2, "currentTimestamp": "2025-11-25T09:41:00Z"},
                            {"time_numeric": 12, "heartRate": 140, "speed_kmh": 10.3, "distanceMeters": 1904, "steps": 2160, "elevation": 50.3, "latitude": 55.7667, "longitude": 37.6320, "temperatureCelsius": 11.9, "currentLayer": 1, "currentSubLayer": 3, "currentTimestamp": "2025-11-25T09:42:00Z"},
                            {"time_numeric": 13, "heartRate": 142, "speed_kmh": 9.9, "distanceMeters": 2069, "steps": 2352, "elevation": 50.8, "latitude": 55.7678, "longitude": 37.6335, "temperatureCelsius": 11.9, "currentLayer": 1, "currentSubLayer": 3, "currentTimestamp": "2025-11-25T09:43:00Z"},
                            {"time_numeric": 14, "heartRate": 144, "speed_kmh": 9.5, "distanceMeters": 2227, "steps": 2538, "elevation": 51.2, "latitude": 55.7690, "longitude": 37.6349, "temperatureCelsius": 11.8, "currentLayer": 2, "currentSubLayer": 0, "currentTimestamp": "2025-11-25T09:44:00Z"},
                            {"time_numeric": 15, "heartRate": 145, "speed_kmh": 9.2, "distanceMeters": 2380, "steps": 2718, "elevation": 51.5, "latitude": 55.7701, "longitude": 37.6363, "temperatureCelsius": 11.8, "currentLayer": 2, "currentSubLayer": 0, "currentTimestamp": "2025-11-25T09:45:00Z"},
                            {"time_numeric": 16, "heartRate": 143, "speed_kmh": 8.8, "distanceMeters": 2527, "steps": 2892, "elevation": 51.8, "latitude": 55.7712, "longitude": 37.6377, "temperatureCelsius": 11.7, "currentLayer": 2, "currentSubLayer": 1, "currentTimestamp": "2025-11-25T09:46:00Z"},
                            {"time_numeric": 17, "heartRate": 140, "speed_kmh": 8.5, "distanceMeters": 2669, "steps": 3060, "elevation": 52.0, "latitude": 55.7723, "longitude": 37.6390, "temperatureCelsius": 11.7, "currentLayer": 2, "currentSubLayer": 1, "currentTimestamp": "2025-11-25T09:47:00Z"},
                            {"time_numeric": 18, "heartRate": 136, "speed_kmh": 8.2, "distanceMeters": 2806, "steps": 3222, "elevation": 52.3, "latitude": 55.7734, "longitude": 37.6403, "temperatureCelsius": 11.6, "currentLayer": 2, "currentSubLayer": 2, "currentTimestamp": "2025-11-25T09:48:00Z"},
                            {"time_numeric": 19, "heartRate": 132, "speed_kmh": 7.8, "distanceMeters": 2936, "steps": 3378, "elevation": 52.5, "latitude": 55.7744, "longitude": 37.6415, "temperatureCelsius": 11.6, "currentLayer": 2, "currentSubLayer": 2, "currentTimestamp": "2025-11-25T09:49:00Z"},
                            {"time_numeric": 20, "heartRate": 128, "speed_kmh": 7.4, "distanceMeters": 3059, "steps": 3528, "elevation": 52.7, "latitude": 55.7754, "longitude": 37.6427, "temperatureCelsius": 11.5, "currentLayer": 2, "currentSubLayer": 3, "currentTimestamp": "2025-11-25T09:50:00Z"}
                        ],
                        "states": []
                    }
                }
            }
            """

        default:
            return nil
        }

        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)

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

                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string: \(dateString)")
            }
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Error decoding embedded \(filename) JSON: \(error)")
            return nil
        }
    }
}