# matSurf
Tool to visualise FreeSurfer generated surfaces in Matlab

For FreeSurfer see - https://surfer.nmr.mgh.harvard.edu/

Developing this tool to get some UI programming experience in Matlab, main aims:

1)  Be able to visualise a FreeSurfer generated surface in Matlab
2)  Be able to add on overlays to the surface (e.g. retinotopic mapping data, fMRI activation)
3)  Be able to customise those overlays, e.g. masking by Z-Score or changng colormaps
4)  Be able to draw ROIs on the surface (particularly for retinotopy) and save those out as FreeSurfer labels

More generally...
- Want to minimise the use of external toolboxes and keep it as 'core' Matlab as possible
- Want to create good synergy between Matlab and 'matSurf', so can e.g. try analysing data in Matlab then quickly view the results on the surface, rinse and repeat
