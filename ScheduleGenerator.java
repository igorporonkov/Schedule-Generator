// ScheduleGenerator.java
import java.io.*;
import java.nio.file.*;
import java.time.*;
import java.time.format.*;
import java.util.*;
import com.google.gson.*;

class ScheduleEntry {
    String subject;
    String teacher;
    String room;
}

class PeriodData {
    int period;
    String time;
    String subject;
    String teacher;
    String room;
}

class DayData {
    int day;
    List<PeriodData> periods;
}

public class ScheduleGenerator {
    private int days;
    private int periods;
    private List<String> subjects;
    private List<String> teachers;
    private List<String> rooms;
    private LocalTime startTime;
    private int duration;
    private Map<Integer, List<ScheduleEntry>> schedule = new HashMap<>();
    private Random rand = new Random();

    public ScheduleGenerator(int days, int periods, List<String> subjects, List<String> teachers,
                             List<String> rooms, String startTime, int duration) {
        this.days = days;
        this.periods = periods;
        this.subjects = subjects != null && !subjects.isEmpty() ? subjects :
                Arrays.asList("Math", "Physics", "Chemistry", "Biology", "History");
        this.teachers = teachers != null && !teachers.isEmpty() ? teachers :
                Arrays.asList("Smith", "Jones", "Williams", "Brown", "Davis");
        this.rooms = rooms != null && !rooms.isEmpty() ? rooms :
                Arrays.asList("101", "102", "103", "104", "105");
        this.startTime = LocalTime.parse(startTime, DateTimeFormatter.ofPattern("HH:mm"));
        this.duration = duration;
    }

    public void generate() {
        if (teachers.size() < periods) {
            for (int i = teachers.size(); i < periods; i++)
                teachers.add("T" + (i+1));
        }
        if (rooms.size() < periods) {
            for (int i = rooms.size(); i < periods; i++)
                rooms.add("R" + (i+1));
        }
        for (int day = 0; day < days; day++) {
            List<ScheduleEntry> daySchedule = new ArrayList<>();
            List<String> teachersShuffled = new ArrayList<>(teachers);
            Collections.shuffle(teachersShuffled, rand);
            List<String> roomsShuffled = new ArrayList<>(rooms);
            Collections.shuffle(roomsShuffled, rand);
            for (int p = 0; p < periods; p++) {
                String subject = subjects.get(rand.nextInt(subjects.size()));
                ScheduleEntry entry = new ScheduleEntry();
                entry.subject = subject;
                entry.teacher = teachersShuffled.get(p % teachersShuffled.size());
                entry.room = roomsShuffled.get(p % roomsShuffled.size());
                daySchedule.add(entry);
            }
            schedule.put(day, daySchedule);
        }
    }

    public void display() {
        System.out.println("\nGenerated Schedule:");
        System.out.println(new String(new char[80]).replace('\0', '-'));
        System.out.printf("%-6s %-8s %-14s %-12s %-12s %s%n", "Day", "Period", "Time", "Subject", "Teacher", "Room");
        System.out.println(new String(new char[80]).replace('\0', '-'));
        for (int day = 0; day < days; day++) {
            for (int p = 0; p < periods; p++) {
                ScheduleEntry entry = schedule.get(day).get(p);
                LocalTime start = startTime.plusMinutes(p * duration);
                LocalTime end = start.plusMinutes(duration);
                String timeStr = String.format("%02d:%02d-%02d:%02d", start.getHour(), start.getMinute(), end.getHour(), end.getMinute());
                System.out.printf("%-6d %-8d %-14s %-12s %-12s %s%n", day+1, p+1, timeStr, entry.subject, entry.teacher, entry.room);
            }
        }
    }

    public void exportCSV(String filename) throws IOException {
        try (PrintWriter pw = new PrintWriter(filename)) {
            pw.println("Day,Period,Time,Subject,Teacher,Room");
            for (int day = 0; day < days; day++) {
                for (int p = 0; p < periods; p++) {
                    ScheduleEntry entry = schedule.get(day).get(p);
                    LocalTime start = startTime.plusMinutes(p * duration);
                    LocalTime end = start.plusMinutes(duration);
                    String timeStr = String.format("%02d:%02d-%02d:%02d", start.getHour(), start.getMinute(), end.getHour(), end.getMinute());
                    pw.printf("%d,%d,%s,%s,%s,%s%n", day+1, p+1, timeStr, entry.subject, entry.teacher, entry.room);
                }
            }
        }
    }

    public void exportJSON(String filename) throws IOException {
        List<DayData> data = new ArrayList<>();
        for (int day = 0; day < days; day++) {
            DayData dd = new DayData();
            dd.day = day+1;
            dd.periods = new ArrayList<>();
            for (int p = 0; p < periods; p++) {
                ScheduleEntry entry = schedule.get(day).get(p);
                LocalTime start = startTime.plusMinutes(p * duration);
                LocalTime end = start.plusMinutes(duration);
                String timeStr = String.format("%02d:%02d-%02d:%02d", start.getHour(), start.getMinute(), end.getHour(), end.getMinute());
                PeriodData pd = new PeriodData();
                pd.period = p+1;
                pd.time = timeStr;
                pd.subject = entry.subject;
                pd.teacher = entry.teacher;
                pd.room = entry.room;
                dd.periods.add(pd);
            }
            data.add(dd);
        }
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        String json = gson.toJson(data);
        Files.write(Paths.get(filename), json.getBytes());
    }

    public static void main(String[] args) throws Exception {
        if (args.length > 0) {
            // CLI mode
            Map<String, String> params = new HashMap<>();
            for (int i = 0; i < args.length; i++) {
                if (args[i].startsWith("--")) {
                    String key = args[i].substring(2);
                    if (i+1 < args.length && !args[i+1].startsWith("--"))
                        params.put(key, args[++i]);
                    else
                        params.put(key, "true");
                }
            }
            int days = params.containsKey("days") ? Integer.parseInt(params.get("days")) : 5;
            int periods = params.containsKey("periods") ? Integer.parseInt(params.get("periods")) : 6;
            List<String> subjects = params.containsKey("subjects") ? Arrays.asList(params.get("subjects").split(",")) : null;
            List<String> teachers = params.containsKey("teachers") ? Arrays.asList(params.get("teachers").split(",")) : null;
            List<String> rooms = params.containsKey("rooms") ? Arrays.asList(params.get("rooms").split(",")) : null;
            String startTime = params.getOrDefault("start", "09:00");
            int duration = params.containsKey("duration") ? Integer.parseInt(params.get("duration")) : 45;
            String output = params.get("output");
            ScheduleGenerator gen = new ScheduleGenerator(days, periods, subjects, teachers, rooms, startTime, duration);
            gen.generate();
            gen.display();
            if (output != null) {
                if (output.endsWith(".json"))
                    gen.exportJSON(output);
                else
                    gen.exportCSV(output);
                System.out.println("Saved to " + output);
            }
        } else {
            // Interactive
            Scanner scanner = new Scanner(System.in);
            System.out.println("=== Schedule Generator ===");
            System.out.print("Enter number of days (1-7): ");
            int days = scanner.nextInt();
            System.out.print("Enter number of periods per day (1-8): ");
            int periods = scanner.nextInt();
            scanner.nextLine(); // consume newline
            System.out.print("Enter subjects (comma-separated): ");
            String subjectsLine = scanner.nextLine();
            List<String> subjects = subjectsLine.isEmpty() ? null : Arrays.asList(subjectsLine.split(","));
            System.out.print("Enter teachers (comma-separated): ");
            String teachersLine = scanner.nextLine();
            List<String> teachers = teachersLine.isEmpty() ? null : Arrays.asList(teachersLine.split(","));
            System.out.print("Enter rooms (comma-separated): ");
            String roomsLine = scanner.nextLine();
            List<String> rooms = roomsLine.isEmpty() ? null : Arrays.asList(roomsLine.split(","));
            System.out.print("Start time (HH:MM, default 09:00): ");
            String startTime = scanner.nextLine();
            if (startTime.isEmpty()) startTime = "09:00";
            System.out.print("Period duration (minutes, default 45): ");
            int duration = scanner.nextInt();
            scanner.nextLine();
            ScheduleGenerator gen = new ScheduleGenerator(days, periods, subjects, teachers, rooms, startTime, duration);
            gen.generate();
            gen.display();
            System.out.print("Export to file? (y/n): ");
            if (scanner.nextLine().toLowerCase().equals("y")) {
                System.out.print("Filename (e.g., schedule.csv or schedule.json): ");
                String fname = scanner.nextLine();
                if (fname.endsWith(".json"))
                    gen.exportJSON(fname);
                else
                    gen.exportCSV(fname);
                System.out.println("Saved to " + fname);
            }
            scanner.close();
        }
    }
}
