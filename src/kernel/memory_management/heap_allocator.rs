struct FreeListNode {
    size: usize,
    next: Option<&'static mut FreeListNode>,
}

static mut HEAP_START: usize = 0;
static mut HEAP_SIZE: usize = 0;
static mut FREE_LIST_HEAD: Option<&'static mut FreeListNode> = None;

fn init_heap(start: usize, size: usize){
    unsafe {
        HEAP_START = start;
        HEAP_SIZE = size;
        FREE_LIST_HEAD = Some(&mut *(HEAP_START as *mut FreeListNode));
        FREE_LIST_HEAD.as_mut().unwrap().size = size;
        FREE_LIST_HEAD.as_mut().unwrap().next = None;
    }
}

// This function is responsible for allocating memory from the heap.
// It takes the desired size as input and returns a pointer to the allocated memory.
// If there is not enough free memory available, it returns a null pointer.

fn allocate(size: usize) -> *mut u8 {

    /*
    // Align the size to 8 bytes
    let aligned_size = (size + 7) & !7;

    // Start searching from the head of the free list
    let mut current: Option<&mut &mut FreeListNode> = unsafe { FREE_LIST_HEAD.as_mut() };
    let mut previous: Option<&mut &mut FreeListNode> = None;

    // Iterate through the free list to find a suitable block of memory
    while let Some(ref node) = current {
        // Check if the current node has enough size to accommodate the allocation
        if node.size >= aligned_size {
            // Calculate the starting address of the allocation
            let alloc_start = node as *mut _ as usize;

            // Check if the remaining size of the node is enough to hold another FreeListNode
            if node.size > aligned_size + core::mem::size_of::<FreeListNode>() {
                // Create a new FreeListNode for the remaining memory
                let next_node = (alloc_start + aligned_size) as *mut FreeListNode;
                unsafe {
                    // Set the size and next pointer of the new node
                    (*next_node).size = node.size - aligned_size;
                    (*next_node).next = node.next.take();

                    // Update the next pointer of the previous node or the head of the free list
                    if let Some(prev) = previous {
                        prev.next = Some(&mut *next_node);
                    } else {
                        FREE_LIST_HEAD = Some(&mut *next_node);
                    }
                }
            } else {
                // Remove the current node from the free list
                if let Some(prev) = previous {
                    prev.next = node.next.take();
                } else {
                    unsafe {
                        FREE_LIST_HEAD = node.next.take();
                    }
                }
            }

            // Return the pointer to the allocated memory
            return alloc_start as *mut u8;
        }

        // Move to the next node in the free list
        previous = current;
        current = node.next.as_mut();
    }
    */

    // If no suitable block of memory is found, return a null pointer
    // Todo: this is terrible and should return an Option
    core::ptr::null_mut()
}

fn deallocate(ptr: *mut u8, size: usize){
    let aligned_size = (size + 7) & !7;
    let new_node = ptr as *mut FreeListNode;
    unsafe{
        (*new_node).size = aligned_size;
        (*new_node).next = FREE_LIST_HEAD.take();
        FREE_LIST_HEAD = Some(&mut *new_node);
    }

    //TODO: implement coalescing of adjacent free blocks
}