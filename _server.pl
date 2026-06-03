#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;
use IO::Select;

my $port = $ARGV[0] || 4173;
my $root = $ARGV[1] || ".";

my %mime = (
  html => "text/html; charset=utf-8",
  css  => "text/css; charset=utf-8",
  js   => "application/javascript; charset=utf-8",
  svg  => "image/svg+xml",
  png  => "image/png",
  jpg  => "image/jpeg",
  jpeg => "image/jpeg",
  gif  => "image/gif",
  ico  => "image/x-icon",
);

my $server = IO::Socket::INET->new(
  LocalAddr => "127.0.0.1",
  LocalPort => $port,
  Proto     => "tcp",
  Listen    => 10,
  ReuseAddr => 1,
) or die "Cannot bind to port $port: $!\n";

$| = 1;
print "Serving $root on http://127.0.0.1:$port\n";

my $sel = IO::Select->new($server);

while (1) {
  my @ready = $sel->can_read(1);
  next unless @ready;
  my $client = $server->accept() or next;

  # 投機的接続でリクエストが来ない場合に詰まらないようタイムアウト
  my $csel = IO::Select->new($client);
  unless ($csel->can_read(3)) {
    close($client);
    next;
  }

  my $req = <$client>;
  if (defined $req && $req =~ m{^GET\s+(\S+)\s+HTTP}) {
    my $path = $1;
    $path =~ s/\?.*$//;
    $path = "/index.html" if $path eq "/";
    $path =~ s{\.\.}{}g;
    my $file = $root . $path;
    if (-f $file) {
      my ($ext) = $file =~ /\.([^.]+)$/;
      $ext = lc($ext || "");
      my $type = $mime{$ext} || "application/octet-stream";
      open(my $fh, "<:raw", $file);
      local $/;
      my $body = <$fh>;
      close($fh);
      print $client "HTTP/1.1 200 OK\r\n";
      print $client "Content-Type: $type\r\n";
      print $client "Content-Length: " . length($body) . "\r\n";
      print $client "Connection: close\r\n\r\n";
      print $client $body;
    } else {
      my $body = "404 Not Found: $path";
      print $client "HTTP/1.1 404 Not Found\r\n";
      print $client "Content-Type: text/plain; charset=utf-8\r\n";
      print $client "Content-Length: " . length($body) . "\r\n";
      print $client "Connection: close\r\n\r\n";
      print $client $body;
    }
  }
  close($client);
}
