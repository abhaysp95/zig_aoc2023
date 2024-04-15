const std = @import("std");
const dprint = std.debug.print;
const ArrayList = std.ArrayList;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const child_allocator = gpa.allocator();

const INPUT = "./input.txt";
const ALLOC_SIZE = 1_00_000;

fn part1(times: ArrayList(usize), dists: ArrayList(usize)) void {
    var error_margin: usize = 1;
    const sz = times.items.len;
    var idx: usize = 0;

    while (idx < sz) : (idx += 1) {
        var tdx: usize = 1;
        var pass_count: usize = 0;
        while (tdx <= times.items[idx]) : (tdx += 1) {
            // dprint("times.items[{}] = {}, tdx = {}", .{ idx, times.items[idx], tdx });
            const my_dist = (times.items[idx] - tdx) * tdx;
            if (my_dist > dists.items[idx]) {
                // dprint(" [incl] = {}\n", .{my_dist});
                pass_count += 1;
            } else {
                // dprint("\n", .{});
            }
        }
        // dprint("time: {}, dist: {}, margin: {}\n", .{ times.items[idx], dists.items[idx], pass_count });
        error_margin *= pass_count;
    }

    dprint("error_margin: {}\n", .{error_margin});
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(child_allocator);
    var allocator = arena.allocator();

    const file = try std.fs.cwd().openFile(INPUT, .{});
    const content = try file.reader().readAllAlloc(allocator, ALLOC_SIZE);

    var iterator = std.mem.tokenizeAny(u8, content, "\n");

    var time_line = std.mem.tokenizeAny(u8, iterator.next().?, ": ");
    _ = time_line.next().?;
    var dist_line = std.mem.tokenizeAny(u8, iterator.next().?, ": ");
    _ = dist_line.next().?;

    var times = ArrayList(usize).init(allocator);
    defer times.deinit();
    errdefer times.deinit();
    var dists = ArrayList(usize).init(allocator);
    defer dists.deinit();
    errdefer dists.deinit();

    while (time_line.next()) |t| {
        try times.append(try std.fmt.parseInt(usize, t, 10));
    }
    while (dist_line.next()) |d| {
        try dists.append(try std.fmt.parseInt(usize, d, 10));
    }

    part1(times, dists);
}
