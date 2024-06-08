
pub fn little_endian_u16(byte: []const u8) u16{
    return @as(u16, @intCast(byte[0])) | @as(u16, @intCast(byte[1]))<<8;
}

pub fn little_endian_u64(byte: []const u8) u64{
    return @as(u16, @intCast(byte[0])) | @as(u16, @intCast(byte[1]))<<8 
            |  @as(u16, @intCast(byte[2])) << 16 | @as(u16, @intCast(byte[3])) << 24
            |  @as(u16, @intCast(byte[4])) << 32 | @as(u16, @intCast(byte[5])) << 40
            |  @as(u16, @intCast(byte[6])) << 48 | @as(u16, @intCast(byte[7])) << 56;
}