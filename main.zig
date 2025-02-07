const std = @import("std");
const token = @import("token.zig");

pub fn main() void {
    std.debug.print("Hello, {s}!\n", .{"World"});
    var literal = "cook".*;
    const cook = literal[0..];
    const tok = token.lookupIdent(cook);
    std.debug.print("{}\n", .{tok});
}
