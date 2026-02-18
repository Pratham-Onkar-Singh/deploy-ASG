# Test parallel load balancing
Write-Host "`nStarting 16 parallel requests across all workers...`n" -ForegroundColor Green

$jobs = 1..16 | ForEach-Object {
    $id = $_
    Start-Job -ScriptBlock {
        param($requestId)
        $startTime = Get-Date
        try {
            # Force new connection each time
            $response = Invoke-WebRequest -Uri "http://localhost:3000/heavy-task" `
                -UseBasicParsing `
                -MaximumRedirection 0 `
                -DisableKeepAlive
            
            $endTime = Get-Date
            $elapsed = ($endTime - $startTime).TotalSeconds
            
            $snippet = if ($response.Content.Length -gt 100) { $response.Content.Substring(0, 100) } else { $response.Content }
            Write-Output "Request $requestId - Time: $elapsed seconds - Response: $snippet"
        } catch {
            Write-Output "Request $requestId - ERROR: $_"
        }
    } -ArgumentList $id
}

Write-Host "Waiting for responses (this should take ~15-20 seconds if parallel)..." -ForegroundColor Yellow
$jobs | Wait-Job | Receive-Job
$jobs | Remove-Job

Write-Host "`nDone! Check server logs to see which workers handled the requests.`n" -ForegroundColor Green
