const std = @import("std");
const token = @import("token.zig");
const TokenType = token.TokenType;

pub const Lexer = struct {
    input: []const u8,
    allocator: std.mem.Allocator,
    pos: usize = 0,
    readPos: usize = 0,
    ch: u8 = 0,

    pub fn nextToken(l: *Lexer) error{OutOfMemory}!*token.Token {
        var tok = try l.allocator.create(token.Token);
        l.skipWhitespace();
        switch (l.ch) {
            '=' => {
                if (l.peekChar() == '=') {
                    var lit = [_]u8{ l.ch, l.ch };
                    const literal: []const u8 = try l.allocator.dupe(u8, lit[0..]);
                    l.readChar();
                    tok.init(literal, TokenType.EQ);
                } else {
                    try l.addSingleCharToken(tok, TokenType.ASSIGN);
                }
            },
            '-' => try l.addSingleCharToken(tok, TokenType.MINUS),
            '+' => try l.addSingleCharToken(tok, TokenType.PLUS),
            '/' => try l.addSingleCharToken(tok, TokenType.SLASH),
            '<' => {
                if (l.peekChar() == '=') {
                    var lit = [_]u8{ l.ch, '=' };
                    const literal: []const u8 = try l.allocator.dupe(u8, lit[0..]);
                    l.readChar();
                    tok.init(literal, TokenType.LTEQ);
                } else {
                    try l.addSingleCharToken(tok, TokenType.LT);
                }
            },
            '>' => {
                if (l.peekChar() == '=') {
                    var lit = [_]u8{ l.ch, '=' };
                    const literal: []const u8 = try l.allocator.dupe(u8, lit[0..]);
                    l.readChar();
                    tok.init(literal, TokenType.GTEQ);
                } else {
                    try l.addSingleCharToken(tok, TokenType.GT);
                }
            },
            ';' => try l.addSingleCharToken(tok, TokenType.SEMICOLON),
            ':' => try l.addSingleCharToken(tok, TokenType.COLON),
            '"' => {
                const literal = try l.readString();
                tok.init(literal, TokenType.STRING);
            },
            ',' => try l.addSingleCharToken(tok, TokenType.COMMA),
            '[' => try l.addSingleCharToken(tok, TokenType.LBRACKET),
            ']' => try l.addSingleCharToken(tok, TokenType.RBRACKET),
            '{' => try l.addSingleCharToken(tok, TokenType.LBRACE),
            '}' => try l.addSingleCharToken(tok, TokenType.RBRACE),
            '(' => try l.addSingleCharToken(tok, TokenType.LPAREN),
            ')' => try l.addSingleCharToken(tok, TokenType.RPAREN),
            0 => tok.init("EOF", TokenType.EOF),
            else => {
                if (isDigit(l.ch)) {
                    const literal = try l.readNum();
                    tok.init(literal, TokenType.INT);
                    return tok;
                } else if (isAlpha(l.ch)) {
                    const literal = try l.readIdent();
                    const t = try token.lookupIdent(literal, l.allocator);
                    tok.init(literal, t);
                    return tok;
                } else {
                    tok.init("", TokenType.ILLEGAL);
                }
            },
        }

        l.readChar();
        return tok;
    }

    fn addSingleCharToken(l: *Lexer, tok: *token.Token, token_type: TokenType) error{OutOfMemory}!void {
        const lit = [_]u8{l.ch};
        const literal: []const u8 = try l.allocator.dupe(u8, lit[0..]);
        tok.init(literal, token_type);
    }

    fn readString(l: *Lexer) error{OutOfMemory}![]const u8 {
        const start = l.pos + 1;
        while (true) {
            l.readChar();
            if (l.ch == '"' or l.ch == 0) {
                break;
            }
        }

        var lit = l.input[start..l.pos];
        return try l.allocator.dupe(u8, lit[0..]);
    }

    fn readIdent(l: *Lexer) error{OutOfMemory}![]const u8 {
        const start = l.pos;
        while (isAlpha(l.ch) or isDigit(l.ch)) {
            l.readChar();
        }

        var lit = l.input[start..l.pos];
        return try l.allocator.dupe(u8, lit[0..]);
    }

    fn readNum(l: *Lexer) error{OutOfMemory}![]const u8 {
        const start = l.pos;
        while (isDigit(l.ch)) {
            l.readChar();
        }

        var lit = l.input[start..l.pos];
        return try l.allocator.dupe(u8, lit[0..]);
    }

    pub fn readChar(l: *Lexer) void {
        if (l.readPos >= l.input.len) {
            l.ch = 0;
        } else {
            l.ch = l.input[l.readPos];
        }
        l.pos = l.readPos;
        l.readPos += 1;
    }

    fn peekChar(l: *Lexer) u8 {
        if (l.readPos >= l.input.len) {
            return 0;
        } else {
            return l.input[l.readPos];
        }
    }

    fn skipWhitespace(l: *Lexer) void {
        while (l.ch == ' ' or l.ch == '\r' or l.ch == '\n' or l.ch == '\t') {
            l.readChar();
        }
    }
};

pub fn init(inp: []const u8, a: std.mem.Allocator) Lexer {
    var l = Lexer{ .input = inp, .allocator = a, .pos = 0, .readPos = 0, .ch = 0 };
    l.readChar();
    return l;
}

fn isAlpha(byte: u8) bool {
    return (('a' <= byte) and (byte <= 'z')) or
        (('A' <= byte) and (byte <= 'Z'));
}

fn isDigit(byte: u8) bool {
    return '0' <= byte and byte <= '9';
}

test "is alpha" {
    try std.testing.expect(isAlpha('a') == true);
    try std.testing.expect(isAlpha('A') == true);
    try std.testing.expect(isAlpha('f') == true);
    try std.testing.expect(isAlpha('F') == true);
    try std.testing.expect(isAlpha('!') == false);
    try std.testing.expect(isAlpha('3') == false);
}

test "is digit" {
    try std.testing.expect(isDigit('4') == true);
    try std.testing.expect(isDigit('2') == true);
    try std.testing.expect(isDigit('0') == true);
    try std.testing.expect(isDigit('F') == false);
    try std.testing.expect(isDigit('*') == false);
}

test "lexer test one" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var l = init("aight jesse = \"meth cook\";", allocator);
    const token_one = try l.nextToken();
    const token_two = try l.nextToken();
    const token_three = try l.nextToken();
    const token_four = try l.nextToken();
    const token_five = try l.nextToken();

    try std.testing.expect(token_one.type == TokenType.CONST);
    try std.testing.expect(token_two.type == TokenType.IDENT);
    try std.testing.expect(std.mem.eql(u8, token_two.literal, "jesse"));
    try std.testing.expect(token_three.type == TokenType.ASSIGN);
    try std.testing.expect(token_four.type == TokenType.STRING);
    try std.testing.expect(std.mem.eql(u8, token_four.literal, "meth cook"));
    try std.testing.expect(token_five.type == TokenType.SEMICOLON);

    const token_six = try l.nextToken();
    try std.testing.expect(token_six.type == TokenType.EOF);
}
