const std = @import("std");
const btree = @import("btree/btree.zig");



pub fn main() !void {
   const b = btree.Node{.data = "tet"};



   std.debug.print("{}", .{b});
}
