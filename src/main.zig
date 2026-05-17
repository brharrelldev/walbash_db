const std = @import("std");
const io = std.io;

const max_level: u16 = 3;

pub const Node = struct {
    key: u16 = undefined,
    value: []const u8 = undefined,
    forward: std.ArrayList(?*Node),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) !Self {
        const node_list = try std.ArrayList(?*Node).initCapacity(allocator, 2);

        return Self{
            .forward = node_list,
        };
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        self.forward.deinit(allocator);
    }
};

pub const Skiplist = struct {
    current_level: u16,
    head: ?*Node,
    allocator: std.mem.Allocator,
    const Self = @This();
    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .head = null,
            .current_level = 0,
            .allocator = allocator,
        };
    }

    pub fn insert(self: *Self, key: u16, node: *Node) !void {
        var newNode = try Node.init(self.allocator);
        var current_node = self.head;

        for (max_level..0) |i| {
            while (current_node.?.forward.items[i] != null and current_node.?.forward.items[i].?.key < key) {
                current_node = current_node.?.forward[i];
                newNode.forward[i] = current_node;
            }
        }

        var target = current_node.?.forward.items[0];

        if (target.? != null and target.?.key == key) {
            target.?.forward.insert(self.allocator, self.current_level, node);
            // target.?.value =  tarV
        }
    }

    // pub fn search(self: *Self, key: u16) []u8 {
    //     var current = self.head;
    //
    //     while (current.?.forward[self.current_level] != null and current.?.forward[self.current_level].key < key) {}
    // }

    // pub fn search(self: *Self, key: u16) void {}
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    defer _ = gpa.deinit();

    const alloc = gpa.allocator();

    var n1 = try Node.init(alloc);
    var n2 = try Node.init(alloc);

    defer n1.deinit(alloc);
    defer n2.deinit(alloc);

    n1.key = 1;
    n1.value = "testing";

    n2.key = 2;
    n2.value = "testing2";

    var sk = Skiplist.init(alloc);

    try sk.insert(&n1);
    try sk.insert(&n2);

    std.debug.print("{s}\n", .{sk.head.?.forward.items[0].?.value});
}
