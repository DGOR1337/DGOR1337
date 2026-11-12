$ErrorActionPreference = 'Stop'
$profileRoot = Split-Path -Parent $PSScriptRoot
$readme = Get-Content -LiteralPath (Join-Path $profileRoot 'README.md') -Raw -Encoding utf8

foreach ($required in @('# Hi, I''m DGOR1337', 'Unreal Engine 逆向工程', '、**Harness 工程**与', '| 🤖 **Harness 工程** | 学习如何为 AI Agent 设计工具接口、管理上下文，并通过评估验证其行为。 |', '后量子密码', '格密码', 'Post-Quantum Cryptography')) {
    if (-not $readme.Contains($required)) { throw "Missing learning profile content: $required" }
}
if ($readme -match '(?i)(?<![\w-])Quantum Cryptography\b|(?<!后)量子密码|LangChain|已掌握|精通|专家|TODO|你的用户名|项目链接') {
    throw 'Profile contains an incorrect study direction, unsupported proficiency claim, or placeholder.'
}
foreach ($privateContent in @('Learning/blob', 'Learning/tree', 'The Game Hacking', 'E:\')) {
    if ($readme.Contains($privateContent)) { throw "Profile exposes a private workspace reference: $privateContent" }
}

# Every image must ship with the README; external render services are unnecessary.
$imageMatches = [regex]::Matches($readme, '<img\b[^>]*src="(?<path>[^"]+)"[^>]*>')
if ($imageMatches.Count -ne 1) { throw 'Expected one local profile banner.' }
foreach ($imageMatch in $imageMatches) {
    $imagePath = $imageMatch.Groups['path'].Value
    if ($imagePath -match '^(?:/|\w+:)|\.\.') { throw "Banner must use a repository-relative path: $imagePath" }
    $resolvedImage = Join-Path $profileRoot $imagePath
    if (-not (Test-Path -LiteralPath $resolvedImage -PathType Leaf)) { throw "Missing image: $imagePath" }
    [xml]$svg = Get-Content -LiteralPath $resolvedImage -Raw -Encoding utf8
    if ($svg.DocumentElement.LocalName -ne 'svg' -or $svg.DocumentElement.GetAttribute('viewBox') -ne '0 0 1200 300') {
        throw 'Banner must be valid SVG with the intended responsive aspect ratio.'
    }
    if ($svg.SelectNodes('//*[local-name()="script" or local-name()="foreignObject" or local-name()="image"]').Count -gt 0) {
        throw 'Banner must remain self-contained SVG artwork.'
    }
    $bannerText = $svg.DocumentElement.InnerText
    if ($bannerText -notmatch 'DGOR1337' -or $bannerText -notmatch 'Post-Quantum Cryptography') { throw 'Banner identity or study direction is incorrect.' }
}

# Public links must refer to the two confirmed public repositories.
$links = [regex]::Matches($readme, '\[[^\]]+\]\((?<url>[^)]+)\)')
$expectedLinks = @('https://github.com/DGOR1337/CE_MCP', 'https://github.com/DGOR1337/Fusion-IDA94')
if ($links.Count -ne $expectedLinks.Count) { throw 'Unexpected number of public repository links.' }
foreach ($link in $links) {
    if ($expectedLinks -notcontains $link.Groups['url'].Value) { throw "Unverified public link: $($link.Value)" }
}
Write-Output 'Profile learning directions, public links, and local SVG banner verified.'
