# SLi - Simply Lightning
SLi (Simply Lightning) is a versatile shell utility designed to simplify Bitcoin Lightning Network node operations. It includes a built-in wallet, encrypted backup functionality, and a package manager for seamless management of Lightning-related tools

![sli-install-16032025](https://github.com/user-attachments/assets/e8f2854f-0e3d-4a06-b931-f563ecee7048)

SLi provides easy package management for Lightning node operators, install, init, configure or update packages trough simple commands. Package includes SLi and Lit, Loop, Pool, Lnconnect (LND and Alby Hub are coming soon). It create service file unit and manage daemons via systemd, provides some useful tools such as getting the HEX of macaroon or generating QR invoice. Many interactive command as well so you dont need to write long cmline commands with arguments, basic but useful wallet to send BTC, create invoice, make a payment, check wallet health, and more. You even dont need to remember all command, SLi comes with nifty Bash completion.

## Key Features

- Node Management: Initialize, start, stop, and monitor Lightning nodes (e.g., litd).
- Wallet Operations: Create addresses, send BTC, generate invoices, and pay via Lightning (sli wa).
- Channel Control: Open, close, and list channels (sli chan).
- Fee Management: Check, set, and adjust routing fees interactively (sli fees).
- Package Manager: Install and upgrade Lightning-related tools (e.g., lit, loop).
- Backup & Restore: Securely back up and restore your node with GPG encryption.
- Handy built in tools: Security Checks, sign message, connect to peer, get macaroon HEX
- Generate QR invoice that can be used in CGI, PHP or static html to get sats from a web page

## Examples

```
$ sli install lit
$ sli m2h macaroon
$ sli wallet send
```

## Installation

You can clone this Github repository or download the latest release archive, extract and run: `./sli init`. You will find setup workflow and user manual on Sli webpage.

## Documentation

[SLi User Manual](https://0xee.li/sli/man.html) - [Quick Guides](https://0xee.li/sli/#quickguides) on SLi website or check out the builtin commands and tools running SLi without arguments: `sli`

⚡️ Built with love by 0xeeLi under the MIT License.

