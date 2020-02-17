$times = @()

$samples = 0
if($args.length -lt 3) {
	$samples = $args[1]
} else {
	$samples = $args[2]
}

foreach($i in 1..$samples) {
	$time = 0
	if($args.length -lt 3) {
		$time = ./bcm $args[0]
	} else {
		$time = ./bcm $args[0] $args[1]
	}
	echo "$($args[0]) ran for $time seconds."
	$times += $time
}

echo $times
echo "Average is $([math]::Round(($times | Measure-Object -Average).Average, 5))"