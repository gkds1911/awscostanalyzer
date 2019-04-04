Invoke-WebRequest -Uri http://a0.awsstatic.com/pricing/1/ebs/pricing-ebs.js -OutFile ".\prices\ebs\pricing-ebs.js"

$file = Get-Content ".\prices\ebs\pricing-ebs.js"

foreach($line in $file)
{
    if($line.ReadCount -eq 7)
    {
        $Content = $line
    }    
}
$Content | Out-file ".\prices\ebs\pricing-ebs.json" -Force