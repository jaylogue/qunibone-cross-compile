# UniBone / QBone Cross-Compilation Makefile

This project provides a top-level Makefile that can be used to cross-compile the UniBone / QBone Linux-to-PDP-11 bridge software on a modern Linux machine.
The Makefile handles all the steps required to build the software, including downloading cross-compilation toolchains, downloading and building support libraries, cloning the QUniBone github repo and applying necessary patches.

All tools and source files are downloaded and built in a local working directory, eliminating the need to install specialized software on the host system.

The current version of the Makefile has been tested and verified on Linux Mint 22.1 (Ubuntu 24.04) targeting the latest QUniBone source as of 2026/04/15 (commit 8de7641 on 2025/08/15).

## Usage

```bash
git clone https://github.com/jaylogue/qunibone-cross-compile.git
cd qunibone-cross-compile
make
```

## Makefile Targets

The Makefile supports the following build targets:

`all`, `build-qunibone`
- Download, patch and build the QUniBone source for the target platform.  This results in the `demo` application being built.

`clean`, `clean-qunibone`
- Clean the QUniBone source tree

`reset`
- Reset the build state.  This deletes the directories containing the QUniBone source tree, the support packages and the cross-compilation toolchains, but retains the files in the download directory.

`download-arm-toolchain`, `install-arm-toolchain`, `download-pru-toolchain`, `install-pru-toolchain`
- Download and install the various cross-compilation toolchains.

`download-libtirpc`, `unpack-libtirpc`, `configure-libtirpc`, `build-libtirpc`, `clean-libtirpc`
- Download, unpack (untar), configure, build and clean the Transport-Independent RPC (libtirpc) library package.

`download-pru-package`
- Download the AM335x PRU software package.

`remove-arm-toolchain`, `remove-pru-toolchain`, `remove-librirpc`, `remove-pru-package`, `remove-qunibone`
- Remove / uninstall the directories associated with the various toolchains and software packages.


## Compilation Options

The following options can specified on the make command line:

`QUNIBONE_PLATFORM=UNIBUS|QBUS`
- Specifies target hardware platform.  Default is UNIBUS.

`MAKE_CONFIGURATION=DBG|RELEASE`
- Specifies whether to build a debug or release build.  Default is RELEASE.

`BUILD_DIR=<path>`
- Build working directory. Defaults to the directory of the Makefile.

`DOWNLOAD_DIR=<path>`
- Directory used to cache downloaded files. Defaults to `<BUILD_DIR>/dl`.

`QUNIBONE_REPO_URL=<url>`
- QUniBone repo URL.  Default is https://github.com/j-hoppe/QUniBone.git

`ARM_TOOLCHAIN_URL=<url>`

`TI_PRU_TOOLCHAIN_URL=<url>`

`PRU_PACKAGE_REPO_URL=<url>`

`LIBTIRPC_PACKAGE_URL=<url>`
- URLs for cross-compilation toolchains and support packages.  See Makefile source for defaults.


## License

The UniBone / QBone Cross-Compilation Makefile and associated files are licensed under the [Apache 2.0 license](LICENSE.txt).
