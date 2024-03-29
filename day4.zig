const std = @import("std");
const mem = std.mem;
const ArrayList = std.ArrayList;
const math = @cImport({
    @cInclude("math.h");
});
const dprint = std.debug.print;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const child_allocator = gpa.allocator();

const ALLOC_SIZE = 1e5;
const FILENAME = "./input.txt";

fn split_lines(allocator: mem.Allocator, filename: []const u8) ![][]u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    const content = try file.reader().readAllAlloc(child_allocator, ALLOC_SIZE);

    var rsz: u32 = 0;
    var csz: u32 = 0;
    var temp: u32 = 0;
    for (content) |c| {
        if (c == '\n') {
            csz = @max(temp, csz);
            temp = 0;
            rsz += 1;
        } else temp += 1;
    }

    var input = try allocator.alloc([]u8, rsz);
    var idx: u32 = 0;
    var cdx: u32 = 0;
    while (idx < rsz) : (idx += 1) {
        input[idx] = try allocator.alloc(u8, csz);
        var jdx: u32 = 0;
        while (jdx <= csz) : (jdx += 1) {
            if (content[cdx] != '\n') {
                input[idx][jdx] = content[cdx];
            }
            cdx += 1;
        }
    }

    return input;
}

fn part2(allocator: mem.Allocator, input: [][]const u8) !void {
    const sz = input.len;

    // create an array on stack with default value of 1 for size 10
    // var wc_input: [10]u32 = .{1} * 10;

    var wc_input = try child_allocator.alloc(u32, sz); // because sz is not known at compile time
    @memset(wc_input, 1);
    for (input, 0..) |line, idx| {
        var card_iter = mem.splitSequence(u8, line, ": ");
        _ = card_iter.next().?;
        var card_nums = card_iter.next().?;
        var split_iter = mem.splitSequence(u8, card_nums, " | ");

        // use tokenize because there can be multiple spaces between number (because of padding)
        var set1 = mem.tokenizeAny(u8, split_iter.next().?, " ");
        var set2 = mem.tokenizeAny(u8, split_iter.next().?, " ");
        var arr1 = ArrayList(u32).init(allocator);
        defer arr1.deinit();
        while (set1.next()) |str| {
            const num = try std.fmt.parseInt(u32, str, 10);
            try arr1.append(num);
        }
        var arr2 = ArrayList(u32).init(allocator);
        defer arr2.deinit();
        while (set2.next()) |str| {
            const num = try std.fmt.parseInt(u32, str, 10);
            try arr2.append(num);
        }
        var matched: u32 = 0;
        for (arr2.items) |num2| {
            for (arr1.items) |num1| {
                if (num2 == num1) {
                    matched += 1;
                }
            }
        }

        dprint("idx: {}, matched: {}\n", .{ idx, matched });
        var cidx: u32 = @as(u32, @intCast(idx)) + 1;
        while (cidx <= idx + matched) : (cidx += 1) {
            wc_input[cidx] += (1 * wc_input[idx]);
        }
        for (wc_input) |c| {
            dprint("{} ", .{c});
        }
        dprint("\n", .{});
    }

    var sum: u32 = 0;
    for (wc_input) |c| {
        sum += c;
    }
    dprint("sum: {}\n", .{sum});
}

fn part1(allocator: mem.Allocator, input: [][]const u8) !void {
    var sum: u32 = 0;
    for (input) |line| {
        var card_iter = mem.splitSequence(u8, line, ": ");
        _ = card_iter.next().?;
        var card_nums = card_iter.next().?;
        var split_iter = mem.splitSequence(u8, card_nums, " | ");

        // use tokenize because there can be multiple space before number (due to padding in input)
        var set1 = mem.tokenizeAny(u8, split_iter.next().?, " ");
        var set2 = mem.tokenizeAny(u8, split_iter.next().?, " ");
        var arr1 = ArrayList(u32).init(allocator);
        defer arr1.deinit();
        while (set1.next()) |str| {
            const num = try std.fmt.parseInt(u32, str, 10);
            try arr1.append(num);
        }
        var arr2 = ArrayList(u32).init(allocator);
        defer arr2.deinit();
        while (set2.next()) |str| {
            const num = try std.fmt.parseInt(u32, str, 10);
            try arr2.append(num);
        }
        var times: u32 = 0;
        var card_sum: u32 = 0;
        for (arr2.items) |num2| {
            for (arr1.items) |num1| {
                if (num1 == num2) {
                    card_sum = @intFromFloat(math.pow(2, @floatFromInt(times)));
                    dprint("card_sum: {}\n", .{card_sum});
                    times += 1;
                }
            }
        }
        sum += card_sum;
        dprint("line: {s} | sum: {}\n", .{ line, sum });
    }

    dprint("sum: {}\n", .{sum});
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(child_allocator);
    var allocator = arena.allocator();
    defer arena.deinit();

    const input = try split_lines(allocator, FILENAME);

    for (input) |line| {
        dprint("{s}\n", .{line});
    }

    // try part1(allocator, input);
    try part2(allocator, input);
}
