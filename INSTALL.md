# Installation

## Debian package

Analizo is readily available as a Debian package. This package migth work with
Ubuntu as well. Installing the Debian package has the follwing advantages:

  1. you do not have to compile anything
  2. all dependencies are installed automatically for you
  3. new versions will be automatically available for upgrading the version
     on your system.

You will find the instructions to install Analizo Debian package below. All of
the steps must be performed as root user:

1) Create a file /etc/apt/sources.list.d/analizo.list file with the following
contents:

```repository
deb http://analizo.org/download/ ./
deb-src http://analizo.org/download/ ./
```

2) Add the repository signing key to your list of trusted keys:

```repository
$ wget -O - http://analizo.org/download/signing-key.asc | apt-key add -
```

3) Update your package lists:

```
$ apt-get update
```

4) Install analizo:

```
$ apt-get install analizo
```

## From sources

Download the analizo tarball linked from <span class='repository'><a href="http://analizo.org/download.html">the download page</a></span>,
extract it and run the following commands inside the analizo-x.y.z directory:

```
$ perl Makefile.PL
$ make
$ sudo make install
```

See the HACKING file for instructions on how to install Analizo dependencies.
You neeed to install the dependencies before installing Analizo.
