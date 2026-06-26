param(
  [int]$Port = 4173,
  [string]$Root = "."
)

# Minimal static file server for environments without Perl/Python/Node (dev preview only).
# Concurrent: a runspace pool serves multiple requests at once.
$ErrorActionPreference = "Stop"
$rootPath = (Resolve-Path $Root).Path

$mime = @{
  ".html" = "text/html; charset=utf-8"
  ".htm"  = "text/html; charset=utf-8"
  ".css"  = "text/css; charset=utf-8"
  ".js"   = "application/javascript; charset=utf-8"
  ".json" = "application/json; charset=utf-8"
  ".svg"  = "image/svg+xml"
  ".jpg"  = "image/jpeg"
  ".jpeg" = "image/jpeg"
  ".png"  = "image/png"
  ".gif"  = "image/gif"
  ".webp" = "image/webp"
  ".ico"  = "image/x-icon"
  ".woff" = "font/woff"
  ".woff2"= "font/woff2"
  ".txt"  = "text/plain; charset=utf-8"
}

# Handler that serves a single connection (runs inside a runspace).
$handler = {
  param($client, $rootPath, $mime)
  try {
    $stream = $client.GetStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $requestLine = $reader.ReadLine()
    if ($requestLine) {
      $parts = $requestLine.Split(" ")
      $rawPath = if ($parts.Length -ge 2) { $parts[1] } else { "/" }
      $urlPath = $rawPath.Split("?")[0]
      $urlPath = [System.Uri]::UnescapeDataString($urlPath)
      if ($urlPath -eq "/") { $urlPath = "/index.html" }

      $relative = $urlPath.TrimStart("/")
      $fullPath = [System.IO.Path]::GetFullPath((Join-Path $rootPath $relative))

      $writer = New-Object System.IO.BinaryWriter($stream)
      if ($fullPath.StartsWith($rootPath) -and (Test-Path $fullPath -PathType Leaf)) {
        $ext = [System.IO.Path]::GetExtension($fullPath).ToLower()
        $ctype = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { "application/octet-stream" }
        $bytes = [System.IO.File]::ReadAllBytes($fullPath)
        $header = "HTTP/1.1 200 OK`r`nContent-Type: $ctype`r`nContent-Length: $($bytes.Length)`r`nConnection: close`r`n`r`n"
        $writer.Write([System.Text.Encoding]::ASCII.GetBytes($header))
        $writer.Write($bytes)
      } else {
        $body = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
        $header = "HTTP/1.1 404 Not Found`r`nContent-Type: text/plain; charset=utf-8`r`nContent-Length: $($body.Length)`r`nConnection: close`r`n`r`n"
        $writer.Write([System.Text.Encoding]::ASCII.GetBytes($header))
        $writer.Write($body)
      }
      $writer.Flush()
    }
  } catch {
    # ignore per-request errors and keep serving
  } finally {
    $client.Close()
  }
}

$pool = [runspacefactory]::CreateRunspacePool(1, 12)
$pool.Open()

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $Port)
$listener.Start()
Write-Host "Serving $rootPath on http://127.0.0.1:$Port/ (concurrent)"

$jobs = New-Object System.Collections.ArrayList
while ($true) {
  $client = $listener.AcceptTcpClient()
  $ps = [powershell]::Create()
  $ps.RunspacePool = $pool
  [void]$ps.AddScript($handler).AddArgument($client).AddArgument($rootPath).AddArgument($mime)
  $async = $ps.BeginInvoke()
  [void]$jobs.Add([pscustomobject]@{ PS = $ps; Async = $async })

  # periodically reap finished handlers to avoid leaking handles
  if ($jobs.Count -gt 24) {
    $done = @($jobs | Where-Object { $_.Async.IsCompleted })
    foreach ($d in $done) {
      try { $d.PS.EndInvoke($d.Async) } catch {}
      $d.PS.Dispose()
      [void]$jobs.Remove($d)
    }
  }
}
