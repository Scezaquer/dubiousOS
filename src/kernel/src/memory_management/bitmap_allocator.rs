// TODO: do a BIOS or UEFI call to find out how much memory is available
// In the meantime we assume constant size of 16MB

const MEMORY_START: usize = 0x100000; // Start after 1MB
const MEMORY_SIZE: usize = 16 * 1024 * 1024; // 16MB of RAM

const FRAME_SIZE: usize = 4096; // 4KB frames
const FRAME_COUNT: usize = MEMORY_SIZE / FRAME_SIZE;

// Bitmap for the frames. 0 means the frame is free, 1 means it's used
static mut FRAME_BITMAP: [u64 ; FRAME_COUNT / 64] = [0; FRAME_COUNT / 64];

fn allocate_frame() -> Option<usize> {
    for (i, map) in unsafe { FRAME_BITMAP.iter_mut().enumerate() } {
        if *map != !0 { // Evil bitwise not operator to get all u64 bits to 1 and check an entire piece of the map for availability at once
            for j in 0..64 { // Find which frame is free in the 64 we tried
                if *map & (1 << j) == 0 {
                    *map |= 1 << j; // Mark the frame as used
                    return Some((i * 64 + j) * FRAME_SIZE + MEMORY_START);
                }
            }
        }
    }
    None
}

fn deallocate_frame(address: usize) {
    let frame = (address - MEMORY_START) / FRAME_SIZE;
    unsafe{
        FRAME_BITMAP[frame / 64] &= !(1 << (frame % 64)); // Mark the frame as free
    }
}