$times = @()
foreach($i in 1..10) {
	$time = (./bcm $args[0])
	echo "$($args[0]) ran for $time seconds."
	$times += $time
}
echo $times