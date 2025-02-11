const std = @import("std");
const lexer = @import("lexer.zig");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var l = lexer.init("aight bet zig = \"Very cool\";", allocator);

    while (l.ch != 0) {
        const tok = try l.nextToken();
        std.debug.print("{s} {}\n", .{ tok.literal, tok.type });
    }
}
