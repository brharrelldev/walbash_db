
pub fn read_little_endian_u16(byte: []const u8) u16{
    return @as(u16, @intCast(byte[0])) | @as(u16, @intCast(byte[1]))<<8;
}

pub fn read_little_endian_u64(byte: []const u8) u64{
    return @as(u64, @intCast(byte[0])) | @as(u64, @intCast(byte[1]))<<8 
            |  @as(u64, @intCast(byte[2])) << 16 | @as(u64, @intCast(byte[3])) << 24
            |  @as(u64, @intCast(byte[4])) << 32 | @as(u64, @intCast(byte[5])) << 40
            |  @as(u64, @intCast(byte[6])) << 48 | @as(u64, @intCast(byte[7])) << 56;
}

pub fn write_little_endian_u64(byte: []const u8, v: u64) void{
    byte[0] = @as(u8, @intCast(v));
    byte[1] = @as(u8, @intCast(v))<<8;
    byte[2] = @as(u8, @intCast(v))<<16;
    byte[3] = @as(u8, @intCast(v))<<24;
    byte[4] = @as(u8, @intCast(v))<<32;
    byte[5] = @as(u8, @intCast(v))<<40;
    byte[6] = @as(u8, @intCast(v))<<48;
    byte[7] = @as(u8, @intCast(v))<<56;
}

pub fn write_little_endian_u16(byte: []const u8, v: u16) void{
     _ = byte[7];

    byte[0] = @as(u8, @intCast(v));
    byte[1] = @as(u8, @intCast(v))<<8;
}