# Hacking

## Getting the source code

```console
git clone https://github.com/analizo/analizo.git
```

## Installing Dependencies

Run this command:

```console
./development-setup.sh
```

If you are using Debian, the script will do everything you need.

If you are using another system, you will have to install some dependencies
first. Check the "Installing dependencies on non-Debian systems" below.

## Running the test suite

Just run `dzil test` in the root of the sources:

```console
dzil test
```

To run a single unit test use `prove`:

```console
prove t/Analizo/Metrics.t
```

Features can also be executed with `pherkin` as:

```console
pherkin t/features/metrics-batch.feature
```

See "Installing Dependencies" above for a guide to install all the software
that's needed to run Analizo tests.

## Building

```console
dzil build
```

## Style and Good practices

Always write automated tests for your code:

* if you are adding a new feature, write a new cucumber feature
  file that shows how the feature is expected to work
* if you are fixing a bug, make sure that you add a test that fails because
  of the bug, and then work on a fix to it.
* If removing any code does not make any test to fail, then that code can be
  removed at any time.
* Make sure the existing tests still pass after you change, add or remove
  any code.

Refactoring code to make it simpler, easier to change or extend is always a
good thing. Just make sure that the entire test suite still passes after you do
any refactoring.

Use 2 indentation of 2 spaces.

Please always put the opening curly brace of a block in the same line of the
corresponding instruction (e.g.  if, for etc).

Good:

```
if (...) {
  ...
}
```

Bad:

```
if (...)
{
  ...
}
```

Always "use strict" in the top of new modules.

Don't bother changing the AUTHORS file. It's automatically generated as part of
the release process. See the dist.ini for more information.

# Sending patches

Send the patches to the Analizo mailing list: analizo@googlegroups.com (see
subscription instructions at [community page](community.html))
or to `joenio@joenio.me`. Or create a pull request on github.

To create a patch:

```console
git clone https://github.com/analizo/analizo.git
cd analizo
edit file
git commit file
git format-patch origin
```

This will generate patch files named like
`0001-message-you-typed-for-the-commit.patch`.

If you want to make several changes, please consider making one commit (and
therefore one patch) for each different logical change you want to make.  In
this case, after running git format-patch you'll have a series of patch files
named like 0001-..., 0002-..., just send them all.

You are encouraged to learn how to use git since it's a powerful version
control system and it can make it easy for you to keep in sync with Analizo
development.

Please write good commits messages. Read the following two links, and use
common sense:

- [A note about git commit messages](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
- [5 useful tips for a better commit message](http://robots.thoughtbot.com/post/48933156625/5-useful-tips-for-a-better-commit-message)

Patches with multiple authors should list the authors in the end of commit
message, using a `Signed-off-by` tag, one author per line. Example:

```
  Signed-off-by: John Doe <johndoe@example.org>
  Signed-off-by: Random Hacker <rhacker@example.org>
```

See commit `005c3bff4e0809eae0340e7629678186d1621930` for an example.

# Installing dependencies on non-Debian systems

1) Install Doxyparse build dependencies: flex, bison, libqt4-dev, gcc, gcc-c++,
python, and git (your operating system probably already has packages for these)

2) Install Doxyparse (see [https://github.com/analizo/doxyparse/wiki][doxyparse])

3) Install [SLOCCount](http://www.dwheeler.com/sloccount/sloccount.html)

4) Make sure you also have `man` and `sqlite3` installed.
