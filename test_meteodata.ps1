docker-machine env test | Invoke-Expression

docker-compose --file C:\GitHub\influx-grafana\docker-compose.yml build

docker-compose --file C:\GitHub\influx-grafana\docker-compose.yml up

### parse docker machine

# new powershell
.\docker_env.ps1
docker-machine env test | Invoke-Expression
$Docker_IP = (($env:DOCKER_HOST -replace "tcp://","") -split ":")[0]
#database name
$database = "meteohub"

### set influx uri´s

$Influx_URI = "http://$($Docker_IP):8086"
$influx_write_uri=”$($Influx_URI)/write?db=$database&precision=ms”
$influx_query_uri=”$($Influx_URI)/query?db=$database”

### note there is neither a rest api, nor a json protocol in iflux "!"!!!
$authheader = "Basic " + ([Convert]::ToBase64String([System.Text.encoding]::ASCII.GetBytes("meteohub:meteohub")))
$postParams = "q=CREATE DATABASE `"$database`""
Invoke-WebRequest -Method POST -uri "$Influx_URI/query" -Body  $postParams  -Verbose

$postParams = "q=CREATE USER meteohub WITH PASSWORD 'meteohub' WITH ALL PRIVILEGES"
Invoke-WebRequest -Method POST -uri "$Influx_URI/query"  -Body  $postParams  -Verbose

## verify db`s
$IE=new-object -com internetexplorer.application
$IE.navigate2("http://$($Docker_IP):3000")
$IE.visible=$true


$IE=new-object -com internetexplorer.application
$IE.navigate2("http://$($Docker_IP):8083")
$IE.visible=$true

### published data
$postParams = 'q=SELECT * FROM "(th0)_data"'
$result = Invoke-RestMethod -Method POST -uri $influx_query_uri  -Body  $postParams  -Verbose # -ContentType 'application/json'


ipmo C:\GitHub\meteohub-dataclient
$Station = "meteohub.fritz.box"
Get-MHDSensorData -Station $Station -ID th0

## SELECT * FROM "(th0)_data"

$ts = New-TimeSpan -Hours 1
do {

$sensorid = "th0"
$DATA = Get-MHDSensorData -Station $Station -ID $sensorid 
$mydate = $DATA.date
$mydate_convert=[datetime]::ParseExact($mydate,"yyyyMMddHHmmss",$null) + $ts
$mydate_epoch = ([DateTimeOffset]$mydate_convert).ToUnixTimeMilliseconds()
$mydate_convert
$postParams = "($sensorid)_data temperature=$($DATA.temp/1),dew=$($data.dew/1),humidity=$($DATA.hum/1),sensor=`"$sensorid`",sensortype=`"$sensortype`" $mydate_epoch" 
Write-Verbose $postParams
Write-host "Posting with $postParams"
Invoke-RestMethod -Headers @{Authorization=$authheader} -Uri $influx_write_uri -Method POST -Body  $postParams 

$sensorid = "wind0"
$DATA = Get-MHDSensorData -Station $Station -ID $sensorid 
$mydate = $DATA.date
$mydate_convert=[datetime]::ParseExact($mydate,"yyyyMMddHHmmss",$null) + $ts
$mydate_convert
$mydate_epoch = ([DateTimeOffset]$mydate_convert).ToUnixTimeMilliseconds()
$postParams = "($sensorid)_data chill=$($DATA.chill/1),direction=$($DATA.dir/1),gust=$($DATA.gust/1),wind=$($DATA.wind/1),sensor=`"$sensorid`",sensortype=`"$sensortype`" $mydate_epoch" 
Write-Verbose $postParams
Write-host "Posting with $postParams"
Invoke-RestMethod -Headers @{Authorization=$authheader} -Uri $influx_write_uri -Method POST -Body  $postParams 


$sensorid = "rain0"
$DATA = Get-MHDSensorData -Station $Station -ID $sensorid 
$mydate = $DATA.date
$mydate_convert=[datetime]::ParseExact($mydate,"yyyyMMddHHmmss",$null) + $ts
$mydate_convert
$mydate_epoch = ([DateTimeOffset]$mydate_convert).ToUnixTimeMilliseconds()
$postParams = "($sensorid)_data delta=$($DATA.delta/1),rate=$($DATA.rate/1),total=$($DATA.total/1),sensor=`"$sensorid`",sensortype=`"$sensortype`" $mydate_epoch" 
Write-host "Posting with $postParams"
Invoke-RestMethod -Headers @{Authorization=$authheader} -Uri $influx_write_uri -Method POST -Body  $postParams 


$sensorid = "thb0"
$DATA = Get-MHDSensorData -Station $Station -ID $sensorid 
$mydate = $DATA.date
$mydate_convert=[datetime]::ParseExact($mydate,"yyyyMMddHHmmss",$null) + $ts
$mydate_convert
$mydate_epoch = ([DateTimeOffset]$mydate_convert).ToUnixTimeMilliseconds()
$postParams = "($sensorid)_data press=$($DATA.press/1),forecast=$($DATA.fc/1),humidity=$($DATA.hum/1),roomtemp=$($DATA.temp/1),sensor=`"$sensorid`",sensortype=`"$sensortype`" $mydate_epoch" 
Write-host "Posting with $postParams"
Invoke-RestMethod -Headers @{Authorization=$authheader} -Uri $influx_write_uri -Method POST -Body  $postParams 


sleep -Seconds 5
}
until ($false)



$ts2 = New-TimeSpan -Hours 2
$current_date = Get-Date
$fromdate = $current_date - $ts2

### insert a series
$dataseries = Get-MHDSensorDataFromDate -Station $Station -fromdate (get-date $fromdate -Format yyyyMMddHHmmss) -ID th0 -Verbose
foreach ($DATA in $dataseries)
    {
    $mydate = $DATA.date
    $mydate_convert=[datetime]::ParseExact($mydate,"yyyyMMddHHmmss",$null) + $ts
    $mydate_epoch = ([DateTimeOffset]$mydate_convert).ToUnixTimeMilliseconds()
    $mydate_convert
    $postParams = "($sensorid)_data temperature=$($DATA.temp/1),dew=$($data.dew/1),humidity=$($DATA.hum/1),sensor=`"$sensorid`",sensortype=`"$sensortype`" $mydate_epoch" 
    Write-Verbose $postParams
    Write-host "Posting with $postParams"
    Invoke-RestMethod -Headers @{Authorization=$authheader} -Uri $influx_write_uri -Method POST -Body  $postParams -Verbose
    }

$dataseries = Get-MHDSensorDataFromDate -Station $Station -fromdate (get-date $fromdate -Format yyyyMMddHHmmss) -ID thb0 -Verbose
foreach ($DATA in $dataseries)
    {
    $mydate = $DATA.date
    $mydate_convert=[datetime]::ParseExact($mydate,"yyyyMMddHHmmss",$null) + $ts
    $mydate_epoch = ([DateTimeOffset]$mydate_convert).ToUnixTimeMilliseconds()
    $mydate_convert
    $postParams = "($sensorid)_data press=$($DATA.press/1),forecast=$($DATA.fc/1),humidity=$($DATA.hum/1),roomtemp=$($DATA.temp/1),sensor=`"$sensorid`",sensortype=`"$sensortype`" $mydate_epoch" 
    Write-host "Posting with $postParams"
    Invoke-RestMethod -Headers @{Authorization=$authheader} -Uri $influx_write_uri -Method POST -Body  $postParams -Verbose
    }