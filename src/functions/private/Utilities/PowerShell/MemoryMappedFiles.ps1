# Quick write test
$map = [System.IO.MemoryMappedFiles.MemoryMappedFile]::CreateOrOpen('TestMap', 1024)
$accessor = $map.CreateViewAccessor()
$data = 'TestData'
$bytes = [System.Text.Encoding]::UTF8.GetBytes($data)
$accessor.Write(0, [int]$bytes.Length)
$accessor.WriteArray(4, $bytes, 0, $bytes.Length)
$accessor.Dispose()
$map.Dispose()

# Quick read test
$map = [System.IO.MemoryMappedFiles.MemoryMappedFile]::OpenExisting('TestMap')
$accessor = $map.CreateViewAccessor()
[int]$length = 0
$accessor.Read(0, [ref]$length)
$bytes = New-Object byte[] $length
$accessor.ReadArray(4, $bytes, 0, $length) | Out-Null
$data = [System.Text.Encoding]::UTF8.GetString($bytes)
Write-Host "Data read from memory: $data"
$accessor.Dispose()
$map.Dispose()
