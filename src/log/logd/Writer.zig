const std = @import("std");
const atomic = std.atomic;
const os = std.os;
const net = std.net;
const Writer = @This();

blocking: bool,
sock: atomic.Value(?*net.Stream) = atomic.Value(?*net.Stream).init(null),

pub fn open(self: *Writer) !void {
    var sock = try connectUnixSocket(self.blocking);
    if (self.sock.cmpxchgStrong(null, &sock, .SeqCst, .SeqCst) == null) {
        sock.close();
        return;
    }
    return;
}

pub fn close(self: *Writer) void {
    const old = self.sock.load(.SeqCst);
    if (old == null) return;
    if (self.sock.cmpxchgStrong(old, null, .SeqCst, .SeqCst)) |sock| {
        sock.?.close();
    }
}

pub fn reconnect(self: *Writer) !void {
    var sock = try connectUnixSocket(self.blocking);
    _ = self.sock.swap(&sock, .SeqCst);
}

pub fn writev(self: *Writer, iovecs: []const os.iovec_const) !usize {
    return self.sock.load(.SeqCst).?.writev(iovecs);
}

fn connectUnixSocket(blocking: bool) !net.Stream {
    const opt_non_block: u32 = if (!blocking) os.SOCK.NONBLOCK else 0;
    const sockfd = try os.socket(
        os.AF.UNIX,
        os.SOCK.DGRAM | os.SOCK.CLOEXEC | opt_non_block,
        0,
    );
    errdefer os.closeSocket(sockfd);
    const saddr = try net.Address.initUnix("/dev/socket/logdw");
    try os.connect(sockfd, &saddr.any, saddr.getOsSockLen());
    return .{ .handle = sockfd };
}
