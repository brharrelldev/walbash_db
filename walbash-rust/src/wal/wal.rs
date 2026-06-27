use std::fs::File;
use std::io::{self, BufReader, BufWriter, Read, Seek, Write};

const HEADER_LENGTH: usize = 7;

pub struct Wal<W: Write, R: Read> {
    cursor: usize,
    buffer: [u8; 64000],
    reader: BufReader<R>,
    writer: BufWriter<W>,
    //key_start: usize,
    //key_end: usize,
}

impl Wal<File, File> {
    pub fn sync_all(&mut self) -> io::Result<()> {
        self.writer.flush()?;
        self.writer.get_ref().sync_all()
    }
}

impl<W: Write + Seek, R: Read + Seek> Wal<W, R> {
    pub fn new(buff_writer: BufWriter<W>, buff_read: BufReader<R>) -> Self {
        Self {
            buffer: [0; 64000],
            cursor: 0,
            reader: buff_read,
            writer: buff_writer,
        }
    }

    //figure out header size.
    // add size to buffer
    // build key index as key_start
    // end of key buffer is cursor + header size + key length
    // initialize keybuffer. It is the key start ... key end
    // calculate key length.Write it to buffer
    // add the rest of they key. build a destination based on the key and key length
    // copy the key destination into buffer
    pub fn write_entry(&mut self, key: &[u8], value: &[u8], ops_type: u8) -> io::Result<()> {
        self.cursor += HEADER_LENGTH;
        let key_start = self.cursor;
        let key_end = self.cursor + 2;

        {
            let key_buffer = &mut self.buffer[key_start..key_end];
            let key_length = key.len() as u16;
            let len_bytes = key_length.to_be_bytes();

            key_buffer[0..2].copy_from_slice(&len_bytes);
        }

        self.cursor += 2;

        let key_buffer_start = self.cursor;
        let key_buffer_end: usize = self.cursor + key.len();

        let key_dest = &mut self.buffer[key_buffer_start..key_buffer_end];

        key_dest.copy_from_slice(key);

        self.cursor += key.len();

        let value_start = self.cursor;
        let value_end = self.cursor + 2;

        {
            let key_value_buff = &mut self.buffer[value_start..value_end];
            let value_len = value.len() as u16;

            key_value_buff[0..2].copy_from_slice(&value_len.to_be_bytes());
        }

        self.cursor += 2;

        let value_buff_start = self.cursor;
        let value_buff_end = self.cursor + value.len();

        let value_dest = &mut self.buffer[value_buff_start..value_buff_end];

        value_dest.copy_from_slice(value);

        self.cursor += value.len();

        let header_len = (2 + key.len() + 2 + value.len()) as u16;
        let be_header = header_len.to_be_bytes();
        self.buffer[4..6].copy_from_slice(&be_header);
        self.buffer[6] = ops_type;

        let mut hasher = crc32fast::Hasher::new();

        hasher.update(&self.buffer[4..HEADER_LENGTH + header_len as usize]);

        let crc = hasher.finalize();

        self.buffer[0] = ((crc >> 24) & 0xFF) as u8;
        self.buffer[1] = ((crc >> 16) & 0xFF) as u8;
        self.buffer[2] = ((crc >> 8) & 0xFF) as u8;
        self.buffer[3] = (crc & 0xFF) as u8;

        self.writer.write_all(&self.buffer[..self.cursor])?;

        self.cursor = 0;

        Ok(())
    }

    pub fn read_entry(&mut self) -> io::Result<()> {
        _ = self.reader.seek(io::SeekFrom::Start(0));

        let mut header_buff: [u8; HEADER_LENGTH] = [0; HEADER_LENGTH];
        self.reader.read_exact(&mut header_buff)?;

        if header_buff.len() < HEADER_LENGTH {
            print!("corrupted data")
        }

        let stored_crc = u32::from_be_bytes(
            header_buff[0..4]
                .try_into()
                .expect("error reading header bytes"),
        );

        let payload_length = u16::from_be_bytes(
            header_buff[4..6]
                .try_into()
                .expect("error reading payload bytes"),
        );

        let mut read_buff: [u8; 4096] = [0; 4096];

        let full_payload = &mut read_buff[0..payload_length as usize];

        let _ = self.reader.read_exact(full_payload);

        if full_payload.len() < payload_length as usize {
            println!("eof");
        }

        let mut hasher = crc32fast::Hasher::new();

        hasher.update(&header_buff[4..HEADER_LENGTH]);
        hasher.update(full_payload);

        let finalized = hasher.finalize();

        if finalized != stored_crc {
            print!("{} is not equal to {}", finalized, stored_crc);
        }

        Ok(())
    }
}

