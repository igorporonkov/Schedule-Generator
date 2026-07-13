// schedule_generator.go
package main

import (
	"bufio"
	"encoding/csv"
	"encoding/json"
	"flag"
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"strings"
	"time"
)

type ScheduleEntry struct {
	Subject string
	Teacher string
	Room    string
}

type ScheduleGenerator struct {
	Days      int
	Periods   int
	Subjects  []string
	Teachers  []string
	Rooms     []string
	StartTime time.Time
	Duration  int
	Schedule  map[int][]ScheduleEntry
}

func NewScheduleGenerator(days, periods int, subjects, teachers, rooms []string, startTime string, duration int) *ScheduleGenerator {
	st, _ := time.Parse("15:04", startTime)
	return &ScheduleGenerator{
		Days:      days,
		Periods:   periods,
		Subjects:  subjects,
		Teachers:  teachers,
		Rooms:     rooms,
		StartTime: st,
		Duration:  duration,
		Schedule:  make(map[int][]ScheduleEntry),
	}
}

func (sg *ScheduleGenerator) generate() {
	if len(sg.Teachers) < sg.Periods {
		for i := len(sg.Teachers); i < sg.Periods; i++ {
			sg.Teachers = append(sg.Teachers, fmt.Sprintf("T%d", i+1))
		}
	}
	if len(sg.Rooms) < sg.Periods {
		for i := len(sg.Rooms); i < sg.Periods; i++ {
			sg.Rooms = append(sg.Rooms, fmt.Sprintf("R%d", i+1))
		}
	}
	for day := 0; day < sg.Days; day++ {
		daySchedule := make([]ScheduleEntry, sg.Periods)
		teachersShuffled := shuffle(sg.Teachers)
		roomsShuffled := shuffle(sg.Rooms)
		for p := 0; p < sg.Periods; p++ {
			subject := sg.Subjects[rand.Intn(len(sg.Subjects))]
			daySchedule[p] = ScheduleEntry{
				Subject: subject,
				Teacher: teachersShuffled[p%len(teachersShuffled)],
				Room:    roomsShuffled[p%len(roomsShuffled)],
			}
		}
		sg.Schedule[day] = daySchedule
	}
}

func shuffle(slice []string) []string {
	tmp := make([]string, len(slice))
	copy(tmp, slice)
	rand.Shuffle(len(tmp), func(i, j int) { tmp[i], tmp[j] = tmp[j], tmp[i] })
	return tmp
}

func (sg *ScheduleGenerator) display() {
	fmt.Println("\nGenerated Schedule:")
	fmt.Println(strings.Repeat("-", 80))
	fmt.Printf("%-6s %-8s %-14s %-12s %-12s %s\n", "Day", "Period", "Time", "Subject", "Teacher", "Room")
	fmt.Println(strings.Repeat("-", 80))
	for day := 0; day < sg.Days; day++ {
		for period, entry := range sg.Schedule[day] {
			start := sg.StartTime.Add(time.Duration(period*sg.Duration) * time.Minute)
			end := start.Add(time.Duration(sg.Duration) * time.Minute)
			timeStr := fmt.Sprintf("%02d:%02d-%02d:%02d", start.Hour(), start.Minute(), end.Hour(), end.Minute())
			fmt.Printf("%-6d %-8d %-14s %-12s %-12s %s\n", day+1, period+1, timeStr, entry.Subject, entry.Teacher, entry.Room)
		}
	}
}

func (sg *ScheduleGenerator) exportCSV(filename string) {
	file, _ := os.Create(filename)
	defer file.Close()
	writer := csv.NewWriter(file)
	defer writer.Flush()
	writer.Write([]string{"Day", "Period", "Time", "Subject", "Teacher", "Room"})
	for day := 0; day < sg.Days; day++ {
		for period, entry := range sg.Schedule[day] {
			start := sg.StartTime.Add(time.Duration(period*sg.Duration) * time.Minute)
			end := start.Add(time.Duration(sg.Duration) * time.Minute)
			timeStr := fmt.Sprintf("%02d:%02d-%02d:%02d", start.Hour(), start.Minute(), end.Hour(), end.Minute())
			writer.Write([]string{
				strconv.Itoa(day + 1),
				strconv.Itoa(period + 1),
				timeStr,
				entry.Subject,
				entry.Teacher,
				entry.Room,
			})
		}
	}
}

func (sg *ScheduleGenerator) exportJSON(filename string) {
	type Period struct {
		Period  int    `json:"period"`
		Time    string `json:"time"`
		Subject string `json:"subject"`
		Teacher string `json:"teacher"`
		Room    string `json:"room"`
	}
	type DayData struct {
		Day     int      `json:"day"`
		Periods []Period `json:"periods"`
	}
	var data []DayData
	for day := 0; day < sg.Days; day++ {
		var periods []Period
		for period, entry := range sg.Schedule[day] {
			start := sg.StartTime.Add(time.Duration(period*sg.Duration) * time.Minute)
			end := start.Add(time.Duration(sg.Duration) * time.Minute)
			timeStr := fmt.Sprintf("%02d:%02d-%02d:%02d", start.Hour(), start.Minute(), end.Hour(), end.Minute())
			periods = append(periods, Period{
				Period:  period + 1,
				Time:    timeStr,
				Subject: entry.Subject,
				Teacher: entry.Teacher,
				Room:    entry.Room,
			})
		}
		data = append(data, DayData{Day: day + 1, Periods: periods})
	}
	jsonData, _ := json.MarshalIndent(data, "", "  ")
	os.WriteFile(filename, jsonData, 0644)
}

func main() {
	// Interactive mode or CLI
	if len(os.Args) > 1 {
		// CLI mode
		days := flag.Int("days", 5, "Number of days")
		periods := flag.Int("periods", 6, "Periods per day")
		subjectsStr := flag.String("subjects", "Math,Physics,Chemistry,Biology,History", "Subjects")
		teachersStr := flag.String("teachers", "Smith,Jones,Williams,Brown,Davis", "Teachers")
		roomsStr := flag.String("rooms", "101,102,103,104,105", "Rooms")
		startTime := flag.String("start", "09:00", "Start time")
		duration := flag.Int("duration", 45, "Period duration in minutes")
		output := flag.String("output", "", "Output filename")
		flag.Parse()
		subjects := strings.Split(*subjectsStr, ",")
		teachers := strings.Split(*teachersStr, ",")
		rooms := strings.Split(*roomsStr, ",")
		gen := NewScheduleGenerator(*days, *periods, subjects, teachers, rooms, *startTime, *duration)
		gen.generate()
		gen.display()
		if *output != "" {
			if strings.HasSuffix(*output, ".json") {
				gen.exportJSON(*output)
			} else {
				gen.exportCSV(*output)
			}
			fmt.Printf("Saved to %s\n", *output)
		}
	} else {
		// Interactive
		reader := bufio.NewScanner(os.Stdin)
		fmt.Println("=== Schedule Generator ===")
		fmt.Print("Enter number of days (1-7): ")
		reader.Scan()
		days, _ := strconv.Atoi(reader.Text())
		if days < 1 || days > 7 {
			days = 5
		}
		fmt.Print("Enter number of periods per day (1-8): ")
		reader.Scan()
		periods, _ := strconv.Atoi(reader.Text())
		if periods < 1 || periods > 8 {
			periods = 6
		}
		fmt.Print("Enter subjects (comma-separated): ")
		reader.Scan()
		subjects := strings.Split(reader.Text(), ",")
		for i := range subjects {
			subjects[i] = strings.TrimSpace(subjects[i])
		}
		if len(subjects) == 0 {
			subjects = []string{"Math", "Physics", "Chemistry", "Biology", "History"}
		}
		fmt.Print("Enter teachers (comma-separated): ")
		reader.Scan()
		teachers := strings.Split(reader.Text(), ",")
		for i := range teachers {
			teachers[i] = strings.TrimSpace(teachers[i])
		}
		if len(teachers) == 0 {
			teachers = []string{"Smith", "Jones", "Williams", "Brown", "Davis"}
		}
		fmt.Print("Enter rooms (comma-separated): ")
		reader.Scan()
		rooms := strings.Split(reader.Text(), ",")
		for i := range rooms {
			rooms[i] = strings.TrimSpace(rooms[i])
		}
		if len(rooms) == 0 {
			rooms = []string{"101", "102", "103", "104", "105"}
		}
		fmt.Print("Start time (HH:MM, default 09:00): ")
		reader.Scan()
		startTime := reader.Text()
		if startTime == "" {
			startTime = "09:00"
		}
		fmt.Print("Period duration (minutes, default 45): ")
		reader.Scan()
		duration, _ := strconv.Atoi(reader.Text())
		if duration <= 0 {
			duration = 45
		}
		gen := NewScheduleGenerator(days, periods, subjects, teachers, rooms, startTime, duration)
		gen.generate()
		gen.display()
		fmt.Print("Export to file? (y/n): ")
		reader.Scan()
		if strings.ToLower(reader.Text()) == "y" {
			fmt.Print("Filename (e.g., schedule.csv or schedule.json): ")
			reader.Scan()
			fname := reader.Text()
			if strings.HasSuffix(fname, ".json") {
				gen.exportJSON(fname)
			} else {
				gen.exportCSV(fname)
			}
			fmt.Printf("Saved to %s\n", fname)
		}
	}
}
