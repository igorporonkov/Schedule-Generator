# schedule_generator.rb
require 'json'
require 'optparse'
require 'time'

class ScheduleGenerator
  attr_reader :days, :periods, :subjects, :teachers, :rooms, :start_time, :duration, :schedule

  def initialize(days: 5, periods: 6, subjects: nil, teachers: nil, rooms: nil, start_time: '09:00', duration: 45)
    @days = days
    @periods = periods
    @subjects = subjects || ['Math', 'Physics', 'Chemistry', 'Biology', 'History']
    @teachers = teachers || ['Smith', 'Jones', 'Williams', 'Brown', 'Davis']
    @rooms = rooms || ['101', '102', '103', '104', '105']
    @start_time = Time.parse(start_time)
    @duration = duration
    @schedule = {}
  end

  def generate
    if @teachers.size < @periods
      (@teachers.size...@periods).each { |i| @teachers << "T#{i+1}" }
    end
    if @rooms.size < @periods
      (@rooms.size...@periods).each { |i| @rooms << "R#{i+1}" }
    end
    @days.times do |day|
      day_schedule = []
      teachers_shuffled = @teachers.shuffle
      rooms_shuffled = @rooms.shuffle
      @periods.times do |p|
        subject = @subjects.sample
        day_schedule << {
          subject: subject,
          teacher: teachers_shuffled[p % teachers_shuffled.size],
          room: rooms_shuffled[p % rooms_shuffled.size]
        }
      end
      @schedule[day] = day_schedule
    end
  end

  def display
    puts "\nGenerated Schedule:"
    puts '-' * 80
    printf "%-6s %-8s %-14s %-12s %-12s %s\n", "Day", "Period", "Time", "Subject", "Teacher", "Room"
    puts '-' * 80
    @days.times do |day|
      @periods.times do |p|
        entry = @schedule[day][p]
        start_t = @start_time + p * @duration * 60
        end_t = start_t + @duration * 60
        time_str = "#{start_t.strftime('%H:%M')}-#{end_t.strftime('%H:%M')}"
        printf "%-6d %-8d %-14s %-12s %-12s %s\n", day+1, p+1, time_str, entry[:subject], entry[:teacher], entry[:room]
      end
    end
  end

  def export_csv(filename)
    CSV.open(filename, 'w') do |csv|
      csv << ['Day', 'Period', 'Time', 'Subject', 'Teacher', 'Room']
      @days.times do |day|
        @periods.times do |p|
          entry = @schedule[day][p]
          start_t = @start_time + p * @duration * 60
          end_t = start_t + @duration * 60
          time_str = "#{start_t.strftime('%H:%M')}-#{end_t.strftime('%H:%M')}"
          csv << [day+1, p+1, time_str, entry[:subject], entry[:teacher], entry[:room]]
        end
      end
    end
  end

  def export_json(filename)
    data = []
    @days.times do |day|
      periods_data = []
      @periods.times do |p|
        entry = @schedule[day][p]
        start_t = @start_time + p * @duration * 60
        end_t = start_t + @duration * 60
        time_str = "#{start_t.strftime('%H:%M')}-#{end_t.strftime('%H:%M')}"
        periods_data << {
          period: p+1,
          time: time_str,
          subject: entry[:subject],
          teacher: entry[:teacher],
          room: entry[:room]
        }
      end
      data << { day: day+1, periods: periods_data }
    end
    File.write(filename, JSON.pretty_generate(data))
  end
end

def interactive
  require 'csv'
  puts "=== Schedule Generator ==="
  print "Enter number of days (1-7): "
  days = gets.to_i
  days = 5 if days < 1 || days > 7
  print "Enter number of periods per day (1-8): "
  periods = gets.to_i
  periods = 6 if periods < 1 || periods > 8
  print "Enter subjects (comma-separated): "
  subjects = gets.chomp.split(',').map(&:strip)
  subjects = ['Math', 'Physics', 'Chemistry', 'Biology', 'History'] if subjects.empty?
  print "Enter teachers (comma-separated): "
  teachers = gets.chomp.split(',').map(&:strip)
  teachers = ['Smith', 'Jones', 'Williams', 'Brown', 'Davis'] if teachers.empty?
  print "Enter rooms (comma-separated): "
  rooms = gets.chomp.split(',').map(&:strip)
  rooms = ['101', '102', '103', '104', '105'] if rooms.empty?
  print "Start time (HH:MM, default 09:00): "
  start_time = gets.chomp
  start_time = '09:00' if start_time.empty?
  print "Period duration (minutes, default 45): "
  duration = gets.to_i
  duration = 45 if duration <= 0
  gen = ScheduleGenerator.new(days: days, periods: periods, subjects: subjects, teachers: teachers,
                              rooms: rooms, start_time: start_time, duration: duration)
  gen.generate
  gen.display
  print "Export to file? (y/n): "
  if gets.chomp.downcase == 'y'
    print "Filename (e.g., schedule.csv or schedule.json): "
    fname = gets.chomp
    if fname.end_with?('.json')
      gen.export_json(fname)
    else
      gen.export_csv(fname)
    end
    puts "Saved to #{fname}"
  end
end

def cli
  options = {}
  OptionParser.new do |opts|
    opts.on('--days N', Integer) { |v| options[:days] = v }
    opts.on('--periods N', Integer) { |v| options[:periods] = v }
    opts.on('--subjects S', String) { |v| options[:subjects] = v }
    opts.on('--teachers T', String) { |v| options[:teachers] = v }
    opts.on('--rooms R', String) { |v| options[:rooms] = v }
    opts.on('--start TIME', String) { |v| options[:start] = v }
    opts.on('--duration N', Integer) { |v| options[:duration] = v }
    opts.on('--output FILE', String) { |v| options[:output] = v }
  end.parse!
  days = options[:days] || 5
  periods = options[:periods] || 6
  subjects = options[:subjects] ? options[:subjects].split(',').map(&:strip) : nil
  teachers = options[:teachers] ? options[:teachers].split(',').map(&:strip) : nil
  rooms = options[:rooms] ? options[:rooms].split(',').map(&:strip) : nil
  start_time = options[:start] || '09:00'
  duration = options[:duration] || 45
  output = options[:output]
  gen = ScheduleGenerator.new(days: days, periods: periods, subjects: subjects, teachers: teachers,
                              rooms: rooms, start_time: start_time, duration: duration)
  gen.generate
  gen.display
  if output
    if output.end_with?('.json')
      gen.export_json(output)
    else
      require 'csv'
      gen.export_csv(output)
    end
    puts "Saved to #{output}"
  end
end

if ARGV.empty?
  interactive
else
  cli
end
