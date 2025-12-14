const std = @import("std");
const lexer = @import("lexer.zig");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const input =
        \\aight bet zig = "Very cool programming language";
        \\aight cook (meat) {
        \\  uh (1 == 2) send yee;
        \\  tho send nah;
        \\};
        \\(10 >= 9) && (9 <= 10);
    ;

    var l = lexer.init(input, allocator);

    while (l.ch != 0) {
        const tok = try l.nextToken();
        std.debug.print("{s} {}\n", .{ tok.literal, tok.type });
    }
}
