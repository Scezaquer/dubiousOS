#![no_std]
#![no_main]

use crate::screen_output::print::print_str;
use crate::screen_output::print::clear_screen;
mod screen_output;

//use drivers::disk::DiskDriver;
use core::panic::PanicInfo;

#[no_mangle]
pub extern "C" fn main() -> ! {

    ///////////// ENTRY POINT OF THE KERNEL /////////////

    // Initialization code goes here
    // set up environment, initialize hardware, etc.

    intro_screen();

    // This function should not return, so we use an infinite loop
    loop {}
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    // add custom panic handling logic here

    // Halt the CPU or loop indefinitely to prevent further execution
    loop {}
}

fn intro_screen(){
    clear_screen();

    // Print a message on screen to signal the kernel loaded successfully
    let kernel_load_msg = "DubiousOS Kernel loaded successfully in 64-bit long mode";

    print_str(kernel_load_msg);
}