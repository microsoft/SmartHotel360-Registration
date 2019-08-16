Param(
    [parameter(Mandatory=$false,ValueFromPipeline=$true)][string]$content="",    
    [parameter(Mandatory=$false)][string]$inputFile="",    
    [parameter(Mandatory=$false)][string]$outputFile="",
    [parameter(Mandatory=$true)][hashtable]$tokens
)


if ([string]::IsNullOrEmpty($content)) {
    if ([string]::IsNullOrEmpty($inputFile)) {
        Write-Host "Must enter -inputFile if content is not piped" -ForegroundColor Red
        exit 1
    }
    $content = Get-Content -Raw $inputFile
}

$tokens.Keys | % ($_) {
  $content = $content -replace "{{$_}}",  $tokens[$_]
}

if ([string]::IsNullOrEmpty($outputFile)) {
    Write-Output $content
}
else {
    Set-Content -Path $outputFile -Value $content
}


# Usage:
# 1. Replace tokens {{a}} & {{b}} with "Gag" and "Ufo" in input.txt and save output.txt
# .\token-replace.ps1 -tokens @{a="Ufo";b="Gag"} -inputFile .\input.txt -outputFile output.txt
#
# 2. Same as before but using pipe
#.\token-replace.ps1 -tokens @{a="Ufo"} -inputFile .\input.txt | .\token-replace.ps1 -tokens @{b="Gag"} -outputFile .\output.txt
#
# 3. Replace same tokens but from pipe input instead of a file
# "{{a}} - {{b}}" | .\token-replace.ps1 -tokens @{a="Ufo"} | .\token-replace.ps1 -tokens @{b="Gag"} -outputFile .\output.txt
#
# 4. Replace same tokens, but write output to stdout to allow further piping
# .\token-replace.ps1 -tokens @{a="Ufo"} -inputFile .\input.txt | .\token-replace.ps1 -tokens @{b="Gag"} | % {$_.ToUpper()}
#
# 5. Same as 4 but using pipe for input instead a file
# "{{a}} - {{b}}" | .\token-replace.ps1 -tokens @{a="Ufo"} | .\token-replace.ps1 -tokens @{b="Gag"} | % {$_.ToUpper()}