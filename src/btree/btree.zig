const std = @import("std");
const util = @import("util.zig");

// B-Tree implementation below, based on the book Build A Database From Scratch
// Node consist of a fixed sized hear containing the node type (leaf or internal) and number of keys
// it will also contain pointes and child nodes
// a list of offsets for each k/v pair
// packed kv pairs

//| type | nkeys | pointers | offsets | key-values
//| 2B | 2B | nkeys * 8B | nkeys * 2B | ...


const HEADER=4;
const BTREE_PAGE_SIZE = 4096;
const BTREE_MAX_KEY_SIZE = 1000;
const BTREE_MAX_VAL_SIZE = 3000;

const BTREE_NODE = 1;
const BTREE_LEAF = 2;


const Node = struct {
    data: [] const u8,

    fn btype(self: *Node ) u16{
       return util.little_endian_u16(self.data);

    }

    fn nkeys(self: *Node) u16{
        return util.little_endian_u16(self.data[2..4]);
    }

    fn set_header(self: *Node, b_type: u16, n_keys: u16) void{
        b_type = btype(self);
        n_keys = nkeys(self); 
    }

    fn get_offset(self: *Node, index: u16) u16{
        const offset = self.data[offset_position(self,index)..];
        return offset;
    }

    fn get_pointer(self: *Node, index: u16) u64{
        std.testing.expect(index < self.nkeys());
        const pos = HEADER + 8*index;
        return util.little_endian_u64(self.data[pos..]);
        
    }

    fn set_offset(self: *Node, index: u16, offset: u16) void{
        offset = self.data[offset_position(self, index)..];

    }
};

//returns offset position. Takes header and keys
fn offset_position(node: *Node, index: u16) u16{

    std.testing.expect(1 <= index and index <= node.nkeys());
    return HEADER +  8*node.nkeys() + 2*(index-1);
}


const BTree = struct{
    root: u64,
    leaf: bool,


    pub fn init() void{
        const node_max = HEADER+8+4+2+BTREE_MAX_KEY_SIZE+BTREE_MAX_VAL_SIZE;
        try std.testing.expect(node_max <= BTREE_PAGE_SIZE);

    }
};

test "ofsset test" {
    var node = Node{.data = "test"};
    const value = node.btype();
    const keys = node.nkeys();

   std.debug.print("value {d}\n", .{value});
   std.debug.print("key is {d}\n", .{keys});


}
