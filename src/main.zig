const std = @import("std");
const btree = @import("btree/btree.zig");

const PAGE_SIZE = 4096;
pub const Pager = struct {
    file: *std.fs.File,
    page_size: u64,
    page_max: u64,
    size: u64,
};

const page = struct {
    num: u64,
    next: *page,
    prev: *page,
    data: []u8,
};

const shards = struct {
    pages: std.AutoArrayHashMap(u64, page),
    dirty: std.AutoArrayHashMap(u64, bool),
    head: *page,
    tail: *page,
};

//persisting to disk
//get file size
//get memory map size
//pass file descripting into memory map
//mmap size is taken as the offset
//return size and chunk
//
//
pub fn main() !void {

    const db_file = try std.fs.cwd().openFile(".", .{});
    defer db_file.close();
    const stat = try db_file.stat();
    const size = stat.size;

    const metadata = try db_file.metadata();

    if (metadata.size() % PAGE_SIZE == 0) {
        std.process.exit(1);
    }

    var mmap_size:  u64 = undefined;

    mmap_size = 64 << 20;

    if (size < mmap_size){
        mmap_size += 2;
    }

    //const pg_size = std.mem.page_size;

    const chunk = try std.posix.mmap(null, metadata.size(),
        std.posix.PROT.READ | std.posix.PROT.WRITE,
        .{.TYPE = .SHARED}, db_file.handle, 0);

    std.debug.print("{s}", chunk);
}

test "testing" {
    const size = 64 << 20;

    std.debug.print("size is {d}\n", .{size});
}
