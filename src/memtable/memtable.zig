const std = @import("std");

pub fn Memtable(comptime T: type) type {
    return struct {
        index: u64,
        map: std.AutoArrayHashMap(u64, T),
        allocator: std.mem.Allocator,
        const Self = @This();

        pub fn init(allocator: std.mem.Allocator) Self {
            const hash = std.AutoArrayHashMap(u64, T).init(allocator);

            return Self{
                .allocator = allocator,
                .index = 0,
                .map = hash,
            };
        }

        pub fn insert(self: *Self, index: u64, comptime V: T) !void {
            try self.map.put(index, V);
        }
    };
}
