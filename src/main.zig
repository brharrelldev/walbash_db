const std = @import("std");
const io = std.io;

var cursor: usize = 0;
pub fn main() !void {
    const key: []const u8 = "this is a test";

    const entry_start = 0;
    const header_size = 2;

    var buffer: [100]u8 = undefined;

    const slice = buffer[entry_start .. entry_start + header_size];

    std.mem.writeInt(u16, slice, @intCast(key.len), .big);

    const key_begin = cursor + header_size;
    const key_end = cursor + header_size + key.len;

    const key_dest = buffer[key_begin..key_end];

    @memcpy(key_dest, key);

    const cwd = std.fs.cwd();

    const output_file = try cwd.createFile("output", .{});
    defer output_file.close();

    const writer = output_file.writer(&buffer);

    _ = try writer.file.write(&buffer);

    var read_buffer: [100]u8 = undefined;

    const read = try std.fs.cwd().readFile("output", &read_buffer);

    std.debug.print("{s}", .{read});
}
