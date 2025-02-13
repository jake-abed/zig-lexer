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
    GT,
    EQ,
    NOT_EQ,
    COMMA,
    SEMICOLON,
    COLON,
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

pub fn lookupIdent(ident: []const u8) error{OutOfMemory}!TokenType {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

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
