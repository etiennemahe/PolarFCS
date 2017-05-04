# PolarFCS Standalone (see note for MATLAB users below)
Installation instructions can be found in the "README.md" file

## PolarFCS Masthead
Users must select an input file, either by pasting the full file path into the "File Path" text box or by clicking on "Select File for Analysis". Users should then click on "Analyze" to run the analysis of the input file

### Input file format
PolarFCS will accept ".txt", ".csv", ".lmd" or ".fcs" files. 

The former two file formats should be uncompressed tab- or comma-demlimited files, respectively, with the first row listing parameter names (as strings). Subsequent rows are assumed to be events; these must be unnamed (i.e. the first column is the first parameter and should not be a column of row names) 

The latter two file types are Flow Cytometry Standard (FCS) formats (with FCS 2.0 and FCS 3.0 supported by PolarFCS). Further information about the structure and data formats of these files can be found through other sources (see for example http://murphylab.web.cmu.edu/publications/64-seamer1997.pdf ). To confirm the correct FCS format version, users can open their files with a text-reader; the FCS format version should be the first visible tag:value pair of the header.

## Select Parameters Window
Users must then confirm the parameters for inclusion in the calculations and plot. This is done by selecting the desired parameters from the list provided by PolarFCS (based on its parsing of the input data files). Users can opt to change the names of the parameters as well. 

MATLAB has restrictions on what sort of strings may be used as variable names (i.e. the parameters names in this case): a valid variable name starts with a letter, followed by letters, digits, or underscores. The space character (' ') is not permitted.

## Plot Window
After the initial plot is produced, users can alter the scale and position of the polar axes in order to tease apart event subsets. In order to facilitate ease of computation, users must adjust the polar axes and click on "Re-Calculate" to complete their changes. Similarly, in order to re-calculate the number of events in the counting field, users must also click on "Re-Calculate". PolarFCS will entitle the plot with the name of the input file.

Since the plot window is an instance of MATLAB, users can employ the basic MATLAB figure window functions to save, export, print, etc. These functions are accessible under the File menu. Users can also pan, rotate and scale plots using the icons to the top left of the plot.

# MATLAB users (makefcspolarscatter.m)
MATLAB users may use the makefcspolarscatter.m script from the commandline, which will take input data, parameter lists, plot title, and a color matrix directly, avoiding the standalone Masthead & parameter selection GUIs.

The makefcspolarscatter.m function takes input data (first argument), an n x m matrix with n rows that are assumed to represent events and m columns assumed to be parameters (column/row headers absent). Other variable arguments include: 'Parameters', a cell of strings to be used as parameter labels for plotting; 'PlotTitle', a string title for the plot; 'ColorProfile', RGB format color data, either a single vector (eg [0 0 1] for blue) or n x 3 matrix with event-specific color settings (for data subset specific coloring, based, for example, on previously generated gating or membership strategies).
