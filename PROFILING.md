# Profiling analizo

Run the desired command under the profiler:

```console
analizo=/path/to/analizo
perl -d:DProf -I$analizo/lib $analizo/lib/Analizo/scripts/analizo-COMMAND
```

Process the profiler output (this has to be run from the same directory where
you run the profiler):

```console
dprofpp
```

## See also

* [Profiling Perl](http://www.perl.com/pub/2004/06/25/profiling.html), by Simon
  Cozens
