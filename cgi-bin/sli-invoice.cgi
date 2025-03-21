#!/bin/bash
#
# sli-invoice.cgi: CGI shell script to display a Lightning invoice.
#
# This script generates a static HTML page to show a Lightning invoice.
# It avoids POST actions for security (e.g., no sli-invoice.cgi?action=xyz).
# It checks for an existing QR code and text file, displaying them if present.

echo "Content-Type: text/html"
echo ""

# Paths to static files.
# For security, no images or text files are stored in cgi-bin; only executable
# scripts reside there. QR_URL is used in <img src="">, while QR_PATH and TXT_PATH
# (relative or full paths) locate the .png and .txt files for existence checks
# and to display the invoice text via 'cat'.

QR_URL="http://0xeeli.local/pay/invoice.png"
QR_PATH="../vhosts/0xeeli.local/www/pay/invoice.png"
TXT_PATH="../vhosts/0xeeli.local/www/pay/invoice.txt"

# CSS Style function
css_style() {
	cat << EOT
	<style>
		body {
			font-family: Arial, sans-serif;
			text-align: center;
			padding: 20px;
			color: #e0e0e0; /* Light text for dark background */
			background-color: #1a1a1a; /* Dark background */
		}
		img { max-width: 300px; }
		img, pre { border-radius: 8px; }
		pre {
			background: #333;
			padding: 10px;
			display: inline-block;
			white-space: pre-wrap;
			word-wrap: break-word;
			font-size: 15px;
			max-width: 50%;
		}
		a.copy-btn {
			text-decoration: none;
			padding: 5px 10px;
			background-color: #d1d5db; /* Light grey */
			color: #1f2937; /* Dark grey text */
			border-radius: 3px;
			cursor: copy;
		}
		a.copy-btn:hover { background-color: #9ca3af; } /* Darker grey on hover */
	</style>
EOT
}

# Verify file existence.
# If the QR code or text file is missing, display a minimal page. Lightning
# invoices are single-use; SLi prompts users to remove these files after payment.

if [ ! -f "$QR_PATH" ] || [ ! -f "$TXT_PATH" ]; then
	cat << EOT
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>SLi Invoice</title>
	
	$(css_style)
	
</head>
<body>
	<h1>⚡️ SLi Lightning Invoice ⚡️</h1>
	<p>No invoice generated yet. Run <code>'sli wallet qr-invoice'</code>
	to create one.</p>
</body>
</html>
EOT
	exit 0
fi

# Extract the invoice amount for display.
# Grep searches for "Amount" in the text file to show on the payment page.

amount=$(grep "Amount" "$TXT_PATH")

# Generate a styled HTML page.
# Displays the QR code, invoice details, and a "Copy" button with modern styling.

cat << EOT
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>SLi Lightning Invoice</title>
	
	$(css_style)
	
</head>
<body>
	<h1>⚡️ SLi Lightning Invoice ⚡️</h1>
	<p>Scan the QR code or copy the invoice details to pay</p>
	<img src="$QR_URL" alt="Lightning Invoice QR Code">
	<p>$amount</p>
<pre id="invoice-details">
EOT

# Parse invoice text.
# Removes "Invoice:" and "Amount : [number] sat" from the SLi output for cleaner display.

cat "$TXT_PATH" | sed -E -e 's/Invoice://' -e 's/Amount : [0-9]+ sat//'

cat << EOT
</pre>
	<div><a class="copy-btn" id="copy-btn" onclick="copyToClipboard()">Copy</a></div>

	<script>
    function copyToClipboard() {
        const pre = document.getElementById('invoice-details');
        const btn = document.getElementById('copy-btn');
        navigator.clipboard.writeText(pre.textContent)
            .then(() => {
                btn.textContent = 'Copied!'; // Change button text
                setTimeout(() => {
                    btn.textContent = 'Copy'; // Revert after 4 seconds
                }, 2500);
            })
            .catch(err => {
                console.error('Failed to copy: ', err);
            });
    }
    // Note: navigator.clipboard requires HTTPS in production, but works on localhost for testing.
    </script>
    
</body>
</html>
EOT

# Now that the page was displayed, remove invoice files
# NOTE: to work the directory and files must belong to the web server 
# user (www-data:www-data on Debian)
rm -f ${TXT_PATH} ${QR_PATH}
exit 0
