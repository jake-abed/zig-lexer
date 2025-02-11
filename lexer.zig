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
                    var lit = [_]u8{l.ch};
                    const literal = try l.allocator.dupe(u8, lit[0..]);
                    tok.init(literal, TokenType.ASSIGN);
                }
            },
            '-' => {
                var lit = [_]u8{l.ch};
                const literal: []const u8 = try l.allocator.dupe(u8, lit[0..]);
                tok.init(literal, TokenType.MINUS);
            },
            '+' => {
                var lit = [_]u8{l.ch};
                const literal: []const u8 = try l.allocator.dupe(u8, lit[0..]);
                tok.init(literal, TokenType.PLUS);
            },
            '/' => {
                var lit = [_]u8{l.ch};
                const literal: []const u8 = try l.allocator.dupe(u8, lit[0..]);
                tok.init(literal, TokenType.SLASH);
            },
            '<' => {
                var lit = [_]u8{l.ch};
                const literal: []const u8 = try l.allocator.dupe(u8, lit[0..]);
                tok.init(literal, TokenType.LT);
            },
            '>' => {
                var lit = [_]u8{l.ch};
                const literal: []const u8 = try l.allocator.dupe(u8, lit[0..]);
                tok.init(literal, TokenType.GT);
            },
            ';' => {
                var lit = [_]u8{l.ch};
                const literal: []const u8 = try l.allocator.dupe(u8, lit[0..]);
                tok.init(literal, TokenType.SEMICOLON);
            },
            ':' => {
                var lit = [_]u8{l.ch};
                const literal: []const u8 = try l.allocator.dupe(u8, lit[0..]);
                tok.init(literal, TokenType.COLON);
            },
            '"' => {
                const literal = try l.readString();
                tok.init(literal, TokenType.STRING);
            },
            0 => {
                tok.init("EOF", TokenType.EOF);
            },
            else => {
                if (isDigit(l.ch)) {
                    const literal = try l.readNum();
                    tok.init(literal, TokenType.INT);
                } else if (isAlpha(l.ch)) {
                    const literal = try l.readIdent();
                    const t = try token.lookupIdent(literal);
                    tok.init(literal, t);
                } else {
                    tok.init("", TokenType.ILLEGAL);
                }
            },
        }

        l.readChar();
        return tok;
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
