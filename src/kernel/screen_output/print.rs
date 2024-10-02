// Module for printing to the screen
// The VGA text buffer is located at 0xb8000

use volatile::Volatile;
use spin::Mutex;
use lazy_static::lazy_static;
use core::fmt;

const BUFFER_HEIGHT: usize = 25;
const BUFFER_WIDTH: usize = 80;
const BUFFER_SIZE: usize = BUFFER_HEIGHT * BUFFER_WIDTH;
const VGA_BUFFER: *mut u16 = 0xb8000 as *mut u16;

// Enum for all 16 possible colors
#[allow(dead_code)] // Disable unused code warning
#[derive(Debug, Copy, Clone, PartialEq, Eq)]
#[repr(u8)]
pub enum Color {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGray = 7,
    DarkGray = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    Pink = 13,
    Yellow = 14,
    White = 15,
}

// Struct for color codes. The struct is a simple wrapper around a u8. A color
// code is a byte, where the lower 4 bits represent the foreground color and the
// upper 4 bits represent the background color
#[derive(Debug, Copy, Clone, PartialEq, Eq)]
#[repr(transparent)] // Ensure that the struct has the same memory layout as u8
struct ColorCode(u8);

impl ColorCode {
    fn new(foreground: Color, background: Color) -> ColorCode {
        ColorCode((background as u8) << 4 | (foreground as u8))
    }
}

// Struct for a single screen character. The struct has an ASCII character and a
// color code
#[derive(Debug, Copy, Clone, PartialEq, Eq)]
#[repr(C)] // Ensure that the struct has the same memory layout as a C struct
struct ScreenChar {
    ascii_character: u8,
    color_code: ColorCode,
}

#[repr(transparent)]
struct Buffer {
    chars: [[Volatile<ScreenChar>; BUFFER_WIDTH]; BUFFER_HEIGHT],
}

pub struct Writer {
    column_position: usize,
    color_code: ColorCode,
    buffer: &'static mut Buffer,
}

impl Writer {
    pub fn new(foreground: Color, background: Color) -> Writer {
        Writer {
            column_position: 0,
            color_code: ColorCode::new(foreground, background),
            buffer: unsafe { &mut *(VGA_BUFFER as *mut Buffer) },
        }
    }

    fn write_byte(&mut self, byte: u8) {
        match byte {
            b'\n' => self.new_line(),
            byte => {
                if self.column_position >= BUFFER_WIDTH {
                    self.new_line();
                }

                let row = BUFFER_HEIGHT - 1;
                let col = self.column_position;

                let color_code = self.color_code;
                self.buffer.chars[row][col].write(ScreenChar {
                    ascii_character: byte,
                    color_code,
                });
                self.column_position += 1;
            }
        }
    }

    fn new_line(&mut self) {
        for row in 1..BUFFER_HEIGHT {
            for col in 0..BUFFER_WIDTH {
                let character = self.buffer.chars[row][col].read();
                self.buffer.chars[row - 1][col].write(character);
            }
        }
        self.clear_row(BUFFER_HEIGHT - 1);
        self.column_position = 0;
    }

    fn clear_row(&mut self, row: usize) {
        let blank = ScreenChar {
            ascii_character: b' ',
            color_code: self.color_code,
        };
        for col in 0..BUFFER_WIDTH {
            self.buffer.chars[row][col].write(blank);
        }
    }

    pub fn clear_screen(&mut self) {
        for row in 0..BUFFER_HEIGHT {
            self.clear_row(row);
        }
        self.column_position = 0;
    }

    pub fn print_string(&mut self, s: &str) {
        //let s = "Hello world!";
        for byte in s.bytes() {
            match byte {
                // Printable ASCII byte or newline
                0x20..=0x7e | b'\n' => self.write_byte(byte),
                // Not part of printable ASCII range
                _ => self.write_byte(0xfe),
            }
        }
    }
}


// Support for macros
impl fmt::Write for Writer {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        self.print_string(s);
        Ok(())
    }
}

/*
// Lazy static writer (global instance)
lazy_static! {
    pub static ref WRITER: Mutex<Writer> = Mutex::new(Writer::new(Color::White, Color::Black));
}

// print! and println! macros
#[macro_export]
macro_rules! print {
    ($($arg:tt)*) => ($crate::kernel::screen_output::print::_print(format_args!($($arg)*)));
}

#[macro_export]
macro_rules! println {
    () => ($crate::print!("\n"));
    ($($arg:tt)*) => ($crate::print!("{}\n", format_args!($($arg)*)));
}


//static mut WRITER: Writer = Writer::new(Color::White, Color::Black);

#[doc(hidden)]
pub fn _print(args: fmt::Arguments) {
    use core::fmt::Write;
    WRITER.lock().write_fmt(args).unwrap();
}
*/

/*pub fn clear_screen() {
    // TODO: do something about the cursor
    // Define a mutable raw pointer to video memory location 0xb8000 (top left
    // corner of the screen)
    let mut video_mem_ptr: *mut u64 = 0xb8000 as *mut u64;
    let char_params: u64 = 0x0F000F000F000F00 as u64;

    for _ in 1..501 {
        unsafe {
            core::ptr::write_volatile(video_mem_ptr, char_params);
            video_mem_ptr = video_mem_ptr.offset(1);
        }
    }

    //set_cursor_position(0, 0);
}

pub fn print_str(s: &str) {
    //TODO: println?
    let mut video_mem_ptr: *mut u16 = 0xb8000 as *mut u16;
    let char_params: u16 = 0x0F00 as u16;

    for byte in s.bytes() {
        // We write directly to video memory, which is unsafe
        unsafe {
            core::ptr::write_volatile(video_mem_ptr, char_params | byte as u16);
            video_mem_ptr = video_mem_ptr.offset(1);
        }
    }
}*/

/*pub fn set_cursor_position(row: u8, col: u8) {
    let position: u16 = (row as u16) * 80 + (col as u16);

    unsafe {
        x86::io::outb(0x3D4, 0x0F);
        x86::io::outb(0x3D5, (position & 0xFF) as u8);
        x86::io::outb(0x3D4, 0x0E);
        x86::io::outb(0x3D5, ((position >> 8) & 0xFF) as u8);
    }
}*/
