Add-Type -TypeDefinition @"
    public enum BranchName
    {
        Dev,
        Test,
        Prod
    }
"@

Add-Type -TypeDefinition @"
    public enum ProjectName
    {
        PTNWebAll,
        Databases,
        Tracker
    }
"@


<#
.SYNOPSIS
Merge code in PerfectVision's projects with a slightly easier syntax than the tf command
.DESCRIPTION
    Streamlined command-line merges for Perfect-Vision tfs changesets

.PARAMETER Source
Source branch, may be one of: Dev,Test,Prod
.PARAMETER Target
Target branch, may be one of: Dev,Test,Prod
.Parameter First
The changeset number of the first changeset in the range
.PARAMETER Last
The changeset number of the last changeset in the range. If ommitted, it will merge only the first changeset
.PARAMETER Force 	
Ignores the merge history and merges the specified changes from the source into the destination, even if some or all these changes have been merged before.
If combined with the Discard flag, will resolve any merge conflicts as keep the destination. 
.PARAMETER Discard
If present, tfs does not perform the merge operation, but updates the merge history to track that the merge occurred. This discards a changeset from being used for a particular merge.
.PARAMETER LocalPath
The local path to where you keep tfs files on your system. Defaults to "I:/tfs". Do not include trailing slashes.
.PARAMETER tfExePath
The full path to tf.exe on your system.
.NOTES
This commandlet makes 
     Merge-Code Dev Test 23426
 Functionally equivalent to 
     tf vc merge /recursive $/PTNWebAll/Dev $/PTNWebAll/Test  /version:C23426~C23426

For more information about TFS command line info see
    https://docs.microsoft.com/en-us/azure/devops/repos/tfvc/use-team-foundation-version-control-commands?view=azure-devops

#>

function Merge-Code{
     [CmdletBinding(PositionalBinding=$true)]
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [BranchName]$Source,
        [Parameter(Position=1,Mandatory=$true)]
        [BranchName]$Target,
        [Parameter(Position=2,Mandatory=$true)]
        [int]$First,
        [Parameter(Position=3,Mandatory=$false)]
        [int]$Last=$First,
        [Parameter(Mandatory=$false)]
        [ProjectName]$Project="PTNWebAll",
		[Parameter(Mandatory=$false)]
        [Switch]$Force,
        [Parameter(Mandatory=$false)]
        [Switch]$Discard,
        [Parameter(Mandatory=$false)]
        [Switch]$Preview,
        [Parameter(Mandatory=$false)]
        [String]$LocalPath= "I:/TFS",
        [Parameter(Mandatory=$false)]
        [String]$tfExePath = "c:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/Common7/IDE/CommonExtensions/Microsoft/TeamFoundation/Team Explorer/tf"
    )
    #"$Source $Target $First $Last $Discard"
    $Local:sourcePath = "$localFilePath/$Project/$Source"
    $Local:targetPath = "$localFilePath/$Project/$Target"
    $Local:changesets = "C"+$First + "~C" + $Last

	
	if ($Force -And $Discard )
	{
		& $tfExePath vc merge /recursive $Local:sourcePath $Local:targetPath /version:$changesets /force /conservative /noPrompt
		& $tfExePath vc resolve $Local:targetPath /recursive /auto:KeepYours /noPrompt
	} 
	elseif ($Force) 
	{
		& $tfExePath vc merge /recursive $Local:sourcePath $Local:targetPath /version:$changesets /force 
	}
    elseif ($Discard)
    {
        & $tfExePath vc merge /recursive $Local:sourcePath $Local:targetPath /version:$changesets /discard
    }
    else {
        #Write-Host "$tfExePath vc merge /recursive $Local:sourcePath $Local:targetPath /version:$changesets"
        & $tfExePath vc merge /recursive $Local:sourcePath $Local:targetPath /version:$changesets
    }
	
    
}
#Source comment here:  tf changeset 31775 /collection:http://server23:8080/tfs/Perfect10 /noPrompt
#checkin command ref https://docs.microsoft.com/en-us/azure/devops/repos/tfvc/checkin-command?view=azure-devops



Export-Module Merge-Code