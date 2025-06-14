import Foundation

enum Milestone: String, Codable, CaseIterable {
    case oneDay = "24_hours"
    case threeDays = "3_days"
    case oneWeek = "1_week"
    case twoWeeks = "2_weeks"
    case oneMonth = "1_month"

    var name: String {
        switch self {
        case .oneDay:
            return "24 Hours"
        case .threeDays:
            return "3 Days"
        case .oneWeek:
            return "1 Week"
        case .twoWeeks:
            return "2 Weeks"
        case .oneMonth:
            return "1 Month"
        }
    }
} 