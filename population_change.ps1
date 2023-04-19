function Get-PrimeFactors {
    param([int64]$number)
    $factors = @()
    $divisor = 2
    while ($number -gt 1) {
        while ($number % $divisor -eq 0) {
            $factors += $divisor
            $number /= $divisor
        }
        $divisor++
    }
    return $factors -join ";"
}

# URL with the  data
$url = "https://datausa.io/api/data?drilldowns=State&measures=Population"

$allData = (Invoke-WebRequest -Uri $url).Content | ConvertFrom-Json
$populationData2019 = $allData | Where-Object { $_."Year" -eq "2019" }
$populationData2020 = $allData | Where-Object { $_."Year" -eq "2020" }

$reportData = @()

foreach ($stateData2020 in $populationData2020) {
    $stateData2019 = $populationData2019 | Where-Object { $_."ID State" -eq $stateData2020."ID State" }
    $populationChange = $stateData2020.Population - $stateData2019.Population
    $percentageChange = ($populationChange / $stateData2019.Population) * 100
    $primeFactors = Get-PrimeFactors -number $stateData2020.Population

    $reportData += New-Object PSObject -Property @{
        "State" = $stateData2020.State
        "Population Change" = "{0} ({1:P2})" -f $populationChange, ($percentageChange / 100)
        "Prime Factors" = $primeFactors
    }
}

$reportData | Export-Csv -Path "PopulationReport.csv" -NoTypeInformation
