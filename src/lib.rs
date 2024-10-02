#![no_std]
#![no_main]
//#![feature(lang_items)]

mod kernel;

use core::panic::PanicInfo;
use core::fmt::Write;

//use crate::kernel::screen_output::print::print_str;
//use crate::kernel::screen_output::print::clear_screen;
use crate::kernel::screen_output::print::Writer;
use crate::kernel::screen_output::print::Color;
//use x86_64::instructions::hlt;

#[no_mangle]
pub extern "C" fn _start() -> ! {

    // ENTRY POINT OF THE KERNEL //

    // For some reason making a static instance of Writer and using it breaks
    // everything, so I have to create a new instance of Writer every time I want to
    // use it. This is *real* bad because all instances share the same memory.
    // I have to fix this. Alternatively just pass around the writer instance
    // as a parameter to functions that need it, but that's SO inconvenient.
    // Counterpoint: Having multiple instances lets me have multiple colors.
    let mut writer = Writer::new(Color::White, Color::Black);

    writer.clear_screen();
    writer.print_string("DubiousOS Kernel v0.1\n");
    write!(writer, "The numbers are {} and {}", 42, 1.0/3.0).unwrap();
    //println!("Hai :{}", "3");

    /*for i in 0..100000 {
        write!(writer, "{}", i).unwrap();
    }*/
    //target remote localhost:1234

    //kernel::screen_output::print::WRITER.lock().write_str("test").unwrap();

    // When using print_str, the compiler optimizes the code by replacing it
    // with a series of mov instructions that write hardcoded bytes to the VGA
    // buffer. This doesn't happen when using writer.print_string, and instead
    // the string is stored in the .rodata section of the kernel binary.
    // However, when loading the kernel in memory, the bootloader doesn't load
    // enough segments to include the .rodata section, so the kernel doesn't
    // have access to the string, and instead prints garbage to the screen, 
    // which is the bytes contained where the string should have been.
    // This is why print_str works but writer.print_string doesn't.

    //clear_screen();
    //print_str("DubiousOS Kernel v0.1");

    //hlt();
    panic!("Some panic message");

    loop {}
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    let mut writer = Writer::new(Color::LightRed, Color::Black);
    writer.print_string("\n");
    write!{writer, "{}", _info}.unwrap();
    loop {}
}

/*#[lang = "eh_personality"]
extern "C" fn eh_personality() {}*/