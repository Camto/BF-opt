$times = @()
foreach($i in 1..$args[1]) {
	$time = (./bcm $args[0])
	echo "$($args[0]) ran for $time seconds."
	$times += $time
}
echo $times
echo "Average is $([math]::Round(($times | Measure-Object -Average).Average, 3))"