const std = @import("std");
const net = std.net;
const time = std.time;
const os = std.os;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // configuración inicial
    const host = "127.0.0.1";
    const port: u16 = 9000;

    // se tiene la stdout
    const stdout = std.io.getStdOut().writer();

    // se abre el socker y se captura el error
    _ = net.tcpConnectToHost(allocator, host, port) catch |err| {
        if (err == error.ConnectionRefused) {
            try stdout.print("Puerto {d} está cerrado\n", .{port});
            return;
        }
    };

    // si llegamos aqui el puerto estará abierto
    try stdout.print("Puerto {d} está abierto \n", .{port});
}
