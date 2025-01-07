const std = @import("std");
const net = std.net;
const time = std.time;
const Address = std.net.Address;
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;

const PortRange = struct {
    start: u16,
    end: u16,
};

const ScanResult = struct {
    port: u16,
    is_open: bool,
    response_time_ns: u64,
};

pub fn main() !void {

    // inicializa el allocator
    var gpa = GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // configuración del escaneo
    const target_host = "127.0.0.1";
    const port_range = PortRange{ .start = 1, .end = 3000 };
    // const timeout_ms = 1000;

    // realizar escaneo
    var results = std.ArrayList(ScanResult).init(allocator);
    defer results.deinit();

    try scanPorts(target_host, port_range, &results);

    // imprime los resultados
    for (results.items) |result| {
        if (result.is_open) {
            std.debug.print("Puerto {d} está abierto (tiempo de respuesta: {d})ns \n", .{ result.port, result.response_time_ns });
        }
    }
}

fn scanPorts(
    target_host: []const u8,
    port_range: PortRange,
    // timeout_ms: u64,
    results: *std.ArrayList(ScanResult),
) !void {
    var current_port = port_range.start;

    while (current_port <= port_range.end) : (current_port += 1) {
        const result = try scanSinglePort(target_host, current_port);
        try results.append(result);
    }
}

fn scanSinglePort(target_host: []const u8, port: u16) !ScanResult {
    const start_time = time.nanoTimestamp();

    // crea la dirección de destino
    const address = try Address.resolveIp(target_host, port);

    // intenta establecer la conexión
    const stream = net.tcpConnectToAddress(address) catch {
        return ScanResult{
            .port = port,
            .is_open = false,
            .response_time_ns = 0,
        };
    };
    defer stream.close();

    const end_time = time.nanoTimestamp();

    const response_time = @as(u64, @intCast(end_time - start_time));

    return ScanResult{ .port = port, .is_open = true, .response_time_ns = response_time };
}
