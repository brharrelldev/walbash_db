const std = @import("std");
const util = @import("util.zig");

// B-Tree implementation below, based on the book Build A Database From Scratch
// Node consist of a fixed sized hear containing the node type (leaf or internal) and number of keys
// it will also contain pointes and child nodes
// a list of offsets for each k/v pair
// packed kv pairs

//| type | nkeys | pointers | offsets | key-values
//| 2B | 2B | nkeys * 8B | nkeys * 2B | ...

const HEADER = 4;
const BTREE_PAGE_SIZE = 4096;
const BTREE_MAX_KEY_SIZE = 1000;
const BTREE_MAX_VAL_SIZE = 3000;

const BTREE_NODE = 1;
const BTREE_LEAF = 2;

const Node = struct {
    data: []const u8,

    fn btype(self: *Node) u16 {
        return util.read_little_endian_u16(self.data);
    }

    fn nkeys(self: *Node) u16 {
        return util.read_little_endian_u16(self.data[2..4]);
    }

    fn set_header(self: *Node, b_type: u16, n_keys: u16) void {
        util.write_little_endian_16(self.data[0..2], b_type);
        util.write_little_endian_16(self.data[2..4], n_keys);
    }

    fn get_offset(self: *Node, index: u16) u16 {
        const offset = self.data[offset_position(self, index)..];
        return offset;
    }

    fn set_offset(self: *Node, index: u16, offset: u16) void {
        offset = self.data[offset_position(self, index)..];
    }

    fn get_pointer(self: *Node, index: u16) u64 {
        std.testing.expect(index < self.nkeys());
        const pos = HEADER + 8 * index;
        return util.read_little_endian_u64(self.data[pos..]);
    }

    fn set_pointer(self: *Node, index: u16, val: u64) void {
        const pos = HEADER + 8 * index;
        util.write_little_endian_u64(self.data[pos..], val);
    }

    fn kv_position(self: *Node, index: u16) u16 {
        return HEADER + 8 * self.nkeys() + 2 * self.nkeys() + self.get_offset(index);
    }

    fn get_key(self: *Node, index: u16) []u8 {
        const pos = self.kv_position(index);
        const key_length = util.read_little_endian_u16(self.data[pos..]);
        const begin_key = self.data[pos + 4 ..];
        return begin_key[begin_key..key_length];
    }

    fn get_value(self: *Node, index: u16) []u8 {
        const pos = self.kv_position(index);
        const key_length = util.read_little_endian_u16(self.data[pos..]);
        const value_length = util.read_little_endian_u16(self.data[pos + 2 ..]);

        const value_begin = self.data[pos + 4 + key_length ..];

        return self.data[value_begin..value_length];
    }

    fn size_in_bytes(self: *Node) u16 {
        return self.kv_position(self.nkeys());
    }
};

//returns offset position. Takes header and keys
fn offset_position(node: *Node, index: u16) u16 {
    std.testing.expect(1 <= index and index <= node.nkeys());
    return HEADER + 8 * node.nkeys() + 2 * (index - 1);
}

fn node_lookup_leaf(node: *Node, key: []u8) u16 {
    const n_keys = node.nkeys();

    const found: u16 = undefined;

    for (0.., @as(u16, @intCast(1))..n_keys) |i, _| {
        if (std.mem.eql([]u8, node.get_key(i), key)) {
            found = i;
        } else {
            break;
        }
    }

    return found;
}

fn leaf_insert(new: *Node, old: *Node, index: u16, key: []u8, val: []u8) void {
    new.set_header(BTREE_LEAF, old.nkeys() + 1);
    node_append_range(new, old, 0, 0, index);
    node_append_kv(new,index,0, key, val);
    node_append_range(new, old, index+1, index, old.nkeys()-1);
}

fn node_append_range(new: *Node, old: *Node, dstNew: u16, srcOld: u16, n: u16) !void {
    if (n == 0) {
        return;
    }

    for (@as(u16, @intCast(0)).., n) |i, _| {
        new.set_pointer(dstNew + 1, old.get_pointer(srcOld + i));
    }

    const dst_begin = new.get_offset(dstNew);
    const src_begin = new.get_offset(srcOld);

    for (@as(u16, @intCast(1)).., n) |i, _| {
        const offset = dst_begin + old.get_offset(srcOld + i) - src_begin;
        new.set_offset(dstNew + 1, offset);
    }

    const begin = old.kv_position(srcOld);
    const end = old.kv_position(srcOld + n);

    std.mem.copyForwards([]u8, new.data[new.kv_position(dstNew)..], old.data[begin..end]);
}

fn node_append_kv(new: *Node, index: u16, pointer: u64, key: []u8, val: []u8) void{

    new.set_pointer(index,pointer);

    const pos = new.kv_position(index);

    util.write_little_endian_u16(new.data[pos..], @as(u16, @intCast(key.len)));
    util.write_little_endian_u16(new.data[pos+2..], @as(u16, @intCast(val.len)));

    std.mem.copyForwards([]u8, new.data[pos+4..], key);
    std.mem.copyForwards([]u8, new.data[pos+4+@as(u16, @intCast(key.len))], val);

    new.set_offset(index+1, new.get_offset(index)+4+@as(u16, @intCast(key.len)));
}

const BTree = struct {
    root: u64,
    leaf: bool,

    pub fn init() void {
        const node_max = HEADER + 8 + 4 + 2 + BTREE_MAX_KEY_SIZE + BTREE_MAX_VAL_SIZE;
        try std.testing.expect(node_max <= BTREE_PAGE_SIZE);
    }
};



test "ofsset test" {
    var node = Node{ .data = "test" };
    const value = node.btype();
    const keys = node.nkeys();

    std.debug.print("value {d}\n", .{value});
    std.debug.print("key is {d}\n", .{keys});
}
