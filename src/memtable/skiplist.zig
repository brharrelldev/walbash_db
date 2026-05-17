const std = @import("std");

const skipListError = error{
    KeyNotFound,
};

const max_level: usize = 5;

const Node = struct {
    key: u16,
    value: []u8,
    nodeArray: ?std.ArrayList(Node),
    height: u16,
    allocator: std.mem.Allocator,
    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        const node_pointers = std.array_list.Managed(Self).init(allocator);
        return Self{
            .allocator = allocator,
            .height = 10,
            .nodeArray = node_pointers,
        };
    }
};

// const SkipList = struct {
//     head: Node,
//     max_level: u32,
//     current: u16,
//     current_level: usize,
//     level: u8,
//
//     const Self = @This();
//
//     pub fn init() Self {
//         return Self{
//             .head = undefined,
//             .max_level = 5,
//             .level = 0,
//             .current_level = 0,
//         };
//     }
//
//     pub fn search(self: *Self, key: u16) ![]u8 {
//         var current = self.head;
//
//         while (current.nodeArray.?.items[max_level] != null and current.nodeArray.?.items[max_level].key < key) {
//             current.nodeArray.items[max_level];
//         }
//     }
// };

test "search test" {
    const t: ?[]const u8 = "testing";

    std.debug.print("{s}\n", .{t.?});
}
