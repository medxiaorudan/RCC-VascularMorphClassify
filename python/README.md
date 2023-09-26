# Python Scripts for WSI Processing

In this folder, the python scripts are primarily used for handling the Whole Slide Images (WSI) using the OpenSlide Python interface and some basic preprocessing.

## Prerequisites

To run these scripts, ensure you have:

- Python 2.7
- Libraries from the scientific computing stack (e.g., Numpy, SciPy). If you don't have these, consider installing [Anaconda](https://www.continuum.io/downloads). It works seamlessly.

## Scripts in this Subfolder

- `extract_low_res_png.py`: Extracts the low-resolution image (`level3.png`) from the WSI.
- `extract_multiple_low_res_png.py`: Essentially does the same as the above but at different levels of the WSI pyramid.
- `segment_roi_gt.py`: Performs subsampling of the WSI image based on the `mask_gt.png` image and saves all the subimages in a `subimages` folder. It also creates the `subimages`, `skeletons`, and `overlays` folders.
- `segment_ROIs.py`: Segments the tumor areas of the tissue with unsupervised learning. It aims to be an automated version of `segment_roi_gt.py` but requires improvements.
