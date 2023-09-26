In this folder, the python scripts are mostly used to deal with the WSI
thanks to the OpenSlide Python interface and some basic preprocessing.

To have these scripts work, you need python 2.7 installed with the
libraries from the scientific computing stack (Numpy, SciPy, ...) installed.
You can install Anaconda if you don't have any of these
(https://www.continuum.io/downloads), it works just fine.

This subfolder contains:
	- 'extract_low_res_png.py' extracts the low resolution image (level3.png)
	from the WSI.
	- 'extract_multiple_low_res_png.py' does basically the same thing but
	a different levels of the WSI pyramid
	- 'segment_roi_gt.py' which performs the subsampling of the WSI image in
	subimages based on the 'mask_gt.png' image and saves all the subimages in a
	'subimages' folder. It also creates the 'subimages', 'skeletons' and
	'overlays' folders.
	- segment_ROIs.py which segments the tumor aeras of the tissue with
	unsupervised learning. It is supposed to be an automated version of
	'segment_roi_gt.py' but doesn't work perfectly and needs to be improved.

