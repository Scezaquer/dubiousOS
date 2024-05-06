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
    let mut video_mem_ptr: *mut u16 = 0xb8000 as *mut u16;

    // Set the character pointed to X. Unsafe is necessary when dereferencing a
    // raw pointer
    let kernel_load_msg = "DubiousOS Kernel loaded successfully in 64-bit long mode";
    let char_params: u16 = 0x0F00 as u16;

    for byte in kernel_load_msg.bytes(){
        unsafe{ 
            core::ptr::write_volatile(video_mem_ptr, char_params | byte as u16);
            video_mem_ptr = video_mem_ptr.offset(1);
        }
    }
    
}