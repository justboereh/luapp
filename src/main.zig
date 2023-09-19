const std = @import("std");
const cli = @import("zig-cli");
const String = @import("zig-string").String;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

var analyze = cli.Option{
    .long_name = "analyze",
    .help = "analyze the code without running it",
    .value = cli.OptionValue{ .bool = false },
};

const app = &cli.App{
    .name = "luapp",
    .description = "A Lua compiler",
    .options = &.{&analyze},
    .action = run,
};

pub fn main() !void {
    return cli.run(app, allocator);
}

fn print(str: []const u8, code: u8) void {
    std.debug.print("{s}", .{str});

    std.process.exit(code);
}

fn run(args: []const []const u8) !void {
    if (args.len < 1) {
        print("Lua file is required");
    }

    var source = std.fs.cwd().openFile(args[0], .{}) catch |err| {
        if (err != error.IsDir) {
            print("Lua file doesn't exists");
        }

        var path = String.init(allocator);
        defer path.deinit();

        try path.concat(args[0]);
        try path.concat("/main.lua");

        var dirSource = std.fs.cwd().openFile(path.str(), .{}) catch {
            print("Main Lua file doesn't exists");
        };
        defer dirSource.close();

        return dirSource;
    };

    defer source.close();

    std.debug.print("{!}", .{source});
}
