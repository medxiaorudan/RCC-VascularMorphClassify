# Contents of this Folder

## Functions:
- **apply_filter.m**: Applied a filter to detect linear structures.
- **clean_skeleton.m**: Some post-processing on the skeleton (remove small branches etc).
- **extract_network.m**: Extracts the skeleton of the vascular network.
- **extract_vessels.m**: Extracts the vascular network.
- **overlay.m**: Just a function to create an overlay of an image and a binary mask (for illustration purpose).
- **preprocess_image.m**: A few preprocessings on the image.
- **showskel.m**: Another function to show the skeleton of a graph.
- **skeleton_analysis.m**: Computes basic features on the graph.

## Scripts:
- **collect_data_from_skeletons.m**: Collects data from the skeletons corresponding to a WSI.
- **extract_all_networks.m**: Extract all the networks on the subimages corresponding to a WSI.
- **extract_networks.m**: Just some test script. Most of what it does is in 'extract_all_networks.m' (I just don't like to delete code).
- **factorize_gabor.m**: Some test script to implement gabor filter.
- **frangi_segmentation.m**: Some test also.
- **fuzzy_detection_test.m**: Some tests.
- **gabor_segmentation.m**: Some tests.
- **half_gabor_segmentation.m**: Some tests.
- **nuclei_detection.m**: Some test script to detect the nuclei with basic morphological operations.
- **overlay_graphs_on_images.m**: A script to show the graph detected on the image for illustration/evaluation purpose.
- **skeletonization.m**: Some tests.
- **water_sheld_Visualization.m**: Visualization result of the water sheld algorithm.

## Folders:
- **external_functions**: A few external functions used in the code.
- **rita_functions**: Rita's functions.
