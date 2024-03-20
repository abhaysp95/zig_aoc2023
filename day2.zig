const std = @import("std");
const ArrayList = std.ArrayList;
const mem = std.mem;
const fmt = std.fmt;
const dprint = std.debug.print;

fn split_lines(filename: []const u8) ![][]const u8 {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile(filename, .{});
    const content = try file.reader().readAllAlloc(allocator, 1000000);

    var lines = ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var iterator = mem.tokenize(u8, content, "\n");

    while (iterator.next()) |line| {
        try lines.append(line);
    }
    var input = try lines.toOwnedSlice();

    return input;
}

const maxr = 12;
const maxg = 13;
const maxb = 14;

const CubeSet = struct {
    red: u32,
    green: u32,
    blue: u32,
};

fn solve(input: [][]const u8) !void {
    // const limitCube = CubeSet{ .red = 12, .green = 13, .blue = 14 };
    // var part1_ans: u32 = 0;
    var part2_ans: u32 = 0;
    for (input) |line| {
        var BaseCube = CubeSet{ .red = 0, .green = 0, .blue = 0 };
        var split_iter = mem.splitSequence(u8, line, ": ");
        var game = split_iter.next().?;
        var game_input = split_iter.next().?;
        var game_idx = try fmt.parseInt(u8, game[5..], 10);
        _ = game_idx;

        var game_steps = mem.splitSequence(u8, game_input, "; ");

        while (game_steps.next()) |step| {
            var cube = mem.tokenizeAny(u8, step, ", ");
            var singleCube = CubeSet{ .red = 0, .green = 0, .blue = 0 };
            while (cube.next()) |c| {
                const freq = try fmt.parseInt(u8, c, 10);
                const color = cube.next().?;
                if (mem.eql(u8, color, "red")) {
                    singleCube.red = freq;
                } else if (mem.eql(u8, color, "green")) {
                    singleCube.green = freq;
                } else if (mem.eql(u8, color, "blue")) {
                    singleCube.blue = freq;
                }
            }
            BaseCube.red = @max(BaseCube.red, singleCube.red);
            BaseCube.green = @max(BaseCube.green, singleCube.green);
            BaseCube.blue = @max(BaseCube.blue, singleCube.blue);

            // this is for part1
            // if (singleCube.red > limitCube.red or singleCube.green > limitCube.green or singleCube.blue > limitCube.blue) {
            //     continue :GameLoop;
            // }
        }
        const CubeMul = BaseCube.red * BaseCube.green * BaseCube.blue;
        part2_ans += CubeMul;

        // this is for part1
        // part1_ans += game_idx;
    }
    dprint("{}\n", .{part2_ans});
}

fn part1(input: [][]const u8) void {
    var sum: u32 = 0;
    var cline: u32 = 0;
    for (input) |line| {
        var iter = mem.tokenize(u8, line, " ");
        var cnum: u8 = 0;
        var cgame: u32 = 0;
        var tcount: u8 = 0;
        var is_game: bool = true;
        while (iter.next()) |word| {
            tcount += 1;
            if (tcount <= 2) {
                if (tcount == 2) {
                    const nword = std.fmt.parseUnsigned(u32, word[0 .. word.len - 1], 10);
                    if (nword) |nw| {
                        cgame = nw;
                    } else |_| {
                        unreachable;
                    }
                    // dprint("cline: {d}, tcount: {d}, cgame: {d}\n", .{ cline, tcount, cgame });
                }
                continue;
            }
            const num = std.fmt.parseUnsigned(u8, word, 10);
            if (num) |n| {
                cnum = n;
                // dprint("cline: {d}, cnum: {d}\n", .{ cline, cnum });
            } else |_| {
                var rcount: u8 = 0;
                var bcount: u8 = 0;
                var gcount: u8 = 0;
                var new_word: []const u8 = word;
                if (word[word.len - 1] == ',' or word[word.len - 1] == ';') {
                    new_word = word[0 .. word.len - 1];
                }
                if (mem.eql(u8, new_word, "red")) {
                    rcount = cnum;
                } else if (mem.eql(u8, new_word, "green")) {
                    gcount = cnum;
                } else if (mem.eql(u8, new_word, "blue")) {
                    bcount = cnum;
                }
                if (rcount > maxr or gcount > maxg or bcount > maxb) {
                    is_game = false;
                    break;
                }
                // dprint("cline: {d}, new_word: {s}\n", .{ cline, new_word });
            }
        }
        if (is_game) {
            sum += cgame;
        }
        // dprint("sum: {d}", .{sum});
        // dprint("\n-------\n", .{});

        cline += 1;
    }

    dprint("sum: {d}\n", .{sum});
}

fn part2(input: [][]const u8) void {
    var sum: u64 = 0;
    var cline: u32 = 0;
    for (input) |line| {
        var iter = mem.tokenize(u8, line, " ");
        var cnum: u8 = 0;
        var cgame: u32 = 0;
        var tcount: u8 = 0;
        var rcount: u32 = 0;
        var bcount: u32 = 0;
        var gcount: u32 = 0;
        while (iter.next()) |word| {
            tcount += 1;
            if (tcount <= 2) {
                if (tcount == 2) {
                    const nword = std.fmt.parseUnsigned(u32, word[0 .. word.len - 1], 10);
                    if (nword) |nw| {
                        cgame = nw;
                    } else |_| {
                        unreachable;
                    }
                    // dprint("cline: {d}, tcount: {d}, cgame: {d}\n", .{ cline, tcount, cgame });
                }
                continue;
            }
            const num = std.fmt.parseUnsigned(u8, word, 10);
            if (num) |n| {
                cnum = n;
                // dprint("cline: {d}, cnum: {d}\n", .{ cline, cnum });
            } else |_| {
                var new_word: []const u8 = word;
                if (word[word.len - 1] == ',' or word[word.len - 1] == ';') {
                    new_word = word[0 .. word.len - 1];
                }
                if (mem.eql(u8, new_word, "red")) {
                    rcount = @max(rcount, cnum);
                } else if (mem.eql(u8, new_word, "green")) {
                    gcount = @max(gcount, cnum);
                } else if (mem.eql(u8, new_word, "blue")) {
                    bcount = @max(bcount, cnum);
                }
                // dprint("cline: {d}, new_word: {s}\n", .{ cline, new_word });
            }
        }
        dprint("r: {d}, g: {d}, b: {d}\n", .{ rcount, gcount, bcount });
        sum += (rcount * gcount * bcount);
        // dprint("sum: {d}", .{sum});
        // dprint("\n-------\n", .{});

        cline += 1;
    }

    dprint("sum: {d}\n", .{sum});
}

pub fn main() !void {
    const input = try split_lines("./input.txt");
    // part2(input);
    try solve(input);
}
