# Test with truly simultaneous requests (no stagger)
Write-Host "`nStarting 16 simultaneous requests...`n" -ForegroundColor Green

$jobs = @()
# Start all jobs at once without delays
1..16 | ForEach-Object {
    $jobs += Start-Job -ScriptBlock { 
        param($requestId)
        $startTime = Get-Date
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:3000/heavy-task" `
                -UseBasicParsing `
                -DisableKeepAlive
            
            $endTime = Get-Date
            $elapsed = ($endTime - $startTime).TotalSeconds
            
            # Extract Worker PID from response
            if ($response.Content -match 'Worker PID: (\d+)') {
                $workerPid = $matches[1]
            } else {
                $workerPid = "Unknown"
            }
            
            # Return as PSCustomObject for proper formatting
            [PSCustomObject]@{
                RequestId = $requestId
                Time = [math]::Round($elapsed, 2)
                WorkerPID = $workerPid
            }
        } catch {
            [PSCustomObject]@{
                RequestId = $requestId
                Time = 0
                WorkerPID = "Error: $($_.Exception.Message)"
            }
        }
    } -ArgumentList $_
}

Write-Host "Waiting for all requests to complete...`n" -ForegroundColor Yellow
$results = $jobs | Wait-Job | Receive-Job
$jobs | Remove-Job

# Display results in a table
$results | Sort-Object RequestId | Format-Table -Property RequestId, @{Label="Time(s)";Expression={$_.Time}}, WorkerPID -AutoSize

# Count unique workers
$uniqueWorkers = ($results | Where-Object {$_.WorkerPID -and $_.WorkerPID -match '^\d+$'} | Select-Object -Property WorkerPID -Unique).Count
$maxTime = ($results | Measure-Object -Property Time -Maximum).Maximum
Write-Host "`nUnique workers used: $uniqueWorkers out of 16 requests" -ForegroundColor Cyan
Write-Host "Max time: $maxTime seconds (ideal: ~5s for perfect parallelization)" -ForegroundColor Cyan
Write-Host "Ideal: All 16 requests should use different workers and complete in ~5 seconds each`n" -ForegroundColor Gray
