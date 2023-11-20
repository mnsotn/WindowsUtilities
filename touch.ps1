#=============================================================================#
function InRange ($val, $low, $high) {

	$val = [int]$val

	if (-not (($val -ge $low) -and ($val -le $high))) {
		write-host -NoNewline $val": " 
		return $false
	}
	return $true
}
#-----------------------------------------------------------------------------#
function IsInt ($val) {
	try {
		# Test for int:  Try to cast to int
		$num = [int]$val
		return $true
	}
	catch {
		# Not an int
		write-host Invalid input: $val
		return $false 
	}
}
#-----------------------------------------------------------------------------#
function ShowUsage {
	write-host "usage: $miNombre path"
	write-host "       $miNombre path -t yyyymmddHHMMSS"
	write-host "       $miNombre path year month day hour minute second"
}
#=============================================================================#

$miNombre = (Get-Item $PSCommandPath ).Basename

# Number of arguments

$numArgs = $Args.count

if ($numArgs -eq 0) {
	ShowUsage
	exit 0
}

if (($numArgs -ne 1) -and `
    ($numArgs -ne 3) -and `
	($numArgs -ne 7)) {
	ShowUsage
	exit 1
}

# -----------------------------------------------------------------------------
# Parse/check arguments

$path = $args[0]

if ($numArgs -eq 1) {
	$year   = Get-Date -UFormat "%Y"
	$month  = Get-Date -UFormat "%m"
	$day    = Get-Date -UFormat "%d"
	$hour   = Get-Date -UFormat "%H"
	$minute = Get-Date -UFormat "%M"
	$second = Get-Date -UFormat "%S"
}
if ($numArgs -eq 3) {
	if ($args[1] -ne '-t') {
		ShowUsage
		exit 1
	}
	$stampString = $args[2]
	if ($stampString.length -ne 14) {
		write-host Invalid time string
		ShowUsage
		exit 1
	}
	$year   = $stampString.Substring( 0, 4)
	$month  = $stampString.Substring( 4, 2)
	$day    = $stampString.Substring( 6, 2)
	$hour   = $stampString.Substring( 8, 2)
	$minute = $stampString.Substring(10, 2)
	$second = $stampString.Substring(12, 2)
}

if ($numArgs -eq 7) {
	$year   = $args[1]
	$month  = $args[2]
	$day    = $args[3]
	$hour   = $args[4]
	$minute = $args[5]
	$second = $args[6]
}

# -----------------------------------------------------------------------------
# Check for integers

if (-not ((IsInt $year) -and `
          (IsInt $month) -and `
          (IsInt $day) -and `
          (IsInt $hour) -and `
          (IsInt $minute) -and `
          (IsInt $second))) {
	exit 1
}

# -----------------------------------------------------------------------------
# Check for range

if (-not ((InRange $year 1600 2107) -and
		  (InRange $month   1   12) -and
		  (InRange $day     1   31) -and
		  (InRange $hour    0   59) -and
		  (InRange $minute  0   59) -and
		  (InRange $second  0   60))) {
	write-host Out-of-range value
	exit 1
}

# -----------------------------------------------------------------------------
# If file doesn't exist, create it

if (-not (Get-Item $path -ErrorAction Ignore)) {
	New-Item $path -type file > $null
	if (-not (Get-Item $path -ErrorAction Ignore)) {
		write-host Not able to create $path 
		exit 1
	}
}

# -----------------------------------------------------------------------------
# Put requested time on the file

if (($numArgs -eq 3) -or ($numArgs -eq 7)) {
	# Touch with given time
	(Get-Item "$path").LastWriteTime = Get-Date -Year $year `
	                                            -Month $month `
	                                            -Day $day `
	                                            -Hour $hour `
	                                            -Minute $minute `
	                                            -Second $second
} else {
	# Touch with current time
	(Get-Item "$path").LastWriteTime = Get-Date
}

exit 0
