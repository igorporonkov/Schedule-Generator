// ScheduleGenerator.cs
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;

class ScheduleEntry
{
    public string Subject { get; set; }
    public string Teacher { get; set; }
    public string Room { get; set; }
}

class ScheduleGenerator
{
    public int Days { get; set; }
    public int Periods { get; set; }
    public List<string> Subjects { get; set; }
    public List<string> Teachers { get; set; }
    public List<string> Rooms { get; set; }
    public DateTime StartTime { get; set; }
    public int Duration { get; set; }
    public Dictionary<int, List<ScheduleEntry>> Schedule { get; set; }

    public ScheduleGenerator(int days, int periods, List<string> subjects, List<string> teachers,
                            List<string> rooms, string startTime, int duration)
    {
        Days = days;
        Periods = periods;
        Subjects = subjects ?? new List<string> { "Math", "Physics", "Chemistry", "Biology", "History" };
        Teachers = teachers ?? new List<string> { "Smith", "Jones", "Williams", "Brown", "Davis" };
        Rooms = rooms ?? new List<string> { "101", "102", "103", "104", "105" };
        StartTime = DateTime.ParseExact(startTime, "HH:mm", null);
        Duration = duration;
        Schedule = new Dictionary<int, List<ScheduleEntry>>();
    }

    public void Generate()
    {
        if (Teachers.Count < Periods)
        {
            for (int i = Teachers.Count; i < Periods; i++)
                Teachers.Add($"T{i+1}");
        }
        if (Rooms.Count < Periods)
        {
            for (int i = Rooms.Count; i < Periods; i++)
                Rooms.Add($"R{i+1}");
        }
        Random rand = new Random();
        for (int day = 0; day < Days; day++)
        {
            var daySchedule = new List<ScheduleEntry>();
            var teachersShuffled = Teachers.OrderBy(x => rand.Next()).ToList();
            var roomsShuffled = Rooms.OrderBy(x => rand.Next()).ToList();
            for (int p = 0; p < Periods; p++)
            {
                string subject = Subjects[rand.Next(Subjects.Count)];
                daySchedule.Add(new ScheduleEntry
                {
                    Subject = subject,
                    Teacher = teachersShuffled[p % teachersShuffled.Count],
                    Room = roomsShuffled[p % roomsShuffled.Count]
                });
            }
            Schedule[day] = daySchedule;
        }
    }

    public void Display()
    {
        Console.WriteLine("\nGenerated Schedule:");
        Console.WriteLine(new string('-', 80));
        Console.WriteLine($"{"Day",-6} {"Period",-8} {"Time",-14} {"Subject",-12} {"Teacher",-12} Room");
        Console.WriteLine(new string('-', 80));
        for (int day = 0; day < Days; day++)
        {
            for (int p = 0; p < Periods; p++)
            {
                var entry = Schedule[day][p];
                var start = StartTime.AddMinutes(p * Duration);
                var end = start.AddMinutes(Duration);
                string timeStr = $"{start:HH:mm}-{end:HH:mm}";
                Console.WriteLine($"{day+1,-6} {p+1,-8} {timeStr,-14} {entry.Subject,-12} {entry.Teacher,-12} {entry.Room}");
            }
        }
    }

    public void ExportCSV(string filename)
    {
        using var writer = new StreamWriter(filename);
        writer.WriteLine("Day,Period,Time,Subject,Teacher,Room");
        for (int day = 0; day < Days; day++)
        {
            for (int p = 0; p < Periods; p++)
            {
                var entry = Schedule[day][p];
                var start = StartTime.AddMinutes(p * Duration);
                var end = start.AddMinutes(Duration);
                string timeStr = $"{start:HH:mm}-{end:HH:mm}";
                writer.WriteLine($"{day+1},{p+1},{timeStr},{entry.Subject},{entry.Teacher},{entry.Room}");
            }
        }
    }

    public void ExportJSON(string filename)
    {
        var data = new List<object>();
        for (int day = 0; day < Days; day++)
        {
            var periods = new List<object>();
            for (int p = 0; p < Periods; p++)
            {
                var entry = Schedule[day][p];
                var start = StartTime.AddMinutes(p * Duration);
                var end = start.AddMinutes(Duration);
                string timeStr = $"{start:HH:mm}-{end:HH:mm}";
                periods.Add(new { period = p+1, time = timeStr, subject = entry.Subject, teacher = entry.Teacher, room = entry.Room });
            }
            data.Add(new { day = day+1, periods });
        }
        string json = JsonSerializer.Serialize(data, new JsonSerializerOptions { WriteIndented = true });
        File.WriteAllText(filename, json);
    }

    static void Main(string[] args)
    {
        if (args.Length > 0)
        {
            // CLI mode
            var dict = new Dictionary<string, string>();
            for (int i = 0; i < args.Length; i++)
            {
                if (args[i].StartsWith("--"))
                {
                    string key = args[i].Substring(2);
                    if (i + 1 < args.Length && !args[i + 1].StartsWith("--"))
                        dict[key] = args[++i];
                    else
                        dict[key] = "true";
                }
            }
            int days = dict.ContainsKey("days") ? int.Parse(dict["days"]) : 5;
            int periods = dict.ContainsKey("periods") ? int.Parse(dict["periods"]) : 6;
            var subjects = dict.ContainsKey("subjects") ? dict["subjects"].Split(',').Select(s => s.Trim()).ToList() : null;
            var teachers = dict.ContainsKey("teachers") ? dict["teachers"].Split(',').Select(s => s.Trim()).ToList() : null;
            var rooms = dict.ContainsKey("rooms") ? dict["rooms"].Split(',').Select(s => s.Trim()).ToList() : null;
            string startTime = dict.ContainsKey("start") ? dict["start"] : "09:00";
            int duration = dict.ContainsKey("duration") ? int.Parse(dict["duration"]) : 45;
            string output = dict.ContainsKey("output") ? dict["output"] : null;
            var gen = new ScheduleGenerator(days, periods, subjects, teachers, rooms, startTime, duration);
            gen.Generate();
            gen.Display();
            if (output != null)
            {
                if (output.EndsWith(".json"))
                    gen.ExportJSON(output);
                else
                    gen.ExportCSV(output);
                Console.WriteLine($"Saved to {output}");
            }
        }
        else
        {
            Console.WriteLine("=== Schedule Generator ===");
            Console.Write("Enter number of days (1-7): ");
            int days = int.Parse(Console.ReadLine() ?? "5");
            Console.Write("Enter number of periods per day (1-8): ");
            int periods = int.Parse(Console.ReadLine() ?? "6");
            Console.Write("Enter subjects (comma-separated): ");
            var subjects = Console.ReadLine()?.Split(',').Select(s => s.Trim()).ToList() ?? new List<string>();
            if (subjects.Count == 0) subjects = new List<string> { "Math", "Physics", "Chemistry", "Biology", "History" };
            Console.Write("Enter teachers (comma-separated): ");
            var teachers = Console.ReadLine()?.Split(',').Select(s => s.Trim()).ToList() ?? new List<string>();
            if (teachers.Count == 0) teachers = new List<string> { "Smith", "Jones", "Williams", "Brown", "Davis" };
            Console.Write("Enter rooms (comma-separated): ");
            var rooms = Console.ReadLine()?.Split(',').Select(s => s.Trim()).ToList() ?? new List<string>();
            if (rooms.Count == 0) rooms = new List<string> { "101", "102", "103", "104", "105" };
            Console.Write("Start time (HH:MM, default 09:00): ");
            string startTime = Console.ReadLine();
            if (string.IsNullOrEmpty(startTime)) startTime = "09:00";
            Console.Write("Period duration (minutes, default 45): ");
            int duration = int.Parse(Console.ReadLine() ?? "45");
            var gen = new ScheduleGenerator(days, periods, subjects, teachers, rooms, startTime, duration);
            gen.Generate();
            gen.Display();
            Console.Write("Export to file? (y/n): ");
            if (Console.ReadLine()?.ToLower() == "y")
            {
                Console.Write("Filename (e.g., schedule.csv or schedule.json): ");
                string fname = Console.ReadLine();
                if (fname.EndsWith(".json"))
                    gen.ExportJSON(fname);
                else
                    gen.ExportCSV(fname);
                Console.WriteLine($"Saved to {fname}");
            }
        }
    }
}
