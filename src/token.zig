const std = @import("std");

pub const Token = struct {
    type: TokenType,
    literal: []const u8,

    pub fn init(
        self: *Token,
        l: []const u8,
        t: TokenType,
    ) void {
        self.literal = l;
        self.type = t;
    }
};

pub const TokenType = enum {
    ILLEGAL,
    EOF,
    IDENT,
    INT,
    FLOAT,
    ASSIGN,
    PLUS,
    MINUS,
    BANG,
    ASTERISK,
    SLASH,
    LT,
    LTEQ,
    GT,
    GTEQ,
    EQ,
    NOT_EQ,
    COMMA,
    SEMICOLON,
    COLON,
    AND,
    OR,
    AMPERSAND,
    PIPE,
    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,
    LBRACKET,
    RBRACKET,
    STRING,
    FUNC,
    CONST,
    LET,
    TRUE,
    FALSE,
    IF,
    ELSE,
    ELIF,
    RETURN,
};

pub fn newToken(t: TokenType, l: []const u8) Token {
    return Token{
        .type = t,
        .literal = l,
    };
}

pub fn lookupIdent(ident: []const u8, allocator: std.mem.Allocator) error{OutOfMemory}!TokenType {
    var map = std.StringHashMap(TokenType).init(allocator);
    try map.put("cook", TokenType.FUNC);
    try map.put("aight", TokenType.CONST);
    try map.put("bet", TokenType.LET);
    try map.put("yee", TokenType.TRUE);
    try map.put("nah", TokenType.FALSE);
    try map.put("uh", TokenType.IF);
    try map.put("tho", TokenType.ELSE);
    try map.put("send", TokenType.RETURN);

    return map.get(ident) orelse TokenType.IDENT;
}

test "ident lookups work" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try std.testing.expect(lookupIdent("cook", allocator) catch unreachable == TokenType.FUNC);
    try std.testing.expect(lookupIdent("aight", allocator) catch unreachable == TokenType.CONST);
    try std.testing.expect(lookupIdent("bet", allocator) catch unreachable == TokenType.LET);
    try std.testing.expect(lookupIdent("yee", allocator) catch unreachable == TokenType.TRUE);
    try std.testing.expect(lookupIdent("nah", allocator) catch unreachable == TokenType.FALSE);
    try std.testing.expect(lookupIdent("uh", allocator) catch unreachable == TokenType.IF);
    try std.testing.expect(lookupIdent("tho", allocator) catch unreachable == TokenType.ELSE);
    try std.testing.expect(lookupIdent("send", allocator) catch unreachable == TokenType.RETURN);
}
