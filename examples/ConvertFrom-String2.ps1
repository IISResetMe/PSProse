using namespace Microsoft.ProgramSynthesis.Extraction.Text

function ConvertFrom-String2
{
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string[]]$InputObject,

        [Parameter(Mandatory)]
        [string]$TemplateString
    )

    begin {
        $Lines = [System.Collections.Generic.List[string]]::new()

        # Parse the template string
        $Template = Get-ParsedTemplate -TemplateString $TemplateString
    }

    process{
        # we'll process the input line by line, later
        foreach($s in $InputObject){
            $s -split '\r?\n' |ForEach-Object {
                $Lines.Add($_)
            }
        }
    }

    end{
        # Apply template to the first line of the input
        $Region = [RegionSession]::CreateStringRegion($Lines[0])
        $Sample = $Region.Slice($SampleStrings.Sample.Start,$SampleStrings.Sample.End)

        # Create a new session, add the sample we just generated as a constraint
        $Session = [RegionSession]::new()
        $Session.Constraints.Add([Microsoft.ProgramSynthesis.Extraction.Text.Constraints.RegionExample]::new($Region,$Sample))

        # Generate the actual program
        $Program = $Session.Learn()

        # Run each line through our new program
        foreach($Line in $Lines |?{$_}){
            $InputString = [RegionSession]::CreateStringRegion($Line)
            $Result = $Program.Run($InputString)

            # Create and output resulting objects
            $props = [ordered]@{}
            $props.Add($SampleStrings.Name,$Result)
            [pscustomobject]$props
        }

        Write-Verbose "Here comes the program - "
        Write-Verbose $($Program.Serialize([Microsoft.ProgramSynthesis.AST.ASTSerializationFormat]::XML))
    }
}
