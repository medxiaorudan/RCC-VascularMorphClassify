This folder contains the following functions:
	- 'apply_filter.m': applied a filter to detect linear structures
	- 'clean_skeleton.m': some post-processing on the skeleton (remove small branches etc)
	- 'extract_network.m': extracts the skeleton of the vascular network
	- 'extract_vessels.m': extracts the vascular network
	- 'overlay.m': just a function to create an overlay of an image and a binary mask (for illustration purpose)
	- 'preprocess_image.m': a few preprocessings on the image
	- 'showskel.m': another function to show the skeleton of a graph
	- 'skeleton_analysis.m': computes basic features on the graph

scripts:
	- 'collect_data_from_skeletons.m': collects data from the skeletons corresponding to a WSI
	- 'extract_all_networks.m': extract all the networks on the subimages corresponding to a WSI
	- 'extract_networks.m': just some test script. most of what it does is in 'extract_all_networks.m' (I just don't like to delete code)
	- 'factorize_gabor.m': some test script to implement gabor filter
	- 'frangi_segmentation.m': some test also
	- 'fuzzy_detection_test.m': some tests
	- 'gabor_segmentation.m': some tests
	- 'half_gabor_segmentation.m': some tests
	- 'nuclei_detection.m': some test script to detect the nuclei with basic morphological operations
	- 'overlay_graphs_on_images.m': a script to show the graph detected on the image for illustration/evaluation purpose
	- 'skeletonization.m': some tests
	- 'water_sheld_Visualization.m': Visualization result of the water sheld algorithm

and folders:
	- 'external_functions': a few external functions used in the code
	- 'rita_functions': Rita's functions
