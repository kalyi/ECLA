# ECLA

Easy Command Line Arguments (ECLA) is a small bash "library" to simplify the
handling of command line arguments.

## Install

Install ECLA to $HOME/bin by simply typing
```sh
$ make install
```
If you prefer another location, e.g., /usr/local/bin, type
```sh
$ PREFIX="/usr/local" make install
```

## Uninstall

If you installed ECLA to the default location (i.e., $HOME/bin), 
uninstall it by typing
```sh
$ make uninstall
```
If you specified a different location, e.g., /usr/local/bin, type
```sh
$ PREFIX="/usr/local" make uninstall
```

## Usage

Simply type
```sh
$ ecla -u
```
to print a small usage guide for ECLA.

