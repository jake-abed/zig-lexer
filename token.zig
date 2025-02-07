const std = @import("std");

const Token = struct { type: TokenType, literal: []u8, line: i64 = 0, col: i64 = 0 };

const TokenType = enum {
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

pub fn lookupIdent(ident: []u8) error{OutOfMemory}!TokenType {
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
