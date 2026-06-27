use std::collections::BTreeMap;
use std::fs::{File, OpenOptions};
use std::io::{self, BufReader, BufWriter};

use crate::wal::wal::Wal;

const MAX_SIZE: u64 = 64 * 10 * 10;

#[repr(C)]
#[derive(Clone, Copy, bytemuck::Zeroable, bytemuck::Pod)]
pub struct CortexPayload {
    neuron_id: u64,
    pre_synapse_neuron_id: u64,
    post_synapse_neuron_id: u64,
}

pub struct Memtable {
    entry: BTreeMap<u64, CortexPayload>,
    current_size: u64,
    wal: Wal<File, File>,
    max_size: u64,
}

impl Memtable {
    pub fn try_new(wal_file_path: String) -> io::Result<Self> {
        let wal_file = OpenOptions::new()
            .read(true)
            .write(true)
            .create(true)
            .truncate(true)
            .open(wal_file_path)?;

        let wal_writer = wal_file.try_clone()?;
        let wal_reader = wal_file.try_clone()?;

        let buff_writer = BufWriter::new(wal_writer);
        let buff_reader = BufReader::new(wal_reader);

        let wal_inst = Wal::new(buff_writer, buff_reader);

        Ok(Self {
            entry: BTreeMap::new(),
            wal: wal_inst,
            current_size: MAX_SIZE,
            max_size: 0,
        })
    }

    pub fn put(&mut self, key: u64, value: CortexPayload) -> io::Result<()> {
        let key_bytes = key.to_be_bytes();
        let value_bytes = bytemuck::bytes_of(&value);

        self.wal.write_entry(&key_bytes, value_bytes, 0x01)?;
        let key_size = std::mem::size_of::<u64>() as u64;
        let value_size = std::mem::size_of::<CortexPayload>() as u64;

        let btree_key: u64 = key_size * 16;
        let btree_value = value_size * 16;

        let node_size = btree_key + btree_value + 16;

        let fill_avg: f32 = 16.0 * 0.7;

        let total_memory_per_elment = node_size as f32 / fill_avg;

        match self.entry.insert(key, value) {
            Some(old_value) => {
                _ = old_value;
            }
            None => {
                self.current_size += key_size + value_size + total_memory_per_elment as u64;
            }
        }

        Ok(())
    }

    pub fn is_max_size(self) -> bool {
        if self.current_size < self.max_size {
            return false;
        }

        true
    }
}
