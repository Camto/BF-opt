$secs = ($args[0] | Measure-Command {./bci $_ | Out-Default}).TotalSeconds
echo $([math]::Round($secs, 5))