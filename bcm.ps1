if($args.length -lt 2) {
	$secs = ($args[0] | Measure-Command {./bci $_ | Out-Default}).TotalSeconds
} else {
	$secs = (@($args[0],$args[1]),1 | Measure-Command {(./bci $_[0] $_[1]) | Out-Default}).TotalSeconds
}
echo $([math]::Round($secs, 5))