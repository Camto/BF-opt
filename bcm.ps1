$secs = ($args[0] | Measure-Command {./bci $_ | Out-Default}).TotalSeconds
"The program ran for $([math]::Round($secs, 3)) seconds."