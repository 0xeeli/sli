# SLi - Simply Lightning
A versatile shell utility that simplifies Bitcoin Lightning Network packages management while offering a suite of handy tools for seamless node operations.

SLi provides easy packages management for Lightning node operators, install, init, configure or update packages trough simple commands. Packages includes SLi and Lit (LND and Alby Hub are coming soon). It let you start/stop/reload daemons via systemd, quick edit of configuration files and provides some useful tools such as getting the HEX of macaroon.

## Examples

```
$ sli install lit
$ sli m2h macaroon
```

## Installation

SLi is well tested and 0.1 will be out soon. For now, you can clone this Github repository or download a ZIP archive and run: `sli init`

## Using SLi

Check out the builtin commands and tools running SLi without arguments: `sli`
