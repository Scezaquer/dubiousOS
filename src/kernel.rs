#![no_std]
#![no_main]

use core::panic::PanicInfo;

#[no_mangle]
pub extern "C" fn _start() -> ! {
    // Initialization code goes here
    // This is where you would set up your environment, initialize hardware, etc.

    // Call your previous main function
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
    let video_mem_ptr: *mut u16 = 0xb8000 as *mut u16;

    // Set the character pointed to X. Unsafe is necessary when dereferencing a
    // raw pointer
    unsafe{ core::ptr::write_volatile(video_mem_ptr, 0x1F58); }
}