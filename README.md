# SLi - Simply Lightning
SLi (Simply Lightning) is a versatile shell utility designed to simplify Bitcoin Lightning Network node operations. It includes a built-in wallet, encrypted backup functionality, and a package manager for seamless management of Lightning-related tools

![SLi Screenshot installing lit](https://0xee.li/media/sli-2025-03-10.png)

SLi provides easy package management for Lightning node operators, install, init, configure or update packages trough simple commands. Package includes SLi and Lit, Loop, Pool, Lnconnect (LND and Alby Hub are coming soon). It let you start/stop/reload daemons via systemd, quick edit of configuration files and provides some useful tools such as getting the HEX of macaroon. Many interactive command as well so you dont need to write long cmline commands with arguments, basic but useful wallet to send BTC, create invoice, make a payment, check wallet health, and more.

## Examples

```
$ sli install lit
$ sli m2h macaroon
$ sli wallet send
```

## Installation

SLi is well tested and 0.1 will be out soon. For now, you can clone this Github repository or download a ZIP archive and run: `./sli init`. You will find setup workflow and user manual on Sli webpage.

## Using SLi

Read the [User Manual](https://0xee.li/sli/man.html) on Sli webpage or check out the builtin commands and tools running SLi without arguments: `sli`
