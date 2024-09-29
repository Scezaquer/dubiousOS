#![no_std]
#![no_main]
#![feature(lang_items)]

mod kernel;

use core::panic::PanicInfo;

use crate::kernel::screen_output::print::print_str;
use crate::kernel::screen_output::print::clear_screen;

#[no_mangle]
pub extern "C" fn _start() -> ! {

    // ENTRY POINT OF THE KERNEL //

    clear_screen();
    print_str("DubiousOS Kernel v0.1");

    loop {}
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

#[lang = "eh_personality"]
extern "C" fn eh_personality() {}