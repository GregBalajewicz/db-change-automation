# needs this module installed. this needs admin rights
#Install-Module -Name SqlServer

# sometimes, you need to run it this way : 
# powershell.exe -executionpolicy bypass -file .\ApplyAllChangeScripts.ps1

param (
    #DB info 
    [string]$connectionstr = ""
)

#
# files MUST be in this format: X.X.sql where X is a number
#
$files = ls -Filter *.sql -Path . | Where-Object { $_.Name -match '^[0-9]+\.{1}[0-9]+\.sql$'  }   | Sort {[double]$_.BaseName}


$runID = New-Guid
Write-Output "START. RunID: $runID" 


$allCompletedWithoutErrors = $true
foreach ($file in $files) {
    Write-Output "processing file $file" 
    $version = [double]$file.BaseName
    $filename = $file.Name 
      
    # Find 
    $Result = Invoke-Sqlcmd -ConnectionString  $connectionstr  `
        "exec schemahistory.ApplySchemaChangeFile_start @runID='$runID', @version=$version, @filename='$filename' " 
    
    if ($Result.AlreadyApplied -eq 0) {
        Write-Output "... $file : applying..."

        $gotError = $false
        try {
            Invoke-Sqlcmd -ConnectionString  $connectionstr  -AbortOnError -Verbose -InputFile $file.Name 
        } catch {
            $gotError = $true
            Write-Output "~~~~~~~~~~ Start - Error from script $filename ~~~~~~~~~"

            Write-Output $_.Exception.Message
            Write-Output "~~~~~~~~~~ End - Error from script $filename ~~~~~~~~~"
            THROW
            EXIT 
        }

        if (-not $gotError) {
            $Result = Invoke-Sqlcmd -ConnectionString  $connectionstr  `
                "exec schemahistory.ApplySchemaChangeFile_end_success @runID='$runID', @version=$version, @filename='$filename' " 
            Write-Output "... $file : DONE"
        }
    } else {
        Write-Output "... $file : skipped, already applied"
    }



    #
    # Supplimentary files for this change script
    #  look for, and apply all .sql files in .\$version folder
    #    
    if (Test-Path ".\$version") {
        Write-Output "... supplementary file folder (\$version\) found. Will process all files there" 
            
        $files_supp = ls -Filter *.sql -Path .\$version

        foreach ($file_supp in $files_supp) {
            $filename_supp = $file_supp.Name 


            Write-Output "...... processing supplementary file .\$version\$filename_supp" 
      
            $Result = Invoke-Sqlcmd -ConnectionString  $connectionstr  `
                "exec schemahistory.ApplySchemaChangeFile_start @runID='$runID', @version=$version, @filename='$filename_supp' " 
    
            if ($Result.AlreadyApplied -eq 0) {
                Write-Output "...... .\$version\$filename_supp : applying..."

                $gotError = $false
                try {
                    Invoke-Sqlcmd -ConnectionString  $connectionstr  -AbortOnError -Verbose -InputFile .\$version\$filename_supp 
                } catch {
                    $gotError = $true
                    Write-Output "~~~~~~~~~~ Start - Error from script $filename_supp ~~~~~~~~~"

                    Write-Output $_.Exception.Message
                    Write-Output "~~~~~~~~~~ End - Error from script $filename_supp ~~~~~~~~~"
                    THROW
                    EXIT 
                }

                if (-not $gotError) {
                    $Result = Invoke-Sqlcmd -ConnectionString  $connectionstr  `
                        "exec schemahistory.ApplySchemaChangeFile_end_success @runID='$runID', @version=$version, @filename='$filename_supp' " 
                    Write-Output "...... .\$version\$filename_supp : DONE"
                }
            } else {
                Write-Output "...... .\$version\$filename_supp : skipped, already applied"
            }
            
        }
    }
    
}

 if ($allCompletedWithoutErrors) {
    Write-Output "FINISHED successfully"
 } else 
 {
     Write-Output "!!!!!!!!!!!!!!! ERRORS OCCURED !!!!!!!!!!!!!!!!!"
 }
