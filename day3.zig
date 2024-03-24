const std = @import("std");
const ArrayList = std.ArrayList;
const mem = std.mem;
const fmt = std.fmt;
const dprint = std.debug.print;
const child_allocator = std.heap.page_allocator;

const ALLOC_SIZE = 1e5;
const FILENAME = "./input.txt";

fn split_lines(filename: []const u8) ![][]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    const content = try file.reader().readAllAlloc(child_allocator, ALLOC_SIZE);

    var lines = ArrayList([]const u8).init(child_allocator);
    defer lines.deinit();

    var iterator = mem.tokenize(u8, content, "\n");

    while (iterator.next()) |line| {
        try lines.append(line);
    }

    // no need to call deinit() because of toOwnedSlice(), it's safe but unnecessary now
    var input = try lines.toOwnedSlice();

    return input;
}

fn is_num(c: u8) bool {
    return if (c >= '0' and c <= '9') true else false;
}

const drow = [_]i8{ -1, -1, -1, 0, 0, 0, 1, 1, 1 };
const dcol = [_]i8{ -1, 0, 1, -1, 0, 1, -1, 0, 1 };

fn part2(input: [][]const u8, visited: [][]u8) !void {
    const Ratio = struct {
        n: u32,
        d: u32,
    };
    const nr = input.len;
    const nc = input[0].len;
    var sum: usize = 0;
    for (input, 0..) |line, i| {
        for (line, 0..) |_, j| {
            if (input[i][j] == '*') {
                // check for the gear with two adjacent number
                var ratio = Ratio{ .n = 0, .d = 0 };
                var c: u8 = 0;
                var num_count: u8 = 0;
                while (c < 9) : (c += 1) {
                    var nx: i32 = @intCast(i);
                    nx += drow[c];
                    var ny: i32 = @intCast(j);
                    ny += dcol[c];
                    if (nx >= 0 and ny >= 0 and nx < nr and ny < nc) {
                        // var counter: u32 = @intCast(ny + 1);
                        var counter: u32 = @intCast(ny -% 1);
                        var unx: usize = @intCast(nx);
                        var buf_start: u32 = 0;
                        var buf_len: u32 = 0;
                        dprint("i: {}, j: {}, nx: {}, ny: {}\n", .{ i, j, nx, ny });
                        if (visited[unx][@intCast(ny)] == 'f') {
                            buf_start = counter + 1;
                            buf_len = 1;
                            while (counter < ny and visited[unx][counter] == 'f') : (counter -%= 1) {
                                buf_start = counter;
                                buf_len += 1;
                            }
                        }
                        // while (counter >= 1 and visited.items[unx][counter - 1] == 'f') : (counter -= 1) {
                        //     buf_start = counter - 1;
                        //     buf_len += 1;
                        // }
                        counter = @intCast(ny);
                        if (visited[unx][counter] == 'f') {
                            counter = @intCast(ny + 1);
                            while (counter < nc and visited[unx][counter] == 'f') : (counter += 1) {
                                buf_len += 1;
                            }
                        }
                        counter = 0;
                        while (counter < buf_len) : (counter += 1) {
                            visited[unx][@intCast(buf_start + counter)] = 't';
                        }
                        if (buf_len != 0) {
                            dprint("got num: {s}\n", .{input[unx][buf_start .. buf_start + buf_len]});
                            if (num_count == 0) {
                                ratio.n = try fmt.parseInt(u32, input[unx][buf_start .. buf_start + buf_len], 10);
                            } else if (num_count == 1) {
                                ratio.d = try fmt.parseInt(u32, input[unx][buf_start .. buf_start + buf_len], 10);
                            } else {
                                ratio.n = 0;
                                ratio.d = 0;
                                break;
                            }
                            num_count += 1;
                        }
                    }
                }
                sum += (ratio.n * ratio.d);
                dprint("multiplied = n: {}, d: {}, sum: {}\n", .{ ratio.n, ratio.d, sum });
            }
        }
    }

    dprint("sum: {}\n", .{sum});
}

fn part1(input: [][]const u8, visited: ArrayList([]u8), nr: u16, nc: u16) !void {
    var i: u32 = 0;
    var sum: usize = 0;
    while (i < nr) : (i += 1) {
        var j: u32 = 0;
        while (j < nc) : (j += 1) {
            if (!is_num(input[i][j]) and input[i][j] != '.') { // it's a special character
                var c: u8 = 0;
                while (c < 9) : (c += 1) {
                    var nx = @as(isize, i) + drow[c];
                    var ny = @as(isize, j) + dcol[c];
                    if (nx >= 0 and ny >= 0 and nx < nr and ny < nc) {
                        // move to prev column now
                        var buf_start: u32 = 0;
                        var buf_len: u32 = 0;
                        var counter: u32 = @intCast(ny + 1); // first, will move backwards, and usize can't handle -1
                        var unx: u32 = @intCast(nx);
                        // move backward
                        while (counter >= 1 and visited.items[unx][counter - 1] == 'f') : (counter -= 1) {
                            buf_start = counter - 1;
                            buf_len += 1;
                        }
                        // move forward
                        counter = @intCast(ny);
                        if (visited.items[unx][(@intCast(ny))] == 'f') {
                            counter = @intCast(ny + 1);
                            while (counter < nc and visited.items[unx][counter] == 'f') : (counter += 1) {
                                buf_len += 1;
                            }
                        }
                        counter = 0;
                        while (counter < buf_len) : (counter += 1) {
                            visited.items[unx][buf_start + counter] = 't';
                        }
                        if (buf_len != 0) {
                            dprint("got num: {s}\n", .{input[unx][buf_start .. buf_start + buf_len]});
                            sum += try fmt.parseInt(u32, input[unx][buf_start .. buf_start + buf_len], 10);
                        }
                    }
                }
            }
        }
    }
    // print visited now
    i = 0;
    while (i < nr) : (i += 1) {
        var j: isize = 0;
        while (j < nc) : (j += 1) {
            dprint("{c}", .{visited.items[@intCast(i)][@intCast(j)]});
        }
        dprint("\n", .{});
    }

    dprint("sum: {d}\n", .{sum});
}

pub fn main() !void {
    const input = try split_lines(FILENAME);

    var arena = std.heap.ArenaAllocator.init(child_allocator);
    var allocator = arena.allocator();
    defer arena.deinit();

    var visited = try allocator.alloc([]u8, input.len);
    for (0..visited.len) |idx| {
        visited[idx] = try allocator.alloc(u8, input[0].len);
        for (input[idx], 0..) |c, i| {
            if (is_num(c)) {
                visited[idx][i] = 'f';
            } else visited[idx][i] = c;
        }
    }

    for (input) |line| {
        dprint("{s}\n", .{line});
    }

    try part2(input, visited);

    // var visited = ArrayList([]u8).init(allocator);
    // defer visited.deinit();
    //
    // var nr: u16 = 0;
    // var nc: u16 = 0;
    // for (input) |line| {
    //     var nline = ArrayList(u8).init(allocator);
    //     var count: u16 = 0;
    //     for (line) |c| {
    //         if (is_num(c)) {
    //             try nline.append('f');
    //         } else try nline.append(c);
    //         count += 1;
    //     }
    //     nc = count; // column width is same for each row
    //     var bline: []u8 = try nline.toOwnedSlice();
    //     try visited.append(bline);
    //
    //     nr += 1;
    // }

    // try part1(input, visited, nr, nc);
    // try part2(input, visited, nr, nc);

    // -- prevent integer overflow during loops --
    var some_length: u16 = 10;
    var counter: u16 = some_length -% 1;
    dprint("{}\n", .{counter});
    while (counter < some_length) : (counter -%= 1) {
        dprint("counter: {}\n", .{counter});
    }
    dprint("{}\n", .{counter});
}
