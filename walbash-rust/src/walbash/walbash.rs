use std::{fmt::Write, fs::File, io::Read};

use clap::Parser;
use serde::{Deserialize, Serialize};

use crate::cli::cli::{Commands::Load, WalBashArgs};
//use crate::memtable::memtable;

pub struct WalbashDB {
    args: WalBashArgs,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Config {
    storage_path: String,
    wal_prefix: String,
    mem_table_max: u64,
}

impl WalbashDB {
    pub fn new() -> Self {
        Self {
            args: WalBashArgs::parse(),
        }
    }

    pub fn run(self) {
        match self.args.load {
            Load { data_file } if !data_file.is_empty() => {}
            _ => {}
        }
    }
}
