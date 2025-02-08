const std = @import("std");
const lexer = @import("lexer.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const literal = "=- + *";
    const l = try lexer.init(literal, allocator);
    var count: u64 = 0;

    while (l.ch != 0 and count < 20) {
        count += 1;
        const tok4 = l.nextToken();
        std.debug.print("{s} {}\n", .{ tok4.literal, tok4.type });
    }
}
