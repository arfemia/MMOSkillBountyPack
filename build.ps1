# Build MMOSkillBountyPack.zip with forward-slash entries AND explicit directory
# entries for every ancestor path. The directory entries matter now that the pack
# ships Server/Languages/*.lang and Server/Item/**: Java's ZipFileSystem.isDirectory()
# returns false without them, so Hytale's I18nModule.loadMessagesFromPack would skip
# the lang file. Never use Compress-Archive (it writes backslash separators that Hytale
# drops on Windows). Mirrors the taming pack recipe. Pass no args; copies the result
# into the Hytale Mods folder.
$pack = $PSScriptRoot
$zipPath = Join-Path $pack 'MMOSkillBountyPack.zip'
Remove-Item $zipPath -ErrorAction SilentlyContinue
Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
$zip = [IO.Compression.ZipFile]::Open($zipPath, 'Create')
try {
    $files = Get-ChildItem -Path $pack -Recurse -File | Where-Object {
        $_.Name -notin 'MMOSkillBountyPack.zip', 'README.md', 'CURSEFORGE.md', 'CLAUDE.md', 'build.ps1'
    }
    $createdDirs = @{}
    foreach ($f in $files) {
        $rel = $f.FullName.Substring($pack.Length + 1).Replace('\', '/')
        # Emit a directory entry for each ancestor path (once), so the zip reports
        # them as real directories to Java's ZipFileSystem.
        $parts = $rel -split '/'
        for ($i = 1; $i -lt $parts.Length; $i++) {
            $dir = ($parts[0..($i - 1)] -join '/') + '/'
            if (-not $createdDirs.ContainsKey($dir)) {
                $zip.CreateEntry($dir, [IO.Compression.CompressionLevel]::NoCompression).Open().Close()
                $createdDirs[$dir] = $true
            }
        }
        $entry = $zip.CreateEntry($rel, [IO.Compression.CompressionLevel]::Optimal)
        $stream = $entry.Open()
        $bytes = [IO.File]::ReadAllBytes($f.FullName)
        $stream.Write($bytes, 0, $bytes.Length)
        $stream.Close()
    }
    Write-Output "Packed $($files.Count) files + $($createdDirs.Count) dir entries -> $zipPath"
} finally {
    $zip.Dispose()
}
$mods = 'D:\Games\Hytale\UserData\Mods\MMOSkillBountyPack.zip'
Copy-Item $zipPath $mods -Force
Write-Output "Copied to $mods"
