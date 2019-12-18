@{
	RootModule='mergeFunction.psm1'
	ModuleVersion = '0.8'
	GUID = '068efa03-fca4-4d59-9c6d-61e05a733701'
	Author = 'Nita Daniel'
	Copyright = '2019 Nita Daniel'
	Description = 'Shorthand functions for performing tf  merges at work'
	PowerShellVersion='5.0'
	FunctionsToExport=@(
		'Merge-Code'
	)
	# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{

		PSData = @{

			# Tags applied to this module. These help with module discovery in online galleries.
			# Tags = @()

			# A URL to the license for this module.
			# LicenseUri = ''

			# A URL to the main website for this project.
			# ProjectUri ='https://github.com/ohmonster/MonstrousPowerShell/tree/master/TFS'

			# ReleaseNotes of this module
			# ReleaseNotes = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable
}