const std = @import("std");
const io = std.Io;

const header_size = 7;

pub const WALWriter = struct {
    writer: std.fs.File,
    buffer: [64000]u8,
    cursor: usize,
    const Self = @This();

    pub fn init(writer: std.fs.File) Self {
        const cursor = 0;

        return Self{
            .writer = writer,
            .cursor = cursor,
            .buffer = undefined,
        };
    }

    // offset math explio.Writeraination
    // if let's say key length is u16, then this is 2 bytes.  That means I want to advance the buffer 2 places
    // So it would be my cursor+2.
    // That means I can do start += self.cursor and I plus 2 it to advance the buffer 2 bytes
    // This means end = self.cursor +2
    // sort to write the key lengths I need to advance twice

    pub fn write_entry(self: *Self, key: []const u8, value: []const u8, op_type: u8) !void {
        self.cursor += header_size;

        // const header: WALHeader = .{ .type = op_type };
        //
        // _ = header;

        const key_start = self.cursor;
        const key_end = self.cursor + header_size + key.len;

        std.debug.print("{d}\n", .{key_start});
        std.debug.print("{d}\n", .{key_end});

        var key_buffer = self.buffer[key_start..key_end];
        std.mem.writeInt(u16, key_buffer[0..2], @intCast(key.len), .big);

        var buff_writer = self.writer.writer(&self.buffer);

        self.cursor += 2;

        const key_buff_start = self.cursor;
        const key_buff_end = self.cursor + key.len;

        const key_dest = self.buffer[key_buff_start..key_buff_end];

        @memcpy(key_dest, key);

        self.cursor += key.len;

        const val_start = self.cursor;
        const val_end = self.cursor + 2;

        const value_len_buff = self.buffer[val_start..val_end];
        std.mem.writeInt(u16, value_len_buff[0..2], @intCast(value.len), .big);
        self.cursor += 2;

        const val_buff_start = self.cursor;
        const val_buff_end = self.cursor + value.len;
        const val_dest = self.buffer[val_buff_start..val_buff_end];
        //
        @memcpy(val_dest, value);
        //
        //
        //

        const crc = std.hash.Crc32.hash(&self.buffer);

        self.buffer[0] = @intCast((crc >> 24) & 0xFF);
        self.buffer[1] = @intCast((crc >> 16) & 0xFF);
        self.buffer[2] = @intCast((crc >> 8) & 0xFF);
        self.buffer[3] = @intCast((crc >> 0) & 0xFF);

        std.debug.print("{d}\n", .{crc});

        const header_len: u16 = @intCast(header_size);

        std.mem.writeInt(u16, self.buffer[4..6], @intCast(header_len), .big);

        self.buffer[6] = op_type;

        _ = try buff_writer.file.write(&self.buffer);

        try self.writer.sync();
    }
};

pub const WALHeader = packed struct {
    crc: u32,
    length: u16,
    type: u8,
};

test "wal functionality check" {
    const fs = std.fs;

    const dir = fs.cwd();
    const test_file = try dir.createFile("test_out", .{});

    const key: []const u8 = "test-1";
    const value: []const u8 = "this is a new value";

    var wal = WALWriter.init(test_file);
    try wal.write_entry(key, value, 0x1);
}
