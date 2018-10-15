function Get-ParsedTemplate
{
    param(
        [Parameter(Mandatory)]
        [string]$TemplateString
    )

    $Line = [System.Text.StringBuilder]::new()
    $Sampling = $false
    $Named = $false
    $Name = ''

    foreach($c in $TemplateString.ToCharArray()){
        if($c -eq '{'){
            $Start = $Line.Length
            $Sampling = $true
        }
        elseif($c -eq '}'){
            $End = $Line.Length
            $Sampling = $false
        }
        else{
            if($Sampling -and -not $Named){
                if($c -eq ':'){
                    $Named = $true
                    continue
                }
                $Name += $c
            }
            else{
                $Line = $Line.Append($c)
            }
        }
    }

    [pscustomobject]@{
        Line = $Line.ToString()
        Name = $Name
        Sample = [pscustomobject]@{
            Start = $Start
            End = $End
        }
    }
}
