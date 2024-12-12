use crate::backup::Backup;
use crate::config::ScheduleConfig;
use chrono::{Datelike, Duration, Local, Weekday};
use log::info;
use tokio::time::sleep;

#[derive(Clone, Debug)]
pub struct Schedule {
    pub frequency: String,
    pub time: String,
}

impl Schedule {
    pub fn to_config(&self) -> crate::config::ScheduleConfig {
        ScheduleConfig {
            frequency: self.frequency.clone(),
            time: self.time.clone(),
        }
    }
}

pub struct BackupRotationConfig {
    pub max_backups: usize,
}

pub struct Scheduler {
    schedule: Schedule,
    backup: Backup,
}

impl Scheduler {
    pub fn new(schedule: Schedule, backup: Backup) -> Self {
        Scheduler { schedule, backup }
    }

    pub fn start(&self) {
        let schedule = self.schedule.clone();
        let mut backup = self.backup.clone();
        tokio::spawn(async move {
            loop {
                let now = Local::now().naive_local();
                let scheduled_time = match schedule.frequency.as_str() {
                    "daily" => {
                        let parts: Vec<&str> = schedule.time.split(':').collect();
                        if parts.len() != 2 {
                            info!("Invalid time format for scheduling.");
                            continue;
                        }
                        let hour: u32 = parts[0].parse().unwrap_or(0);
                        let minute: u32 = parts[1].parse().unwrap_or(0);
                        Local::now()
                            .date_naive()
                            .and_hms_opt(hour, minute, 0)
                            .unwrap()
                    }
                    "weekly" => {
                        // For simplicity, assume weekly schedule is every Monday at specified time
                        let parts: Vec<&str> = schedule.time.split(':').collect();
                        if parts.len() != 2 {
                            info!("Invalid time format for scheduling.");
                            continue;
                        }
                        let hour: u32 = parts[0].parse().unwrap_or(0);
                        let minute: u32 = parts[1].parse().unwrap_or(0);
                        let next_monday = get_next_monday(now, hour, minute);
                        next_monday
                    }
                    _ => {
                        info!("Unsupported frequency for scheduling.");
                        continue;
                    }
                };

                let duration = if scheduled_time > now {
                    scheduled_time - now
                } else {
                    // Schedule for the next interval
                    match schedule.frequency.as_str() {
                        "daily" => {
                            Duration::seconds(24 * 3600)
                                - Duration::seconds((now - scheduled_time).num_seconds())
                        }
                        "weekly" => {
                            Duration::seconds(7 * 24 * 3600)
                                - Duration::seconds((now - scheduled_time).num_seconds())
                        }
                        _ => Duration::seconds(60),
                    }
                };

                sleep(duration.to_std().unwrap()).await;

                match backup.run() {
                    Ok(_) => info!("Scheduled backup completed successfully."),
                    Err(e) => info!("Scheduled backup failed: {}", e),
                };
            }
        });
    }
}

fn get_next_monday(now: chrono::NaiveDateTime, hour: u32, minute: u32) -> chrono::NaiveDateTime {
    let date = now.date();
    let current_weekday = date.weekday();
    let days_ahead = (Weekday::Mon.num_days_from_monday() as i64
        - current_weekday.num_days_from_monday() as i64
        + 7)
        % 7;
    let next_monday = if days_ahead == 0 {
        date + Duration::days(7)
    } else {
        date + Duration::days(days_ahead)
    };
    next_monday.and_hms_opt(hour, minute, 0).unwrap()
}
