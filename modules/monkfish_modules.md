# 📦 Available Spack Modules

Modules available on this system are organized by environment and compiler. Each entry includes a brief description and tags for currently loaded `(L)` and default `(D)` modules.

---
## 🖥️ Core Modules — `/opt/sw/modules/linux-ubuntu22.04-x86_64/Core`

| Module Name                          | Description                                      | Notes     |
|--------------------------------------|--------------------------------------------------|-----------|
| `StdEnv`                             | Standard environment base module                | **(L)**   |
| `aocc/4.1.0-jbnmokw`                 | AMD Optimizing C/C++ Compiler                   |           |
| `cmake/3.27.7-iecjvg7`               | CMake build system                              | **(L)**   |
| `fftw/3.3.10-zx2ukb3`                | Fast Fourier Transform library  (for C )        |           |
| `g2c/2.0.0-ryfoeub`                  | GRIB2 Fortran-to-C interface (NCEP)             |           |
| `gcc/11.4.0-gpa7gcm`                 | GNU Compiler Collection                         |           |
| `gh/2.32.1-5b556bl`                  | GitHub CLI                                      |           |
| `gnuplot/5.4.3-m6fdhjv`              | Plotting utility                                |           |
| `hdf5/1.14.3-xqw2mo2`                | Hierarchical Data Format                        |           |
| `ip/3.3.3-zpgap4z`                   | The NCEP general interpolation library          |           |
| `libx11/1.8.4-tbwgqae`               | X Window System core protocol library           |           |
| `libxft/2.3.2-adcyq32`               | X FreeType interface library                    |           |
| `matlab/R2019b-s4a2zg6`             | MATLAB R2019b                                   |           |
| `matlab/R2022a-xrhzvkz`             | MATLAB R2022a                                   |           |
| `matlab/R2023a-w5rfesd`             | MATLAB R2023a                                   |           |
| `matlab/R2023b-bw5x3eq`             | MATLAB R2023b                                   | **(D)**   |
| `netcdf-c/4.9.2-l2utfuj`             | Core NetCDF library                             |           |
| `netcdf-fortran/4.6.1-ubfi2fw`       | Fortran interface to NetCDF                     |           |
| `netlib-lapack/3.11.0-oae77cr`       | LAPACK linear algebra library                   |           |
| `openblas/0.3.24-3ghuip4`            | Optimized BLAS library                          |           |
| `openjdk/11.0.20.1_1-2bcen6x`        | Java Development Kit (OpenJDK 11)               |           |
| `openmpi/4.1.6-rrw2r6f`              | OpenMPI                                         | **(L)**   |
| `py-jupyter/1.0.0-vgqfuqr`           | Jupyter metapackage                             |           |
| `py-numpy/1.26.1-y7z6m2e`            | NumPy for Python                                |           |
| `python/3.10.13-pyz2srm`             | Python 3.10                                     |           |
| `python/3.12.0-frmduvb`              | Python 3.12                                     | **(D)**   |
| `qt/5.15.11-uausxzm`                 | Qt GUI framework                                |           |
| `r/4.3.0-rszddot`                    | R statistical computing                         |           |
| `subversion/1.14.2-s34wsh7`          | Version control (SVN)                           |           |
| `tar/1.34-kvq7naq`                   | Tape Archiver                                   | **(L)**   |
| `tau/2.33-ushwn34`                   | Tuning and Analysis Utilities                   |           |

---

## 🔧 OpenMPI Stack — `/opt/sw/modules/linux-ubuntu22.04-x86_64/openmpi/4.1.6-rrw2r6f/Core`
These are shown by default because openmpi/4.1.6 is loaded in the core modules
| Module Name                       | Description                                             | Notes     |
|-----------------------------------|---------------------------------------------------------|-----------|
| `cdo/2.2.2-rgmyuut`               | Climate Data Operators                                  |           |
| `eccodes/2.25.0-mdwifdw`          | GRIB and BUFR encoding/decoding (ECMWF)                 |           |
| `esmf/8.5.0-fvc74ay`              | Earth System Modeling Framework                         |           |
| `nco/5.1.6-ok5oedt`               | NetCDF Operators for data manipulation                  |           |
| `netcdf-c/4.9.2-75pgbfk`          | Core NetCDF C library                                   | **(L,D)** |
| `netcdf-cxx4/4.3.1-zcuspaf`       | C++ interface to NetCDF                                 |           |
| `netcdf-fortran/4.6.1-zgcmhqb`    | Fortran interface to NetCDF                             | **(L,D)** |
| `netlib-scalapack/2.2.0-uuiv7oi`  | ScaLAPACK parallel linear algebra                       |           |
| `parallel-netcdf/1.12.3-o45lllq`  | Parallel NetCDF for MPI applications                    |           |
| `valgrind/3.20.0-hv57c5t`         | Memory debugging and profiling tool                     |           |

---

## 🧪 AOCC Compiler Stack — `/opt/sw/modules/linux-ubuntu22.04-x86_64/aocc/4.1.0`
These require the aocc/4.1.0 module from the core modules to be loaded. Once aocc is loaded, the available modules expand to look very much like the OpenMPI stack above.
| Module Name                     | Description                       | Notes     |
|---------------------------------|-----------------------------------|-----------|
| `openmpi/4.1.6-25i3e6u`         | OpenMPI built with AOCC 4.1.0     |           |
| `openmpi/4.1.6-ztwqdhx`         | Default OpenMPI with AOCC         | **(D)**   |

---

## 🔍 Notes

- **(L)** indicates a module that is **loaded** by default into the user environment.
- **(D)** marks the **default version** of that module, automatically selected if no version is specified.

Modules can take the full name of the command or the abbreviated version. Here are some equivalent commands:

| Long Command          | Short Command       |
|-----------------------|---------------------|
|`module available`     | `ml av`             |
|`module list`          | `ml`                |
|`module load openmpi`  | `ml openmpi`        |
|`module unload openmpi`| `ml -openmpi`       |

- Remove all loaded modules with the command `ml purge`
- Reset the environment to the default loadout with `ml reset`.
- Search through packages for STRING using spider, `ml spider STRING`
- Show all hidden modules `ml --show-all avail`
