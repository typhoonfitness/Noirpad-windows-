# NoirPad local server - serves this folder at http://localhost:8420
# so browser extensions like QuillBot (which ignore file:// pages) can run.
# ASCII-only file: Windows PowerShell reads .ps1 without a BOM as ANSI.

$port = 8420
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$url  = "http://localhost:$port/NoirPad.html"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")

try {
    $listener.Start()
} catch {
    # Port already in use - a server is probably already running. Just open the page.
    Start-Process $url
    exit
}

Start-Process $url
Write-Host ""
Write-Host "  NOIR//PAD is running at $url" -ForegroundColor White
Write-Host "  Keep this window open while you write. Close it (or press Ctrl+C) to stop." -ForegroundColor DarkGray
Write-Host ""

$mime = @{
    ".html" = "text/html; charset=utf-8"
    ".htm"  = "text/html; charset=utf-8"
    ".txt"  = "text/plain; charset=utf-8"
    ".md"   = "text/plain; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".js"   = "text/javascript; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
}

while ($listener.IsListening) {
    try {
        $ctx = $listener.GetContext()
        $req = $ctx.Request
        $res = $ctx.Response

        $rel = [System.Uri]::UnescapeDataString($req.Url.AbsolutePath).TrimStart('/')
        if ([string]::IsNullOrWhiteSpace($rel)) { $rel = "NoirPad.html" }

        $path = Join-Path $root $rel
        $full = [System.IO.Path]::GetFullPath($path)

        # block path traversal outside this folder
        if (-not $full.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase) -or
            -not (Test-Path $full -PathType Leaf)) {
            $res.StatusCode = 404
            $msg = [System.Text.Encoding]::UTF8.GetBytes("404 - lost in the fog")
            $res.OutputStream.Write($msg, 0, $msg.Length)
            $res.Close()
            continue
        }

        $ext = [System.IO.Path]::GetExtension($full).ToLower()
        if ($mime.ContainsKey($ext)) { $res.ContentType = $mime[$ext] }
        else { $res.ContentType = "application/octet-stream" }
        $bytes = [System.IO.File]::ReadAllBytes($full)
        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
        $res.Close()
    } catch {
        # ignore individual request errors, keep serving
    }
}
