# Load the required .NET Assemblies for UI development
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the main window form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Network & Group Policy Utility"
$form.Size = New-Object System.Drawing.Size(910, 610)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# Helper function to generate standardized UI buttons
function Create-Button($text, $x, $y, $width = 160) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Location = New-Object System.Drawing.Point($x, $y)
    $btn.Size = New-Object System.Drawing.Size($width, 35)
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    $btn.BackColor = [System.Drawing.Color]::LightGray
    return $btn
}

# --- Action Buttons Layout (Row 1) ---
$btnIPConfig = Create-Button "IPConfig /All" 20 20
$btnIPConfig.BackColor = [System.Drawing.Color]::LightBlue

$btnGPUpdate = Create-Button "GPUpdate /Force" 195 20
$btnGPUpdate.BackColor = [System.Drawing.Color]::LightSalmon

$btnDHCPRenew = Create-Button "DHCP Renew" 370 20
$btnDHCPRenew.BackColor = [System.Drawing.Color]::LightGreen

$btnNetstat = Create-Button "Netstat Active" 545 20
$btnNetstat.BackColor = [System.Drawing.Color]::Lavender

$btnARP = Create-Button "ARP Table" 720 20
$btnARP.BackColor = [System.Drawing.Color]::LightYellow


# --- Interactive Target Utilities Layout (Row 2) ---
# Label for the input box
$lblPing = New-Object System.Windows.Forms.Label
$lblPing.Text = "Target Address:"
$lblPing.Location = New-Object System.Drawing.Point(20, 78)
$lblPing.Size = New-Object System.Drawing.Size(110, 25)
$lblPing.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)

# Textbox input (Resized slightly to balance the 3 utility buttons)
$txtPingAddress = New-Object System.Windows.Forms.TextBox
$txtPingAddress.Location = New-Object System.Drawing.Point(135, 75)
$txtPingAddress.Size = New-Object System.Drawing.Size(380, 25)
$txtPingAddress.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$txtPingAddress.Text = "google.com" # Default placeholder value changed to a domain for cleaner lookup testing

# The 3 Shared Target Buttons
$btnPing = Create-Button "Ping" 530 72 110
$btnPing.BackColor = [System.Drawing.Color]::LightSteelBlue

$btnNSLookup = Create-Button "NSLookup" 650 72 110
$btnNSLookup.BackColor = [System.Drawing.Color]::Thistle

$btnTracert = Create-Button "Tracert" 770 72 110
$btnTracert.BackColor = [System.Drawing.Color]::LightCyan


# --- Main Output Box Layout ---
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(20, 130)
$outputBox.Size = New-Object System.Drawing.Size(855, 410)
$outputBox.MultiLine = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.Font = New-Object System.Drawing.Font("Consolas", 9.5)
$outputBox.ReadOnly = $true
$outputBox.BackColor = [System.Drawing.Color]::Black
$outputBox.ForeColor = [System.Drawing.Color]::White
$outputBox.Text = "Click any action button above to run its command..."


# --- Click Event Logic ---

# 1. IPConfig Click Event
$btnIPConfig.Add_Click({
    $outputBox.Text = "Executing 'ipconfig /all'... please wait..."
    $form.Refresh()
    try { $outputBox.Text = ipconfig /all | Out-String } catch { $outputBox.Text = "Error running ipconfig: $_" }
})

# 2. GPUpdate Click Event
$btnGPUpdate.Add_Click({
    $outputBox.Text = "Updating group policies natively ('gpupdate /force'). This may take a few seconds..."
    $form.Refresh()
    try { $outputBox.Text = gpupdate /force | Out-String } catch { $outputBox.Text = "Error running gpupdate: $_" }
})

# 3. DHCP Renew Click Event
$btnDHCPRenew.Add_Click({
    $outputBox.Text = "Requesting new IP assignment ('ipconfig /renew'). Please wait..."
    $form.Refresh()
    try { $outputBox.Text = ipconfig /renew | Out-String } catch { $outputBox.Text = "Error renewing DHCP lease: $_" }
})

# 4. Netstat Click Event
$btnNetstat.Add_Click({
    $outputBox.Text = "Fetching active connections and listening ports ('netstat -an'). Please wait..."
    $form.Refresh()
    try { $outputBox.Text = netstat -an | Out-String } catch { $outputBox.Text = "Error running netstat: $_" }
})

# 5. ARP Click Event
$btnARP.Add_Click({
    $outputBox.Text = "Fetching ARP translation tables ('arp -a'). Please wait..."
    $form.Refresh()
    try { $outputBox.Text = arp -a | Out-String } catch { $outputBox.Text = "Error running arp: $_" }
})

# Helper function to validate target input
function Get-ValidTarget {
    $target = $txtPingAddress.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($target)) {
        $outputBox.Text = "Error: Please enter a valid IP address or domain name in the Target box."
        return $null
    }
    return $target
}

# 6. Ping Utility Click Event
$btnPing.Add_Click({
    $target = Get-ValidTarget
    if ($null -eq $target) { return }
    
    $outputBox.Text = "Pinging target '$target'... please wait..."
    $form.Refresh()
    try { $outputBox.Text = ping $target | Out-String } catch { $outputBox.Text = "Error executing ping: $_" }
})

# 7. NSLookup Click Event
$btnNSLookup.Add_Click({
    $target = Get-ValidTarget
    if ($null -eq $target) { return }
    
    $outputBox.Text = "Performing DNS lookup for '$target'... please wait..."
    $form.Refresh()
    try { $outputBox.Text = nslookup $target | Out-String } catch { $outputBox.Text = "Error executing nslookup: $_" }
})

# 8. Traceroute Click Event
$btnTracert.Add_Click({
    $target = Get-ValidTarget
    if ($null -eq $target) { return }
    
    $outputBox.Text = "Tracing route to '$target'. Note: Traceroute can take up to a minute to finish mapping hops. Please wait..."
    $form.Refresh()
    try { $outputBox.Text = tracert $target | Out-String } catch { $outputBox.Text = "Error executing tracert: $_" }
})


# Add controls to the Form
$form.Controls.Add($btnIPConfig)
$form.Controls.Add($btnGPUpdate)
$form.Controls.Add($btnDHCPRenew)
$form.Controls.Add($btnNetstat)
$form.Controls.Add($btnARP)
$form.Controls.Add($lblPing)
$form.Controls.Add($txtPingAddress)
$form.Controls.Add($btnPing)
$form.Controls.Add($btnNSLookup)
$form.Controls.Add($btnTracert)
$form.Controls.Add($outputBox)

# Launch the Application UI
[void]$form.ShowDialog()