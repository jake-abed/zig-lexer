const std = @import("std");
const lexer = @import("lexer.zig");

pub fn main() void {
    var literal = " == - + *".*;
    const cook = literal[0..];
    const l = lexer.init(cook);
    const tok = l.nextToken();
    const tok2 = l.nextToken();
    const tok3 = l.nextToken();
    const tok4 = l.nextToken();
    std.debug.print("{s} {}\n", .{ tok.literal, tok.type });
    std.debug.print("{s} {}\n", .{ tok2.literal, tok2.type });
    std.debug.print("{s} {}\n", .{ tok3.literal, tok3.type });
    std.debug.print("{s} {}\n", .{ tok4.literal, tok4.type });
}
