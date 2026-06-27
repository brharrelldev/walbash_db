use std::io;

mod cli;
mod memtable;
mod wal;
mod walbash;

fn main() -> io::Result<()> {
    Ok(())
}

//match args.wal_command {
//    Commands::WALCommand { ops } => match ops {
//        Some(WalOpts::Write {
//            key_name,
//            value,
//            out_file,
//        }) if !key_name.is_empty() && !value.is_empty() && !out_file.is_empty() => {
//            let wal_file = OpenOptions::new()
//                .write(true)
//                .create(true)
//                .truncate(true)
//                .open(out_file)?;

//            let read_clone = wal_file.try_clone()?;
//            let write_clone = wal_file.try_clone()?;

//            let writer = BufWriter::new(read_clone);
//            let reader = BufReader::new(write_clone);

//            let mut wal_entry = Wal::new(writer, reader);

//            wal_entry.write_entry(key_name.as_bytes(), value.as_bytes(), 0x01)?;

//            wal_entry.sync_all()?;
//        }
//        Some(WalOpts::Read { db_file }) if !db_file.is_empty() => {
//            let wal_file = OpenOptions::new().read(true).open(db_file)?;

//            let read_clone = wal_file.try_clone()?;
//            let write_clone = wal_file.try_clone()?;

//            let writer = BufWriter::new(read_clone);
//            let reader = BufReader::new(write_clone);

//            let mut wal_entry = Wal::new(writer, reader);

//            wal_entry.read_entry()?;
//        }
//        None => {}
//        _ => {}
//    },
