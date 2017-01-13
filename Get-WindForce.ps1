function Get-WindForce {

<#
.Synopsis
   Returns wind force speed description for the specified language code.
.DESCRIPTION
   Returns wind force speed description for the specified language code. If no language code specified
   the current cached culture context is used.
.EXAMPLE
   Get-WindForce -Speed 28
.EXAMPLE
   Get-WindForce -Speed 28 -Language it-IT
.EXAMPLE
    3,11 | Get-WindForce -Language fr-FR -Verbose
.PARAMETER Speed
    The speed of the wind in meters per second.
.PARAMETER Language
    The language to use for the description.
.OUTPUTS
   A string description in the specified language.
.NOTES
   happysysadm.com
   @sysadm2010
   http://www.happysysadm.com/2017/01/a-powershell-function-to-translate-wind.html
.NOTES
   System.Globalization namespace and Hashtable revision
   iayfconsulting.com
   @CarnegieJ
#>
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        # Speed of wind in m/s
        [Parameter(Mandatory=$true, ValueFromPipeline=$true,
          HelpMessage='Please specify the Speed (m/s)')]
        [double]$Speed,

        # Language code to use for the output of the wind force
        [Parameter(Mandatory=$false, ValueFromPipeline=$true,
          HelpMessage='Please specify the Language')]
        [ValidateSet('en-US', 'it-IT', 'fr-FR', 'de-DE')]
        [Alias('LanguageCode')]
        [string]$Language = $([System.Globalization.CultureInfo]::GetCultureInfo($Language)).Name
    )
    Begin {
        <#
        # Create Globalization String table (via PS Hashtable) of culture specifiC strings.
        1033    en-US    English (United States)
        1040    it-IT    Italian (Italy)
        1036    fr-FR    French (France)
        1031    de-DE    German (Germany)

        StringID  Return values respectively
        --------  -------------------------------------------------------------------------
        0         'Calm', 'Calma','Calme','WindStille'
        1         'Light air', 'Bava di vento','Très légère brise','Leichter Zug'
        2         'Light breeze', 'Brezza leggera','Légère brise','Leichte Brise'
        3         'Gentle breeze', 'Brezza testa','Petite brise','Schwache Brise'
        4         'Moderate breeze', 'Vento moderato','Jolie brise','Mäßige Brise'
        5         'Fresh breeze', 'Vento teso','Bonne brise','Frische Brise'
        6         'Strong breeze', 'Vento fresco','Vent frais','Starker Wind'
        7         'Near gale', 'Vento forte','Grand frais','Steifer Wind'
        8         'Gale', 'Burrasca','Coup de vent','Stürmischer Wind'
        9         'Strong gale', 'Burrasca forte','Fort coup de vent','Sturm'
        10        'Storm', 'Tempesta','Tempête','Schwerer Sturm'
        11        'Violent storm', 'Fortunale','Violent tempête','Orkanartiger Sturm'
        12        'Hurricane', 'Uragano','Ouragan','Orkan'
        13        'NA', 'NA','NA','NA'
        #>
        $Strings = 
            $(@{1033 = 'Calm' # String Item 0
                1040 = 'Calma'; 1036 = 'Calme'; 1031 = 'WindStille'}),
            $(@{1033 = 'Light air' # String Item 1
                1040 = 'Bava di vento'; 1036 = 'Très légère brise'; 1031 = 'Leichter Zug'}),
            $(@{1033 = 'Light breeze' # String Item 2
                1040 = 'Brezza leggera'; 1036 = 'Légère brise'; 1031 = 'Leichte Brise'}),
            $(@{1033 = 'Gentle breeze' # String Item 3
                1040 = 'Brezza testa'; 1036 = 'Petite brise'; 1031 = 'Schwache Brise'}),
            $(@{1033 = 'Moderate breeze' # String Item 4
                1040 = 'Vento moderato'; 1036 = 'Jolie brise'; 1031 = 'Mäßige Brise'}),
            $(@{1033 = 'Fresh breeze' # String Item 5
                1040 = 'Vento teso'; 1036 = 'Bonne brise'; 1031 = 'Frische Brise'}),
            $(@{1033 = 'Strong breeze' # String Item 6
                1040 = 'Vento fresco'; 1036 = 'Vent frais'; 1031 = 'Starker Wind'}),
            $(@{1033 = 'Near gale' # String Item 7
                1040 = 'Vento forte'; 1036 = 'Grand frais'; 1031 = 'Steifer Wind'}),
            $(@{1033 = 'Gale' # String Item 8
                1040 = 'Burrasca'; 1036 = 'Coup de vent'; 1031 = 'Stürmischer Wind'}),
            $(@{1033 = 'Strong gale' # String Item 9
                1040 = 'Burrasca forte'; 1036 = 'Fort coup de vent'; 1031 = 'Sturm'}),
            $(@{1033 = 'Storm' # String Item 10
                1040 = 'Tempesta'; 1036 = 'Tempête'; 1031 = 'Schwerer Sturm'}),
            $(@{1033 = 'Violent storm' # String Item 11
                1040 = 'Fortunale'; 1036 = 'Violent tempête'; 1031 = 'Orkanartiger Sturm'}),
            $(@{1033 = 'Hurricane' # String Item 12
                1040 = 'Uragano'; 1036 = 'Ouragan'; 1031 = 'Orkan'}),
            $(@{1033 = 'NA' # String Item 13
                1040 = 'NA'; 1036 = 'NA'; 1031 = 'NA'})
        $LCID = $([System.Globalization.CultureInfo]::GetCultureInfo($Language)).LCID
    }
    
    Process {
    
        Write-Verbose "working on $speed m/s"
        $windforce = switch ($speed) {
            {$_ -lt 0.3} { $Strings[0].Item($LCID) }
            {($_ -ge 0.3) -and ($_ -le 1.5)} { $Strings[1].Item($LCID) }
            {($_ -ge 1.6) -and ($_ -le 3.3)} { $Strings[2].Item($LCID) }
            {($_ -ge 3.4) -and ($_ -le 5.5)} { $Strings[3].Item($LCID) }
            {($_ -ge 5.6) -and ($_ -le 7.9)} { $Strings[4].Item($LCID) }
            {($_ -ge 8) -and ($_ -le 10.7)} { $Strings[5].Item($LCID) }
            {($_ -ge 10.8) -and ($_ -le 13.8)} { $Strings[6].Item($LCID) }
            {($_ -ge 13.9) -and ($_ -le 17.1)} { $Strings[7].Item($LCID) } 
            {($_ -ge 17.2) -and ($_ -le 20.7)} { $Strings[8].Item($LCID) }
            {($_ -ge 20.8) -and ($_ -le 24.4)} { $Strings[9].Item($LCID) }
            {($_ -ge 24.5) -and ($_ -le 28.4)} { $Strings[10].Item($LCID) }
            {($_ -ge 28.5) -and ($_ -le 32.6)} { $Strings[11].Item($LCID) }
            {$_ -ge 32.7} { $Strings[12].Item($LCID) }
            default { $Strings[13].Item($LCID) }
            }

        Write-Verbose "Printing in choosen language: $([System.Globalization.CultureInfo]::GetCultureInfo($Language).DisplayName)"
        $windforce
    }
}

