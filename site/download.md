# Download

Analizo current version is <strong>{$version}</strong>. You have more than one
choice of download, see below.

## Source code

Analizo source code can be obtained by downloading
[analizo_{$version}.tar.gz](download/analizo_{$version}.tar.gz)
To perform the installation, check the [installation
instructions](installation.html).

## Debian package

Analizo is readily available as a Debian package. This package migth work with
Ubuntu as well. Installing the Debian package has the following advantages:

* you do not have to compile anything
* all dependencies are installed automatically
* new versions will be made available automatically and you can upgrade using
  standard Debian tools

You will find the instructions to install Analizo Debian package below. All of
the steps must be performed as =root= user.

1) Create a file `/etc/apt/sources.list.d/analizo.list` file with the following
contents:

```repository
deb http://analizo.org/download/ ./
deb-src http://analizo.org/download/ ./
```

2) Add the repository signing key to your list of trusted keys:

```repository
# wget -O - http://analizo.org/download/signing-key.asc | apt-key add -
```

3) Update your package lists:

```
# apt-get update
```

4) Install analizo:

```
# apt-get install analizo
```
