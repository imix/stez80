use std::io::{self, Read, Write};
use std::os::unix::io::AsRawFd;
use std::sync::mpsc::{self, Receiver, TryRecvError};
use std::thread;
use std::time::Duration;

use ctrlc;
use termios::{tcsetattr, Termios, ECHO, ICANON, TCSANOW};

use iz80::{Cpu, Machine, TimedRunner};

static ROM_DATA: &[u8] = include_bytes!("rom/monitor.bin");
//static ROM_DATA: &[u8] = &[ 0xDB, 0x03, 0xE6, 0x01, 0xCA, 0x00, 0x00, 0xDB, 0x02, 0xD3, 0x02, 0xC3, 0x00, 0x00, ];

const MHZ: f64 = 4.0;

fn main() {
    let fd = io::stdin().as_raw_fd();
    let mut termios = Termios::from_fd(fd).unwrap();
    let original_termios = termios.clone();
    termios.c_lflag &= !(ICANON | ECHO);
    tcsetattr(fd, TCSANOW, &termios).unwrap();

    ctrlc::set_handler(move || {
        tcsetattr(fd, TCSANOW, &original_termios).unwrap();
        std::process::exit(0);
    })
    .unwrap();

    let mut machine = SteZ80Machine::new();
    let mut cpu = Cpu::new();
    let mut timed_runner = TimedRunner::default();
    timed_runner.set_mhz(&cpu, MHZ, 1000);

    let mut stdout = io::stdout();
    let stdin_channel = spawn_stdin_channel();

    for (i, &b) in ROM_DATA.iter().enumerate() {
        machine.poke(i as u16, b);
    }

    cpu.registers().set_pc(0x0000);
    machine.in_values[3] = 1;
    cpu.set_trace(false);

    //println!("[emulator] Entering main loop... type a character.");

    loop {
        timed_runner.execute(&mut cpu, &mut machine);

        if let Some(port) = machine.out_port.take() {
            match port {
                2 => {
                    let c = machine.out_value;
                    //println!("[emulator] OUT (2) requested → '{}'", c as char);
                    stdout.write_all(&[c]).unwrap();
                    stdout.flush().unwrap();
                }
                3 => {}
                _ => panic!("BDOS command not implemented"),
            }
        }

        if MHZ == 0.0 {
            thread::sleep(Duration::from_millis(1));
        }

        if machine.rx_buffer.is_none() {
            match stdin_channel.try_recv() {
                Ok(key) => {
                    //println!("[host] Received key '{}'", key as char);
                    machine.rx_buffer = Some(key);
                    machine.in_values[2] = key;
                    machine.in_values[3] = 1;
                }
                Err(TryRecvError::Empty) => {
                    if machine.rx_buffer.is_none() {
                        machine.in_values[3] = 0;
                    }
                }
                Err(TryRecvError::Disconnected) => {}
            }
        }
    }
}

fn spawn_stdin_channel() -> Receiver<u8> {
    let (tx, rx) = mpsc::channel::<u8>();
    thread::spawn(move || {
        let stdin = io::stdin();
        let mut handle = stdin.lock();
        let mut buffer = [0u8; 1];

        loop {
            if let Ok(_) = handle.read_exact(&mut buffer) {
                let mut c = buffer[0];
                // return CR when LF is entered
                if c == 10 {
                    // LF
                    c = 13; // CR
                }
                if tx.send(c).is_err() {
                    break;
                }
            }
        }
    });

    rx
}

struct SteZ80Machine {
    mem: [u8; 65536],
    in_values: [u8; 256],
    rx_buffer: Option<u8>,
    in_port: Option<u8>,
    out_port: Option<u8>,
    out_value: u8,
}

impl SteZ80Machine {
    pub fn new() -> Self {
        Self {
            mem: [0; 65536],
            in_values: [0; 256],
            rx_buffer: None,
            in_port: None,
            out_port: None,
            out_value: 0,
        }
    }
}

impl Machine for SteZ80Machine {
    fn peek(&self, address: u16) -> u8 {
        self.mem[address as usize]
    }

    fn poke(&mut self, address: u16, value: u8) {
        self.mem[address as usize] = value;
    }

    fn port_in(&mut self, address: u16) -> u8 {
        let port = address as u8;
        let value = match port {
            2 => {
                if let Some(c) = self.rx_buffer.take() {
                    self.in_values[3] = 1;
                    //println!("[port_in] IN (2) → '{}' [{}]", c as char, c);
                    c
                } else {
                    //println!("[port_in] IN (2) → NO DATA, returning 0x00");
                    0x00
                }
            }
            3 => {
                let v = self.in_values[3];
                //println!("[port_in] IN (3) → {:02X}", v);
                v
            }
            _ => {
                let v = self.in_values[port as usize];
                //println!("[port_in] IN ({:02X}) → {:02X}", port, v);
                v
            }
        };

        self.in_port = Some(port);
        value
    }

    fn port_out(&mut self, address: u16, value: u8) {
        let port = address as u8;
        //println!( "[port_out] OUT ({:02X}) ← '{}' [{}]", port, value as char, value);
        self.out_port = Some(port);
        self.out_value = value;
    }
}
