# SLi - Simply Lightning
SLi (Simply Lightning) is a versatile shell utility designed to simplify Bitcoin Lightning Network node operations. It includes a built-in wallet, encrypted backup functionality, node management, and a package management system.

![sli-install-16032025](https://github.com/user-attachments/assets/e8f2854f-0e3d-4a06-b931-f563ecee7048)

SLi provides easy package management for Lightning node operators, allowing you to install, initialize, configure, or update packages through simple commands. Packages include SLi and tools like Lit, Loop, Pool, and Lnconnect. Alby Hub and LND are on the way and will be inclued in the next release.

SLi comes with many interactive commands so you don't need to write long commands with arguments. It includes a basic but useful wallet to send BTC, create invoices, make payments, check node health, and more.

## Key Features

- **Node Management**: Initialize, start, stop, and monitor Lightning nodes (e.g., litd).
- **Wallet Operations**: Create addresses, send BTC, generate invoices, and make payments via Lightning (sli wa).
- **Channel Control**: Open, close, and list channels (sli chan).
- **Fee Management**: Check, set, and adjust routing fees interactively (sli fees).
- **Package Manager**: Install and upgrade Lightning-related tools (e.g., lit, loop).
- **Backup & Restore**: Securely back up and restore your node with GPG encryption.
- **Handy Built-in Tools**: Security checks, sign messages, connect to peers, get macaroon HEX.
- **Generate QR Invoice**: Generate QR codes for invoices that can be used in CGI, PHP, or static HTML to receive sats from a web page.

## Examples

```sh
$ sli install lit
$ sli m2h macaroon
$ sli wallet send
```

## Installation

You can clone this GitHub repository or download the latest release archive, extract and run: `./sli init`. You will find the setup workflow and user manual on the SLi website.

## Documentation

- [SLi User Manual](https://0xee.li/sli/man.html) on SLi website
- [Quick Guides](https://0xee.li/sli/#quickguides) on SLi website
- Check out the built-in commands and tools by running SLi without arguments: `sli`

⚡️ Built with love by 0xeeLi under the MIT License.

