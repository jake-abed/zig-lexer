const std = @import("std");
const lexer = @import("lexer.zig");

pub fn main() void {
    var literal = " == -".*;
    const cook = literal[0..];
    const l = lexer.init(cook);
    const tok = l.nextToken();
    const tok2 = l.nextToken();
    std.debug.print("{s} {}\n", .{ tok.literal, tok.type });
    std.debug.print("{s} {}\n", .{ tok2.literal, tok2.type });
}
