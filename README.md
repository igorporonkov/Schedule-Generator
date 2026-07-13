🗓️ Schedule Generator – Multi‑Language Edition

A flexible **schedule generator** for educational institutions, training centres, or personal planning.  
Creates a weekly timetable with random assignment of subjects, teachers, and classrooms, while respecting constraints (no overlaps, teacher availability, etc.).  
Built in **7 programming languages** – perfect for learning, automation, or quick scheduling.

## ✨ Features
- **Configurable parameters** – number of days, periods per day, subjects, teachers, rooms.
- **Random assignment** – distributes subjects across the week with no conflicts.
- **Constraints** – each teacher can teach only one class at a time; each room can host only one class.
- **Custom time slots** – set start and end times for each period (optional).
- **Export** – save schedule to CSV or JSON file.
- **Display** – show schedule as a formatted table in the console.
- **Interactive mode** – step‑by‑step input with validation.
- **Command‑line mode** – pass parameters via arguments for scripting.

## 🗂 Languages & Files
| Language          | File                    |
|-------------------|-------------------------|
| Python            | `schedule_generator.py` |
| Go                | `schedule_generator.go` |
| JavaScript (Node) | `schedule_generator.js` |
| C#                | `ScheduleGenerator.cs`  |
| Java              | `ScheduleGenerator.java`|
| Ruby              | `schedule_generator.rb` |
| Swift             | `schedule_generator.swift`|

## 🚀 How to Run
Each file is standalone – run it with the appropriate interpreter/compiler.

| Language | Command (interactive) | Command (CLI) |
|----------|----------------------|---------------|
| Python   | `python schedule_generator.py` | `python schedule_generator.py --days 5 --periods 6 --subjects Math,Physics --teachers Smith,Jones` |
| Go       | `go run schedule_generator.go` | `go run schedule_generator.go -days 5 -periods 6 -subjects Math,Physics -teachers Smith,Jones` |
| JavaScript | `node schedule_generator.js` | `node schedule_generator.js --days 5 --periods 6 --subjects Math,Physics --teachers Smith,Jones` |
| C#       | `dotnet run` | `dotnet run -- --days 5 --periods 6 --subjects Math,Physics --teachers Smith,Jones` |
| Java     | `java ScheduleGenerator` | `java ScheduleGenerator --days 5 --periods 6 --subjects Math,Physics --teachers Smith,Jones` |
| Ruby     | `ruby schedule_generator.rb` | `ruby schedule_generator.rb --days 5 --periods 6 --subjects Math,Physics --teachers Smith,Jones` |
| Swift    | `swift schedule_generator.swift` | `swift schedule_generator.swift --days 5 --periods 6 --subjects Math,Physics --teachers Smith,Jones` |

## 📊 Example Session (Interactive)
=== Schedule Generator ===
Enter number of days (1-7): 5
Enter number of periods per day (1-8): 6
Enter subjects (comma-separated): Math,Physics,Chemistry,Biology,History
Enter teachers (comma-separated): Smith,Jones,Williams,Brown,Davis
Enter rooms (comma-separated): 101,102,103,104
Start time (HH:MM, default 09:00): 09:00
Period duration (minutes, default 45): 45
Generating schedule...

Schedule (Day 1):
Period 1 (09:00-09:45): Math (Smith) in 101
Period 2 (09:45-10:30): Physics (Jones) in 102
...

text

## 🔧 Command‑Line Options
| Option | Description |
|--------|-------------|
| `--days N` | Number of days (default: 5) |
| `--periods N` | Periods per day (default: 6) |
| `--subjects S1,S2` | Comma-separated subject names |
| `--teachers T1,T2` | Comma-separated teacher names |
| `--rooms R1,R2` | Comma-separated room numbers |
| `--start TIME` | Start time (HH:MM, default: 09:00) |
| `--duration M` | Period duration in minutes (default: 45) |
| `--output FILE` | Export to CSV or JSON (auto-detect from extension) |

## 📁 Export Format (CSV)
A table with days as rows and periods as columns, each cell containing subject, teacher, room.

## 🤝 Contributing
Add support for groups, parallel classes, or more complex constraints – PRs welcome!

## 📜 License
MIT – use freely.
