
Observed Output:
================

    > b --version
    build2 0.9.0-a.0.ba8ce9226af0
    libbutl 0.9.0-a.0.3bf1846063ad
    host x86_64-microsoft-win32-msvc14.1
    Copyright (c) 2014-2018 Code Synthesis Ltd
    This is free software released under the MIT license.

0. Just the library
-------------------1

`buildfile` is only 2 lines:

    ./: {*/ -build/} manifest lib{repro}
    lib{repro} : hxx{public private}

The headers exist but only have `#pragma once` as content.
There is also a `foruseronly.hxx` header for a later test.

    > b
    info: ..\build-repro\dir{repro_install_headers\} is up to date

    > b install config.install.root=../install/repro/
    install manifest{manifest}@..\build-repro\repro_install_headers\
    install hxx{public}@..\build-repro\repro_install_headers\
    install hxx{private}@..\build-repro\repro_install_headers\
    install ..\build-repro\repro_install_headers\pca{repro}
    install ..\build-repro\repro_install_headers\pcs{repro}

Both `public.hxx` and `private.hxx` headers are installed, as expected.

1. Don't install the private header
-----------------------------------

We add this line to the buildfile:

    hxx{private} : install = false

Then try to build and install:

    > b
    error: no rule to update ..\build-repro\repro_install_headers\hxx{private}
    info: re-run with --verbose 4 for more information
    info: while applying rule cxx.link to update ..\build-repro\repro_install_headers\libs{repro}
    info: while applying rule bin.lib to update ..\build-repro\repro_install_headers\lib{repro}
    info: while applying rule alias to update ..\build-repro\dir{repro_install_headers\}
    info: failed to update ..\build-repro\dir{repro_install_headers\}

    > b install config.install.root=../install/repro/
    install manifest{manifest}@..\build-repro\repro_install_headers\
    install hxx{public}@..\build-repro\repro_install_headers\
    install ..\build-repro\repro_install_headers\pca{repro}
    install ..\build-repro\repro_install_headers\pcs{repro}

As expected, `b install` will not install the private header.
However we get a weird error when building.

2. Explicitely state that publich header should be installed
------------------------------------------------------------

We remove the previous test's line and start again (with `b clean`) this time with:

    hxx{public} : install = true

This is redundant with the default because we already made this header a requirement of the library, which implies that this header is installed by default.

    > b
    error: no rule to update ..\build-repro\repro_install_headers\hxx{public}
    info: re-run with --verbose 4 for more information
    info: while applying rule cxx.link to update ..\build-repro\repro_install_headers\liba{repro}
    info: while applying rule bin.lib to update ..\build-repro\repro_install_headers\lib{repro}
    info: while applying rule alias to update ..\build-repro\dir{repro_install_headers\}
    info: failed to update ..\build-repro\dir{repro_install_headers\}

    > b install config.install.root=../install/repro/
    error: no rule to update (for install) ..\build-repro\repro_install_headers\hxx{public}
    info: re-run with --verbose 4 for more information
    info: while applying rule install.file to update (for install) ..\build-repro\repro_install_headers\hxx{public}
    info: while applying rule cxx.install to update (for install) ..\build-repro\repro_install_headers\liba{repro}
    info: while applying rule bin.lib to update (for install) ..\build-repro\repro_install_headers\lib{repro}
    info: while applying rule install.alias to update (for install) ..\build-repro\dir{repro_install_headers\}
    info: failed to update (for install) ..\build-repro\dir{repro_install_headers\}

Explicitely stating that a header should be installed seems to trigger this error, which seems out of place.

3. Explicitely state which header to publish or not
---------------------------------------------------

This time we try with a combination, that matches my initial attempt at making some headers public and some other headers private explicitely:

    hxx{public} : install = true
    hxx{private} : install = false

Then:

    > b
    error: no rule to update ..\build-repro\repro_install_headers\hxx{public}
    info: re-run with --verbose 4 for more information
    info: while applying rule cxx.link to update ..\build-repro\repro_install_headers\liba{repro}
    info: while applying rule bin.lib to update ..\build-repro\repro_install_headers\lib{repro}
    info: while applying rule alias to update ..\build-repro\dir{repro_install_headers\}
    error: no rule to update ..\build-repro\repro_install_headers\hxx{private}
    info: re-run with --verbose 4 for more information
    info: while applying rule cxx.link to update ..\build-repro\repro_install_headers\libs{repro}
    info: while applying rule bin.lib to update ..\build-repro\repro_install_headers\lib{repro}
    info: while applying rule alias to update ..\build-repro\dir{repro_install_headers\}
    info: failed to update ..\build-repro\dir{repro_install_headers\}

    > b install config.install.root=../install/repro/
    error: no rule to update (for install) ..\build-repro\repro_install_headers\hxx{public}
    info: re-run with --verbose 4 for more information
    info: while applying rule install.file to update (for install) ..\build-repro\repro_install_headers\hxx{public}
    info: while applying rule cxx.install to update (for install) ..\build-repro\repro_install_headers\liba{repro}
    info: while applying rule bin.lib to update (for install) ..\build-repro\repro_install_headers\lib{repro}
    info: while applying rule install.alias to update (for install) ..\build-repro\dir{repro_install_headers\}
    info: failed to update (for install) ..\build-repro\dir{repro_install_headers\}

Both operation fails, but the install seems to fail only for the public header.

4. Install a header that should only be used by the user
--------------------------------------------------------

This time we keep the default (all headers published, situation 0) but want to add a header to the install, without it being available to build the library (some libraries does that, though it's not always an issue to add these headers to the library requirements):

    hxx{foruseronly} : install = true

Then:

    > b
    info: ..\build-repro\dir{repro_install_headers\} is up to date

    > b install config.install.root=../install/repro/
    install manifest{manifest}@..\build-repro\repro_install_headers\
    install hxx{public}@..\build-repro\repro_install_headers\
    install hxx{private}@..\build-repro\repro_install_headers\
    install ..\build-repro\repro_install_headers\pca{repro}
    install ..\build-repro\repro_install_headers\pcs{repro}

The header `foruseronly.hxx` is not installed.
I am currently assuming that this is on purpose as the file is never refered by the build requirements of the directory.

As it is not possible to add a `hxx{somefile}` in the directory requirement, I suspect the best way to do this is simply to make a header-only library:

    ./: {*/ -build/} manifest lib{repro} lib{additional_headers}

    lib{repro} : hxx{public private}
    lib{additional_headers} : hxx{foruseronly}

In this case all headers are installed.

So this is not a real problem, though I wanted to point it because it might not be obvious at first attempt to express this.

5. Install a header with the wrong extension (required by lua)
--------------------------------------------------------------

Now we want to be able to install a file that is not part of the build.
As we know (see 4.), if we don't require that header, it will not be installed.

    lib{repro} : hxx{someapi.hpp}

This works as expected: the file is installed. However we didn't want to make this file available to the library compilation. Alternatively:

    lib{repro} : file{someapi.hpp}

However:

    > b install config.install.root=../install/repro/
    install manifest{manifest}@..\build-repro\repro_install_headers\
    install hxx{public}@..\build-repro\repro_install_headers\
    install hxx{private}@..\build-repro\repro_install_headers\
    install ..\build-repro\repro_install_headers\pca{repro}
    install ..\build-repro\repro_install_headers\pcs{repro}

`someapi.hpp` is not installed at all.
Assuming it's the default behavior for `file` target, we add:

    lib{repro} : file{someapi.hpp}
    file{someapi.hpp} : install = true

Then:

    > b
    error: no rule to update ..\build-repro\repro_install_headers\file{someapi.hpp}
    info: re-run with --verbose 4 for more information
    info: while applying rule cxx.link to update ..\build-repro\repro_install_headers\libs{repro}
    info: while applying rule bin.lib to update ..\build-repro\repro_install_headers\lib{repro}
    info: while applying rule alias to update ..\build-repro\dir{repro_install_headers\}
    info: failed to update ..\build-repro\dir{repro_install_headers\}

    > b install config.install.root=../install/repro/
    error: no rule to update (for install) ..\build-repro\repro_install_headers\file{someapi.hpp}
    info: re-run with --verbose 4 for more information
    info: while applying rule install.file to update (for install) ..\build-repro\repro_install_headers\file{someapi.hpp}
    info: while applying rule cxx.install to update (for install) ..\build-repro\repro_install_headers\liba{repro}
    info: while applying rule bin.lib to update (for install) ..\build-repro\repro_install_headers\lib{repro}
    info: while applying rule install.alias to update (for install) ..\build-repro\dir{repro_install_headers\}
    info: failed to update (for install) ..\build-repro\dir{repro_install_headers\}


This seems to be just a variant of the previous issues.