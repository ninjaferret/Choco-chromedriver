param(
	[Parameter(Mandatory=$true)]
	[String]
	$apiKey,
	[Parameter(Mandatory=$true)]
	[String]
	$versionNumber
)

$ErrorActionPreference = "Stop"

pushd tools

# Download the release to get its checksum
$url = "https://chromedriver.storage.googleapis.com/$versionNumber/chromedriver_win32.zip"
wget "$url" -OutFile chromedriver_win32.zip
$hash = Get-FileHash chromedriver_win32.zip
$hash = $hash.Hash
Write-Host "Hash is: $hash"

# Replace the checksum and version in the chocolateyinstall.ps1 file
$pwd = pwd
$content = [IO.File]::ReadAllText("$pwd\chocolateyinstall.template.ps1")
$content = $content.Replace("{CHECKSUM}", $hash)
$content = $content.Replace("{VERSION}", $versionNumber)

[IO.File]::WriteAllText("$pwd\chocolateyinstall.ps1", $content)

# Push to chocolatey.org
popd
rm *.nupkg
choco pack chromedriver.nuspec --version $versionNumber
choco push --api-key=$apiKey
popd