pactivate
=========

`pactivate` is a script to build a Python virtualenv for a project that has
no dependencies on any Python packages not distributed with Python itself,
not even [pip]. You need only Python itself (such as one supplied by your
OS packaging system, one built by [Pythonz], or a manual download and build
of the Python source). Note that some Linux distributions do not supply all
of the base Python system in the standard package; with Debian for example
you must install `python3-distutils` as well as `python3`.

`pactivate` needs to know the _base directory_ (BASE) for your project
(so it can find configuration files) and the _build directory_ under which
it will store the bootstrap files and the virtual environment that it
creates.

BASE defaults to the directory in which `pactivate` resides. (It's usual to
put `pactivate` in the root of the project if developers source it from the
command line.) BUILD is `$BASE/.build/` by default. These may be changed
with the `-B` and `-b` options respectively.

### Files and Directories

    $BUILD/
    ├ bootstrap/pactivate/  Independent copies of pip and virtualenv
    └ virtualenv/           Virtual environment created for the project
    $BASE/
    ├ .python               Python interpreter for building virtualenv
    └ requirements.txt      Packages to be installed in the project virtualenv

If it exists, `.python` (which is typically a symlink) is used only to
install a new virtualenv when there isn't an existing one. However, even
after this, if it exists it _must always_ point to a valid Python
interpreter or pactivate will fail. (This is a bug, but probably not worth
the complexity to fix.)

### Command-line options

- `-b BUILD`: Set the build dir
- `-B BASE`: Set the base dir
- `-i`: Enter interactive shell in container after the test completes
- `-q`: Run programs in quiet mode to reduce output verbosity

You can use a different python interpreter by symlinking `$BASE/.python` to
your interpreter of choice. This is not normally commited, but is in $BASE
so that it persists even after `rm -rf $BUILD` to do a fully clean build.


Developer Notes
---------------

The tests are run with `./Test`. You can use the `-q` option to produce
significantly less output, but this usually makes idenitifying problems
significantly more difficult. The `-i` option will start an interactive
shell in the test container after the test completes or fails (the startup
message will give the exit code indicating success or failure) to allow for
interactive investigation of problems or simply playing with the script.

The tests are run in a Docker container to ensure that `pactivate` does not
accidentally use an existing installation of `pip` or `virtualenv`. The
`Test` script runs `docker` with `sudo` and so will first prompt for your
sudo password if sudo requires one and your sudo credentials are not
already cached. (The `docker` command [grants full root privileges to any
user that can run it][docker-is-root], so you should not use a "docker"
group; not granting sudo privileges to members of that group simply
disguises the fact that they have full root access anyway.)

`pactivate`, being sourced, runs in a special environment:
1. We cannot use `exit` because that will exit the calling script (or worse
   yet, close the window of the user that sourced the script at the command
   line). However, in a sourced script `return` will abort execution of the
   remainder of the sourced script, and the source command will return the
   exit code given to `return`.
2. We are constrained by the environment set by the calling script (or in
   the calling user's shell). For example, the `-e` option may or may not
   be set, so we can't rely on untested commands stopping execution. We
   also cannot use `trap` for any cleanup because a) we're only a fragment
   of a script, so we never exit, and b) it would override any `trap`
   setting in a calling script.


<!-------------------------------------------------------------------->
[pip]: https://en.wikipedia.org/wiki/Pip_(package_manager)
[pythonz]: https://github.com/saghul/pythonz
[docker-is-root]: https://docs.docker.com/engine/security/#docker-daemon-attack-surface
