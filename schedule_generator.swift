// schedule_generator.swift
import Foundation

struct ScheduleEntry {
    let subject: String
    let teacher: String
    let room: String
}

class ScheduleGenerator {
    var days: Int
    var periods: Int
    var subjects: [String]
    var teachers: [String]
    var rooms: [String]
    var startTime: Date
    var duration: Int
    var schedule: [Int: [ScheduleEntry]] = [:]

    init(days: Int = 5, periods: Int = 6, subjects: [String]? = nil, teachers: [String]? = nil,
         rooms: [String]? = nil, startTime: String = "09:00", duration: Int = 45) {
        self.days = days
        self.periods = periods
        self.subjects = subjects ?? ["Math", "Physics", "Chemistry", "Biology", "History"]
        self.teachers = teachers ?? ["Smith", "Jones", "Williams", "Brown", "Davis"]
        self.rooms = rooms ?? ["101", "102", "103", "104", "105"]
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        self.startTime = formatter.date(from: startTime) ?? formatter.date(from: "09:00")!
        self.duration = duration
    }

    func generate() {
        if teachers.count < periods {
            for i in teachers.count..<periods {
                teachers.append("T\(i+1)")
            }
        }
        if rooms.count < periods {
            for i in rooms.count..<periods {
                rooms.append("R\(i+1)")
            }
        }
        for day in 0..<days {
            var daySchedule: [ScheduleEntry] = []
            let teachersShuffled = teachers.shuffled()
            let roomsShuffled = rooms.shuffled()
            for p in 0..<periods {
                let subject = subjects.randomElement()!
                let entry = ScheduleEntry(
                    subject: subject,
                    teacher: teachersShuffled[p % teachersShuffled.count],
                    room: roomsShuffled[p % roomsShuffled.count]
                )
                daySchedule.append(entry)
            }
            schedule[day] = daySchedule
        }
    }

    func display() {
        print("\nGenerated Schedule:")
        print(String(repeating: "-", count: 80))
        print(String(format: "%-6s %-8s %-14s %-12s %-12s %s", "Day", "Period", "Time", "Subject", "Teacher", "Room"))
        print(String(repeating: "-", count: 80))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        for day in 0..<days {
            guard let daySchedule = schedule[day] else { continue }
            for p in 0..<periods {
                let entry = daySchedule[p]
                let start = startTime.addingTimeInterval(TimeInterval(p * duration * 60))
                let end = start.addingTimeInterval(TimeInterval(duration * 60))
                let timeStr = "\(formatter.string(from: start))-\(formatter.string(from: end))"
                print(String(format: "%-6d %-8d %-14s %-12s %-12s %s", day+1, p+1, timeStr, entry.subject, entry.teacher, entry.room))
            }
        }
    }

    func exportCSV(filename: String) {
        var lines = ["Day,Period,Time,Subject,Teacher,Room"]
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        for day in 0..<days {
            guard let daySchedule = schedule[day] else { continue }
            for p in 0..<periods {
                let entry = daySchedule[p]
                let start = startTime.addingTimeInterval(TimeInterval(p * duration * 60))
                let end = start.addingTimeInterval(TimeInterval(duration * 60))
                let timeStr = "\(formatter.string(from: start))-\(formatter.string(from: end))"
                lines.append("\(day+1),\(p+1),\(timeStr),\(entry.subject),\(entry.teacher),\(entry.room)")
            }
        }
        try? lines.joined(separator: "\n").write(toFile: filename, atomically: true, encoding: .utf8)
    }

    func exportJSON(filename: String) {
        var data: [[String: Any]] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        for day in 0..<days {
            guard let daySchedule = schedule[day] else { continue }
            var periodsData: [[String: Any]] = []
            for p in 0..<periods {
                let entry = daySchedule[p]
                let start = startTime.addingTimeInterval(TimeInterval(p * duration * 60))
                let end = start.addingTimeInterval(TimeInterval(duration * 60))
                let timeStr = "\(formatter.string(from: start))-\(formatter.string(from: end))"
                periodsData.append([
                    "period": p+1,
                    "time": timeStr,
                    "subject": entry.subject,
                    "teacher": entry.teacher,
                    "room": entry.room
                ])
            }
            data.append(["day": day+1, "periods": periodsData])
        }
        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) {
            try? jsonData.write(to: URL(fileURLWithPath: filename))
        }
    }
}

func interactive() {
    print("=== Schedule Generator ===")
    print("Enter number of days (1-7): ", terminator: "")
    guard let daysStr = readLine(), let days = Int(daysStr), days >= 1, days <= 7 else {
        print("Invalid days, using default 5")
        let days = 5
    }
    print("Enter number of periods per day (1-8): ", terminator: "")
    guard let periodsStr = readLine(), let periods = Int(periodsStr), periods >= 1, periods <= 8 else {
        print("Invalid periods, using default 6")
        let periods = 6
    }
    print("Enter subjects (comma-separated): ", terminator: "")
    let subjectsStr = readLine() ?? ""
    let subjects = subjectsStr.isEmpty ? nil : subjectsStr.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    print("Enter teachers (comma-separated): ", terminator: "")
    let teachersStr = readLine() ?? ""
    let teachers = teachersStr.isEmpty ? nil : teachersStr.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    print("Enter rooms (comma-separated): ", terminator: "")
    let roomsStr = readLine() ?? ""
    let rooms = roomsStr.isEmpty ? nil : roomsStr.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    print("Start time (HH:MM, default 09:00): ", terminator: "")
    let startTime = readLine() ?? "09:00"
    print("Period duration (minutes, default 45): ", terminator: "")
    let durationStr = readLine() ?? "45"
    let duration = Int(durationStr) ?? 45
    let gen = ScheduleGenerator(
        days: days,
        periods: periods,
        subjects: subjects,
        teachers: teachers,
        rooms: rooms,
        startTime: startTime,
        duration: duration
    )
    gen.generate()
    gen.display()
    print("Export to file? (y/n): ", terminator: "")
    guard let export = readLine()?.lowercased(), export == "y" else { return }
    print("Filename (e.g., schedule.csv or schedule.json): ", terminator: "")
    let fname = readLine() ?? "schedule.csv"
    if fname.hasSuffix(".json") {
        gen.exportJSON(filename: fname)
    } else {
        gen.exportCSV(filename: fname)
    }
    print("Saved to \(fname)")
}

func cli() {
    let args = CommandLine.arguments.dropFirst()
    var params: [String: String] = [:]
    var i = 0
    while i < args.count {
        let arg = args[i]
        if arg.hasPrefix("--") {
            let key = String(arg.dropFirst(2))
            if i+1 < args.count && !args[i+1].hasPrefix("--") {
                params[key] = args[i+1]
                i += 2
            } else {
                params[key] = "true"
                i += 1
            }
        } else {
            i += 1
        }
    }
    let days = Int(params["days"] ?? "5") ?? 5
    let periods = Int(params["periods"] ?? "6") ?? 6
    let subjects = params["subjects"]?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    let teachers = params["teachers"]?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    let rooms = params["rooms"]?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    let startTime = params["start"] ?? "09:00"
    let duration = Int(params["duration"] ?? "45") ?? 45
    let output = params["output"]
    let gen = ScheduleGenerator(
        days: days,
        periods: periods,
        subjects: subjects,
        teachers: teachers,
        rooms: rooms,
        startTime: startTime,
        duration: duration
    )
    gen.generate()
    gen.display()
    if let out = output {
        if out.hasSuffix(".json") {
            gen.exportJSON(filename: out)
        } else {
            gen.exportCSV(filename: out)
        }
        print("Saved to \(out)")
    }
}

if CommandLine.arguments.count > 1 {
    cli()
} else {
    interactive()
}
