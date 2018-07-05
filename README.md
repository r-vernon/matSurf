# matSurf
Tool to visualise FreeSurfer generated surfaces in Matlab

> For FreeSurfer see - https://surfer.nmr.mgh.harvard.edu/

Developing this tool to get some UI programming experience in Matlab, main aims:

1)  Be able to visualise a FreeSurfer generated surface in Matlab
2)  Be able to add on overlays to the surface (e.g. retinotopic mapping data, fMRI activation)
3)  Be able to customise those overlays, e.g. masking by Z-Score or changng colormaps
4)  Be able to draw ROIs on the surface (particularly for retinotopy) and save those out as FreeSurfer labels

More generally...
- Want to minimise the use of external toolboxes and keep it as 'core' Matlab as possible
- Want to create good synergy between Matlab and 'matSurf', so can e.g. try analysing data in Matlab then quickly view the results on the surface, rinse and repeat
- In accordance with above, aiming for efficient code that tries to minimise memory usage, e.g. by passing around handles to a surface rather than the surface data itself, and casts to single or uint32 where possible

Will be implemented in *three* (?) specific modes:
1) Camera mode - rotate, pan, zoom camera around surface, no surface interaction
2) Data mode - Static surface, clicking on a vertex returns overlay information for that vertex (e.g. Z-Score if fMRI data loaded as overlay)
   - Possibly ROI membership as well but will see...
3) ROI mode - Static surface, clicking on the surface creates paths across the surface, closing the path with form an ROI
4) Timeseries mode - (*possibly*) Would like to be able to add data timeseries onto the surface as well, then plot timeseries either for a selected vertices, or collapsed across vertices within an ROI, may integrate into Data mode...

--------------------------------------------------------------------------------

*Still developing the tool so most functionality missing right now* 

*Location to data also currently hardcoded whilst I'm developing software*

## Main functions
- matSurf - main function, loads the figure and sets necessary callbacks
- matSurf_createFig - programmatically creates figure, arranges buttons etc
- matlab_visual_test - initial scripted attempt to visualise ROIs, add overlays, draw on surface

## Additional 
**(*only describing key files for now*)**
- @brainSurf - Surface class, contains surface data for a single hemisphere, including overlays, ROIs
- @cmaps - Colormaps class, sets up all the default colormaps for the tool, and allows you to map data to specific colors. 
- misc_fig - Will store any additional figures, e.g. 'get subject information' or 'mask overlay' figures
- misc_fn - Will store any additional functions that have no obvious associations

--------------------------------------------------------------------------------

## TODO

- [ ] Implement ROI creation code
- [ ] Implement overlay masking code
- [ ] Implement three core mode functionality (Camera, Data, ROI)
- [ ] Implement data view callbacks
- [ ] Make colormaps perceptuall linear (currently using Matlab defaults)
- [ ] Make sure e.g. brainSurf class is deleted properly when figure closed, to avoid memory leaks
