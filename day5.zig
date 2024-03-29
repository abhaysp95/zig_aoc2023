const std = @import("std");
const mem = std.mem;
const ArrayList = std.ArrayList;
const dprint = std.debug.print;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const child_allocator = gpa.allocator();

const ALLOC_SIZE = 1e5;
const INPUT = "./input.txt";

const Mapper = struct {
    dest: u32,
    src: u32,
    range: u32,
};

pub fn main() !void {
    const file = try std.fs.cwd().openFile(INPUT, .{});
    const content = try file.reader().readAllAlloc(child_allocator, ALLOC_SIZE);

    var iterator = std.mem.tokenizeAny(u8, content, "\n");

    var arena = std.heap.ArenaAllocator.init(child_allocator);
    var allocator = arena.allocator();

    var seed_split = std.mem.splitSequence(u8, iterator.next().?, ": ");
    _ = seed_split.next().?;

    var seeds_iter = std.mem.splitSequence(u8, seed_split.next().?, " ");
    var seeds = try allocator.alloc(u32, 1);

    var seed_idx: u32 = 0;
    while (seeds_iter.next()) |s| {
        seeds[seed_idx] = try std.fmt.parseInt(u32, s, 10);
        seed_idx += 1;
        if (seeds.len <= seed_idx) {
            seeds = try allocator.realloc(seeds, seeds.len * 2);
        }
    }
    if (seeds.len > seed_idx) {
        seeds = try allocator.realloc(seeds, seed_idx);
    }
    // for (seeds) |s| {
    //     dprint("seed: {d}\n", .{s});
    // }

    var mappings = try allocator.alloc([]Mapper, 7);
    var idx: u32 = 0;

    var clen: u32 = 0;
    mappings[idx] = try allocator.alloc(Mapper, 1);
    _ = iterator.next().?;
    while (iterator.next()) |line| {
        if (mem.containsAtLeast(u8, line, 1, "map")) {
            if (mappings[idx].len != clen) {
                mappings[idx] = try allocator.realloc(mappings[idx], clen);
            }
            clen = 0;
            idx += 1;
            mappings[idx] = try allocator.alloc(Mapper, 1);
        } else {
            if (clen == mappings[idx].len) {
                mappings[idx] = try allocator.realloc(mappings[idx], mappings[idx].len * 2);
            }
            var mapcode_iter = mem.tokenizeAny(u8, line, " ");
            mappings[idx][clen].dest = try std.fmt.parseInt(u32, mapcode_iter.next().?, 10);
            mappings[idx][clen].src = try std.fmt.parseInt(u32, mapcode_iter.next().?, 10);
            mappings[idx][clen].range = try std.fmt.parseInt(u32, mapcode_iter.next().?, 10);
            clen += 1;
        }
    }

    const last_idx = mappings.len - 1;
    if (mappings[last_idx].len != clen) {
        mappings[last_idx] = try allocator.realloc(mappings[last_idx], clen);
    }

    // printing things now

    for (mappings) |mapping| {
        for (mapping) |map| {
            dprint("src: {d}, dest: {d}, range: {d}\n", .{ map.src, map.dest, map.range });
        }
        dprint("\n", .{});
    }

    // try part1(seeds, mappings);
}
