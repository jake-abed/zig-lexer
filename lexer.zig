const std = @import("std");
const token = @import("token.zig");

const Lexer = struct {
    input: []u8,
    position: u64 = 0,
    readPosition: u64 = 0,
    line: u64 = 1,
    col: u64 = 1,
    ch: u8 = 0,
    pub fn nextToken(self: *Lexer) token.Token {
        var tok: token.Token = undefined;

        self.skipWhitespace();

        switch (self.ch) {
            '=' => {
                if (self.peekChar() == '=') {
                    const ch = self.ch;
                    self.readChar();
                    var l = [_]u8{ ch, ch };
                    const literal = l[0..];
                    tok = token.Token{
                        .type = token.TokenType.EQ,
                        .literal = literal,
                        .line = self.line,
                        .col = self.col,
                    };
                } else {
                    var l = [_]u8{self.ch};
                    const literal = l[0..];
                    tok = newToken(
                        token.TokenType.ASSIGN,
                        literal,
                        self.line,
                        self.col,
                    );
                }
            },
            '-' => {
                var l = [_]u8{self.ch};
                const literal = l[0..];
                tok = token.Token{
                    .type = token.TokenType.MINUS,
                    .literal = literal,
                    .line = self.line,
                    .col = self.col,
                };
            },
            else => {
                var l = [_]u8{0};
                const literal = l[0..];
                tok = token.Token{
                    .type = token.TokenType.ILLEGAL,
                    .literal = literal,
                    .line = self.line,
                    .col = self.col,
                };
            },
        }

        return tok;
    }
    fn readChar(self: *Lexer) void {
        if (self.readPosition > self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[@intCast(self.readPosition)];
        }
        self.position = self.readPosition;
        self.readPosition += 1;
        self.col += 1;
    }
    fn peekChar(self: *Lexer) u8 {
        if (self.readPosition > self.input.len) {
            return 0;
        } else {
            return self.input[@intCast(self.readPosition)];
        }
    }
    fn skipWhitespace(self: *Lexer) void {
        while (self.ch == '\n' or self.ch == ' ' or self.ch == '\t' or self.ch == '\r') {
            if (self.ch == '\n' or self.ch == '\r') {
                self.readChar();
                self.line += 1;
                self.col = 0;
            } else {
                self.readChar();
            }
        }
    }
};

pub fn init(inp: []u8) *Lexer {
    var l = Lexer{ .input = inp };
    l.readChar();
    return &l;
}

pub fn newToken(
    tokType: token.TokenType,
    literal: []u8,
    line: u64,
    col: u64,
) token.Token {
    return token.Token{
        .type = tokType,
        .literal = literal,
        .line = line,
        .col = col,
    };
}
