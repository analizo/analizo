# Profiling analizo

Run the desired command under the profiler:

```console
analizo=/path/to/analizo
perl -d:DProf -I$analizo/lib $analizo/lib/Analizo/Command/COMMAND
```

Process the profiler output (this has to be run from the same directory where
you run the profiler):

```console
dprofpp
```

## Using Devel::NYTProf

Run the desired command under the profiler:

```console
COMMAND=metrics SOURCE=t/samples/hello_world/cpp/ perl profile.pl
```

Process the profiler output (this has to be run from the same directory where
you run the profiler) in html format:

```console
nytprofhtml --open
```

You can run profiler running analizo over any source-code you want
by passing via command line argument or $SOURCE variable, eg:

```console
SOURCE=t/samples/hello_world/cpp/ perl profile.pl
```

```console
perl profile.pl t/samples/hello_world/cpp/
```

* [Profiling Perl](http://www.perl.com/pub/2004/06/25/profiling.html), by Simon
  Cozens
* [Devel::NYTProf - Profiling Perl code](https://www.perl.org/about/whitepapers/perl-profiling.html),
  by Leo Lapworth
