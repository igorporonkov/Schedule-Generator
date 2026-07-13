# schedule_generator.py
import sys
import argparse
import random
import csv
import json
from datetime import datetime, timedelta

class ScheduleGenerator:
    def __init__(self, days=5, periods=6, subjects=None, teachers=None, rooms=None,
                 start_time="09:00", duration=45):
        self.days = days
        self.periods = periods
        self.subjects = subjects or ["Math", "Physics", "Chemistry", "Biology", "History"]
        self.teachers = teachers or ["Smith", "Jones", "Williams", "Brown", "Davis"]
        self.rooms = rooms or ["101", "102", "103", "104", "105"]
        self.start_time = datetime.strptime(start_time, "%H:%M")
        self.duration = duration
        self.schedule = {}  # day -> list of (subject, teacher, room)

    def generate(self):
        # Ensure enough teachers and rooms for each period
        if len(self.teachers) < self.periods:
            print("Warning: Not enough teachers, adding dummy ones.")
            for i in range(self.periods - len(self.teachers)):
                self.teachers.append(f"T{i+1}")
        if len(self.rooms) < self.periods:
            print("Warning: Not enough rooms, adding dummy ones.")
            for i in range(self.periods - len(self.rooms)):
                self.rooms.append(f"R{i+1}")

        for day in range(self.days):
            day_schedule = []
            # Shuffle teachers and rooms for this day
            teachers_shuffled = random.sample(self.teachers, self.periods)
            rooms_shuffled = random.sample(self.rooms, self.periods)
            # Assign subjects randomly (allow repeats)
            subjects_shuffled = [random.choice(self.subjects) for _ in range(self.periods)]
            for p in range(self.periods):
                day_schedule.append((subjects_shuffled[p], teachers_shuffled[p], rooms_shuffled[p]))
            self.schedule[day] = day_schedule

    def display(self):
        print("\nGenerated Schedule:")
        print("-" * 80)
        print(f"{'Day':<6} {'Period':<8} {'Time':<14} {'Subject':<12} {'Teacher':<12} {'Room'}")
        print("-" * 80)
        for day in range(self.days):
            for period, (subject, teacher, room) in enumerate(self.schedule[day], start=1):
                start = self.start_time + timedelta(minutes=(period-1)*self.duration)
                end = start + timedelta(minutes=self.duration)
                time_str = f"{start.strftime('%H:%M')}-{end.strftime('%H:%M')}"
                print(f"{day+1:<6} {period:<8} {time_str:<14} {subject:<12} {teacher:<12} {room}")

    def export_csv(self, filename):
        with open(filename, 'w', newline='') as f:
            writer = csv.writer(f)
            header = ["Day", "Period", "Time", "Subject", "Teacher", "Room"]
            writer.writerow(header)
            for day in range(self.days):
                for period, (subject, teacher, room) in enumerate(self.schedule[day], start=1):
                    start = self.start_time + timedelta(minutes=(period-1)*self.duration)
                    end = start + timedelta(minutes=self.duration)
                    time_str = f"{start.strftime('%H:%M')}-{end.strftime('%H:%M')}"
                    writer.writerow([day+1, period, time_str, subject, teacher, room])

    def export_json(self, filename):
        data = []
        for day in range(self.days):
            day_data = []
            for period, (subject, teacher, room) in enumerate(self.schedule[day], start=1):
                start = self.start_time + timedelta(minutes=(period-1)*self.duration)
                end = start + timedelta(minutes=self.duration)
                day_data.append({
                    "period": period,
                    "time": f"{start.strftime('%H:%M')}-{end.strftime('%H:%M')}",
                    "subject": subject,
                    "teacher": teacher,
                    "room": room
                })
            data.append({"day": day+1, "periods": day_data})
        with open(filename, 'w') as f:
            json.dump(data, f, indent=2)

def interactive():
    print("=== Schedule Generator ===")
    days = int(input("Enter number of days (1-7): ") or "5")
    periods = int(input("Enter number of periods per day (1-8): ") or "6")
    subjects = input("Enter subjects (comma-separated): ").split(',')
    subjects = [s.strip() for s in subjects if s.strip()]
    if not subjects:
        subjects = ["Math", "Physics", "Chemistry", "Biology", "History"]
    teachers = input("Enter teachers (comma-separated): ").split(',')
    teachers = [t.strip() for t in teachers if t.strip()]
    if not teachers:
        teachers = ["Smith", "Jones", "Williams", "Brown", "Davis"]
    rooms = input("Enter rooms (comma-separated): ").split(',')
    rooms = [r.strip() for r in rooms if r.strip()]
    if not rooms:
        rooms = ["101", "102", "103", "104", "105"]
    start_time = input("Start time (HH:MM, default 09:00): ") or "09:00"
    duration = int(input("Period duration (minutes, default 45): ") or "45")
    gen = ScheduleGenerator(days, periods, subjects, teachers, rooms, start_time, duration)
    gen.generate()
    gen.display()
    export = input("Export to file? (y/n): ").strip().lower()
    if export == 'y':
        fname = input("Filename (e.g., schedule.csv or schedule.json): ")
        if fname.endswith('.json'):
            gen.export_json(fname)
        else:
            gen.export_csv(fname)
        print(f"Saved to {fname}")

def cli():
    parser = argparse.ArgumentParser(description='Schedule Generator')
    parser.add_argument('--days', type=int, default=5, help='Number of days')
    parser.add_argument('--periods', type=int, default=6, help='Periods per day')
    parser.add_argument('--subjects', default='Math,Physics,Chemistry,Biology,History', help='Comma-separated subjects')
    parser.add_argument('--teachers', default='Smith,Jones,Williams,Brown,Davis', help='Comma-separated teachers')
    parser.add_argument('--rooms', default='101,102,103,104,105', help='Comma-separated rooms')
    parser.add_argument('--start', default='09:00', help='Start time HH:MM')
    parser.add_argument('--duration', type=int, default=45, help='Period duration in minutes')
    parser.add_argument('--output', help='Output filename (CSV or JSON)')
    args = parser.parse_args()
    subjects = [s.strip() for s in args.subjects.split(',')]
    teachers = [t.strip() for t in args.teachers.split(',')]
    rooms = [r.strip() for r in args.rooms.split(',')]
    gen = ScheduleGenerator(args.days, args.periods, subjects, teachers, rooms, args.start, args.duration)
    gen.generate()
    gen.display()
    if args.output:
        if args.output.endswith('.json'):
            gen.export_json(args.output)
        else:
            gen.export_csv(args.output)
        print(f"Saved to {args.output}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        cli()
    else:
        interactive()
