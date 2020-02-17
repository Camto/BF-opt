$program_name = [System.IO.Path]::GetFileNameWithoutExtension($args[0])

$opts = "set", "mult", "linear"
foreach($opt in $opts) {
	"./bfc ""$($args[0])"" ""{opts={$opt=true},outfile='../BF Programs/$program_name$opt.bc'}"""
	./bfc $args[0] "{opts={$opt=true},outfile='../BF Programs/$program_name$opt.bc'}"
}