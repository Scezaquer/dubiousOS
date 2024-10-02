const PAGE_SIZE: usize = 4096;
const ENTRY_COUNT: usize = 512;

pub type PhysicalAddress = u64;
pub type VirtualAddress = u64;

pub struct Page{
    number: usize,
}

pub struct Entry(u64);

impl Entry{
    pub fn is_unused(&self) -> bool{
        self.0 == 0
    }

    pub fn set_unused(&mut self){
        self.0 = 0;
    }
}