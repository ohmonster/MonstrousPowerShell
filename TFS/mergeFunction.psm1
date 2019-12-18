﻿Add-Type -TypeDefinition @"
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

$collection="http://server23:8080/tfs/Perfect10"
$comment=''
$tfsContent = tf workspaces /collection:'http://server23:8080/tfs/Perfect10' /format:detailed | Select-String -Pattern "$/:" -SimpleMatch | %{$_ -Replace "\$/: ",""}


<#
.SYNOPSIS
The command will
1) Merge code for a specified changeset or changeset range for a specific project

It also copies the comment associated with the first changeset in your merge to the clipboard.

If you do not see your files in the Pending Changes portion of the TFS GUI, close any solutions you have open and check again.


.DESCRIPTION
Streamlined command-line merges for Perfect-Vision tfs changesets

This commandlet makes 
     Merge-Code Dev Test 23426
 Functionally equivalent to 
     tf vc merge /recursive $/PTNWebAll/Dev $/PTNWebAll/Test  /version:C23426~C23426

.PARAMETER Source
Source branch, may be one of: Dev,Test,Prod

.PARAMETER Target
Target branch, may be one of: Dev,Test,Prod

.Parameter First
The changeset number of the first changeset in the range

.PARAMETER Last
The changeset number of the last changeset in the range. If ommitted, it will merge only the first changeset

.PARAMETER ProjectName
One of PTNWebAll, Databases, Tracker. Default is PTNWebAll.

.PARAMETER Force 	
Ignores the merge history and merges the specified changes from the source into the destination, even if some or all these changes have been merged before.

If combined with the Discard flag, will resolve any merge conflicts to retain the code in the target branch. 

.PARAMETER Discard
If present, tfs does not perform the merge operation, but updates the merge history to track that the merge occurred. This discards a changeset from being used for a particular merge.

.PARAMETER LocalPath
The local path to where you keep tfs files on your system. It attempts to find a workspace path mapped to your system. If not you'll have to specify.

.PARAMETER tfExePath
The full path to tf.exe on your system.

.LINK
    https://docs.microsoft.com/en-us/azure/devops/repos/tfvc/use-team-foundation-version-control-commands?view=azure-devops
.LINK
    https://github.com/ohmonster/MonstrousPowerShell/tree/master/TFS

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
        [String]$LocalPath= "$tfsContent",
        [Parameter(Mandatory=$false)]
        [String]$tfExePath = "c:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/Common7/IDE/CommonExtensions/Microsoft/TeamFoundation/Team Explorer/tf"
    )
    #"$Source $Target $First $Last $Discard"
    $private:sourcePath = "$LocalPath/$Project/$Source"
    $private:targetPath = "$LocalPath/$Project/$Target"
    $private:changesets = "C"+$First + "~C" + $Last
	
	
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

    $private:info = & $tfExePath changeset $First /collection:$collection /noPrompt | Select-String -Pattern "Comment:"  -Context 1
    $comment=$info.Context.PostContext
    Set-Clipboard $comment
	
    
}

Export-ModuleMember -Function Merge-Code