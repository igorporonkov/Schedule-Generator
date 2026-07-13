// schedule_generator.js
const fs = require('fs');
const readline = require('readline');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

class ScheduleGenerator {
    constructor(days = 5, periods = 6, subjects = [], teachers = [], rooms = [], startTime = "09:00", duration = 45) {
        this.days = days;
        this.periods = periods;
        this.subjects = subjects.length ? subjects : ["Math", "Physics", "Chemistry", "Biology", "History"];
        this.teachers = teachers.length ? teachers : ["Smith", "Jones", "Williams", "Brown", "Davis"];
        this.rooms = rooms.length ? rooms : ["101", "102", "103", "104", "105"];
        const [h, m] = startTime.split(':').map(Number);
        this.startTime = new Date();
        this.startTime.setHours(h || 9, m || 0, 0, 0);
        this.duration = duration;
        this.schedule = {};
    }

    generate() {
        if (this.teachers.length < this.periods) {
            for (let i = this.teachers.length; i < this.periods; i++) {
                this.teachers.push(`T${i+1}`);
            }
        }
        if (this.rooms.length < this.periods) {
            for (let i = this.rooms.length; i < this.periods; i++) {
                this.rooms.push(`R${i+1}`);
            }
        }
        for (let day = 0; day < this.days; day++) {
            const daySchedule = [];
            const teachersShuffled = this.shuffle([...this.teachers]);
            const roomsShuffled = this.shuffle([...this.rooms]);
            for (let p = 0; p < this.periods; p++) {
                const subject = this.subjects[Math.floor(Math.random() * this.subjects.length)];
                daySchedule.push({
                    subject,
                    teacher: teachersShuffled[p % teachersShuffled.length],
                    room: roomsShuffled[p % roomsShuffled.length]
                });
            }
            this.schedule[day] = daySchedule;
        }
    }

    shuffle(arr) {
        for (let i = arr.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [arr[i], arr[j]] = [arr[j], arr[i]];
        }
        return arr;
    }

    display() {
        console.log('\nGenerated Schedule:');
        console.log('-'.repeat(80));
        console.log(`${'Day'.padEnd(6)} ${'Period'.padEnd(8)} ${'Time'.padEnd(14)} ${'Subject'.padEnd(12)} ${'Teacher'.padEnd(12)} Room`);
        console.log('-'.repeat(80));
        for (let day = 0; day < this.days; day++) {
            for (let p = 0; p < this.periods; p++) {
                const entry = this.schedule[day][p];
                const start = new Date(this.startTime);
                start.setMinutes(start.getMinutes() + p * this.duration);
                const end = new Date(start);
                end.setMinutes(end.getMinutes() + this.duration);
                const timeStr = `${String(start.getHours()).padStart(2,'0')}:${String(start.getMinutes()).padStart(2,'0')}-${String(end.getHours()).padStart(2,'0')}:${String(end.getMinutes()).padStart(2,'0')}`;
                console.log(`${String(day+1).padEnd(6)} ${String(p+1).padEnd(8)} ${timeStr.padEnd(14)} ${entry.subject.padEnd(12)} ${entry.teacher.padEnd(12)} ${entry.room}`);
            }
        }
    }

    exportCSV(filename) {
        const rows = [['Day', 'Period', 'Time', 'Subject', 'Teacher', 'Room']];
        for (let day = 0; day < this.days; day++) {
            for (let p = 0; p < this.periods; p++) {
                const entry = this.schedule[day][p];
                const start = new Date(this.startTime);
                start.setMinutes(start.getMinutes() + p * this.duration);
                const end = new Date(start);
                end.setMinutes(end.getMinutes() + this.duration);
                const timeStr = `${String(start.getHours()).padStart(2,'0')}:${String(start.getMinutes()).padStart(2,'0')}-${String(end.getHours()).padStart(2,'0')}:${String(end.getMinutes()).padStart(2,'0')}`;
                rows.push([day+1, p+1, timeStr, entry.subject, entry.teacher, entry.room]);
            }
        }
        const content = rows.map(row => row.join(',')).join('\n');
        fs.writeFileSync(filename, content);
    }

    exportJSON(filename) {
        const data = [];
        for (let day = 0; day < this.days; day++) {
            const periods = [];
            for (let p = 0; p < this.periods; p++) {
                const entry = this.schedule[day][p];
                const start = new Date(this.startTime);
                start.setMinutes(start.getMinutes() + p * this.duration);
                const end = new Date(start);
                end.setMinutes(end.getMinutes() + this.duration);
                const timeStr = `${String(start.getHours()).padStart(2,'0')}:${String(start.getMinutes()).padStart(2,'0')}-${String(end.getHours()).padStart(2,'0')}:${String(end.getMinutes()).padStart(2,'0')}`;
                periods.push({ period: p+1, time: timeStr, subject: entry.subject, teacher: entry.teacher, room: entry.room });
            }
            data.push({ day: day+1, periods });
        }
        fs.writeFileSync(filename, JSON.stringify(data, null, 2));
    }
}

function ask(question) {
    return new Promise(resolve => rl.question(question, resolve));
}

async function interactive() {
    console.log('=== Schedule Generator ===');
    const days = parseInt(await ask('Enter number of days (1-7): ') || '5');
    const periods = parseInt(await ask('Enter number of periods per day (1-8): ') || '6');
    const subjectsStr = await ask('Enter subjects (comma-separated): ');
    const subjects = subjectsStr ? subjectsStr.split(',').map(s => s.trim()).filter(s => s) : undefined;
    const teachersStr = await ask('Enter teachers (comma-separated): ');
    const teachers = teachersStr ? teachersStr.split(',').map(s => s.trim()).filter(s => s) : undefined;
    const roomsStr = await ask('Enter rooms (comma-separated): ');
    const rooms = roomsStr ? roomsStr.split(',').map(s => s.trim()).filter(s => s) : undefined;
    const startTime = await ask('Start time (HH:MM, default 09:00): ') || '09:00';
    const duration = parseInt(await ask('Period duration (minutes, default 45): ') || '45');
    const gen = new ScheduleGenerator(days, periods, subjects, teachers, rooms, startTime, duration);
    gen.generate();
    gen.display();
    const exportAns = await ask('Export to file? (y/n): ');
    if (exportAns.toLowerCase() === 'y') {
        const fname = await ask('Filename (e.g., schedule.csv or schedule.json): ');
        if (fname.endsWith('.json')) {
            gen.exportJSON(fname);
        } else {
            gen.exportCSV(fname);
        }
        console.log(`Saved to ${fname}`);
    }
    rl.close();
}

function cli() {
    const args = require('minimist')(process.argv.slice(2));
    const days = args.days || 5;
    const periods = args.periods || 6;
    const subjects = args.subjects ? args.subjects.split(',').map(s => s.trim()) : undefined;
    const teachers = args.teachers ? args.teachers.split(',').map(s => s.trim()) : undefined;
    const rooms = args.rooms ? args.rooms.split(',').map(s => s.trim()) : undefined;
    const startTime = args.start || '09:00';
    const duration = args.duration || 45;
    const output = args.output;
    const gen = new ScheduleGenerator(days, periods, subjects, teachers, rooms, startTime, duration);
    gen.generate();
    gen.display();
    if (output) {
        if (output.endsWith('.json')) {
            gen.exportJSON(output);
        } else {
            gen.exportCSV(output);
        }
        console.log(`Saved to ${output}`);
    }
}

if (process.argv.length > 2) {
    cli();
} else {
    interactive();
}
