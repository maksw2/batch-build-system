my attempt at a build system.
it's very limited because windows batch.
uses g++ and a file list (filelist.txt)
in the future i want to add options for multiple compilers, building dlls and static libraries,
configuration files, including filelists from filelists.
now only existing launch arg is to set final executable name:
make.cmd EXEC_NAME (no extension!!!)
feel free to open issues and prs.
this is activly maintained.