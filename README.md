# PolarFCS
A Multi-Parametric Data Visualization Aid for Flow Cytometry Assessment

# Background
PolarFCS takes input flow cytometry data and performs eventwise multi-parametric center-of-mass calculation. The center-of-mass of each event is then plotted on a 2-dimensional scatter plot. The resulting scatter plot also contains axes for each of the input parameters, these capable of adjustment and scaling by users. 

# Installation
For author convenience, PolarFCS was written in MATLAB. As most users will know, MATLAB is not an open source language. To this end, however, compiled binaries were produced for Windows 7 and MacOSX users, which can be downloaded. In each case, the appropriate MATLAB runtime must also be downloaded and installed. For advanced users interested in incorporating center-of-mass analysis into their own pipelines, the relevant source code is also provided (makefcspolarscatter.m).

Begin by downloading and installing the necessary MATLAB runtime. These are available from https://www.mathworks.com/products/compiler/mcr.html 

Be certain to select both the correct version and correct operating system: PolarFCS was written for and compiled in version R2016b (9.1).

Download and unzip the PolarFCS package by clicking on "Clone or download" followed by "Download Zip" on the github PolarFCS page (https://github.com/etiennemahe/PolarFCS).
