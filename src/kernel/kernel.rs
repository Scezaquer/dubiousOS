#![no_std]
#![no_main]

use core::panic::PanicInfo;

#[no_mangle]
pub extern "C" fn _start() -> ! {

    ///////////// ENTRY POINT OF THE KERNEL /////////////

    // Initialization code goes here
    // set up environment, initialize hardware, etc.

    main();

    // This function should not return, so we use an infinite loop
    loop {}
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    // add custom panic handling logic here

    // Halt the CPU or loop indefinitely to prevent further execution
    loop {}
}

fn main(){
    // Define a mutable raw pointer to video memory location 0xb8000 (top left
    // corner of the screen)
    let mut video_mem_ptr: *mut u16 = 0xb8000 as *mut u16;

    // Print a message on screen to signal the kernel loaded successfully
    let kernel_load_msg = "DubiousOS Kernel loaded successfully in 64-bit long mode";
    let char_params: u16 = 0x0F00 as u16;   // White text on black background

    for byte in kernel_load_msg.bytes(){
        // We write directly to video memory, which is unsafe
        unsafe{ 
            core::ptr::write_volatile(video_mem_ptr, char_params | byte as u16);
            video_mem_ptr = video_mem_ptr.offset(1);
        }
    }
}