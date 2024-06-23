pub fn clear_screen(){
    // TODO: do something about the cursor
    // Define a mutable raw pointer to video memory location 0xb8000 (top left
    // corner of the screen)
    let mut video_mem_ptr: *mut u64 = 0xb8000 as *mut u64;
    let char_params: u64 = 0x0F000F000F000F00 as u64;

    for _ in 1..501{
        unsafe{ 
            core::ptr::write_volatile(video_mem_ptr, char_params);
            video_mem_ptr = video_mem_ptr.offset(1);
        }
    }
}

pub fn print_str(s: &str){
    //TODO: println?
    let mut video_mem_ptr: *mut u16 = 0xb8000 as *mut u16;
    let char_params: u16 = 0x0F00 as u16;

    for byte in s.bytes(){
        // We write directly to video memory, which is unsafe
        unsafe{ 
            core::ptr::write_volatile(video_mem_ptr, char_params | byte as u16);
            video_mem_ptr = video_mem_ptr.offset(1);
        }
    }
}