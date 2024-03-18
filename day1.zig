const std = @import("std");
const ArrayList = std.ArrayList;
const mem = std.mem;
const dprint = std.debug.print;

const Day1 = error{NumberNotFound};

fn split_lines(filename: []const u8) ![][]const u8 {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile(filename, .{});
    const content = try file.reader().readAllAlloc(allocator, 100000);

    var lines = ArrayList([]const u8).init(allocator);
    defer lines.deinit();
    var iterator = mem.tokenize(u8, content, "\n");

    while (iterator.next()) |line| {
        try lines.append(line);
    }

    var input = try lines.toOwnedSlice();
    // dprint("{s}\n", .{input});

    return input;
}

// there should atleast be a number present
fn get_first_digit(line: []const u8) u32 {
    var fd: u32 = 0;
    var idx: u32 = 0;
    while (idx < line.len) : (idx += 1) {
        if (line[idx] >= '0' and line[idx] <= '9') {
            fd = line[idx] - '0';
            break;
        }
    }

    return idx;
}

// there should atleast be a number present
fn get_second_digit(line: []const u8) u32 {
    var sd: u32 = 0;
    var idx: u32 = 0;
    var prev: u32 = 0; // not making optional, because atleast one number will be present
    while (idx < line.len) : (idx += 1) {
        if (line[idx] >= '0' and line[idx] <= '9') {
            sd = line[idx] - '0';
            prev = idx;
            // dprint("prev: {d} ", .{prev});
        }
    }

    // dprint("return prev: {d}\n", .{prev});
    return prev;
}

fn part1(input: [][]const u8) void {
    var sum: u32 = 0;
    for (input) |line| {
        const fd = get_first_digit(line);
        const sd = get_second_digit(line);
        var num: u32 = fd * 10 + sd;
        // dprint("{d}\n", .{num});
        sum += num;
    }
    // dprint("sum: {}\n", .{sum});
}

const numbers = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

fn find_first_number(line: []const u8) Day1!struct { u32, u32 } {
    var idx: u32 = 0;
    var sz = line.len;

    while (idx < sz) : (idx += 1) {
        var nidx: u32 = 0;
        while (nidx < 9) : (nidx += 1) {
            var tidx = idx;
            var matched: bool = true;
            for (numbers[nidx]) |c| {
                if (tidx < sz and line[tidx] != c) {
                    matched = false;
                    break;
                }
                tidx += 1;
            }
            if (matched) {
                return .{ nidx, idx };
            }
        }
    }

    return Day1.NumberNotFound;
}

fn find_last_number(line: []const u8) Day1!struct { u32, u32 } {
    var idx: u32 = 0;
    var sz = line.len;
    // dprint("line: {s}\n", .{line});

    var pnum: ?u32 = null;
    var pidx: ?u32 = null;
    while (idx < sz) : (idx += 1) {
        var nidx: u32 = 0;
        while (nidx < 9) : (nidx += 1) {
            var tidx = idx;
            var matched: bool = true;
            for (numbers[nidx]) |c| {
                if ((tidx < sz and line[tidx] != c) or tidx >= sz) {
                    matched = false;
                    break;
                }
                tidx += 1;
            }
            if (matched) {
                pnum = nidx;
                pidx = idx;
            }
        }
    }

    return if (pnum == null) Day1.NumberNotFound else .{ pnum.?, pidx.? };
}

fn part2(input: [][]const u8) void {
    var sum: u32 = 0;
    for (input) |line| {
        var num: u32 = 0;

        const fidx = get_first_digit(line);
        const sidx = get_second_digit(line);
        const fnum = find_first_number(line);
        if (fnum) |tuple| {
            if (tuple[1] < fidx) {
                num += ((tuple[0] + 1) * 10);
            } else num += ((line[fidx] - '0') * 10);
        } else |_| { // the placeholder is just to capture error, or else fnum will be treated as optional
            num += ((line[fidx] - '0') * 10);
        }
        const snum = find_last_number(line);
        if (snum) |tuple| {
            if (tuple[1] > sidx) {
                num += (tuple[0] + 1);
            } else num += (line[sidx] - '0');
        } else |_| {
            num += (line[sidx] - '0');
        }

        dprint("{d}\n", .{num});
        sum += num;
    }

    dprint("{d}\n", .{sum});
}

pub fn main() !void {
    const input = try split_lines("./input.txt");

    part2(input);
}

// var fd: ?u32 = null;
// if (fd) |_| { // if fd is done then this will work
//     sd = c - '0';
//     dprint("sd {d} ", .{sd.?});
// } else {
//     fd = c - '0';
//     dprint("fd {d} ", .{fd.?});
// }
