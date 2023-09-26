#==============================================================================
# Experiments on Region Of Interest segmentation (from low resolution images) 
# to extract tumor regions: for now, using K-means pixelwise clustering on 
# texture maps
#==============================================================================


#==============================================================================
# Importing needed libraries
#==============================================================================
from __future__ import division
import numpy as np
import skimage
import skimage.io
import skimage.exposure
import skimage.filters
import skimage.morphology
import skimage.segmentation
import skimage.measure
#import milk
import os
import scipy.ndimage as sndim
from pylab import *
import sklearn
import sklearn.preprocessing
import subprocess
import cv2
#==============================================================================
# The executable files to work with the .scn files
#==============================================================================
opslide_show_props_exe = r'D:/Doctoral_Programs/RCC/openslide-win64-20171122/bin/openslide-show-properties.exe'
opslide_write_png_exe = r'D:/Doctoral_Programs/RCC/openslide-win64-20171122/bin/openslide-write-png.exe'

#==============================================================================
# Select the path of the image you want to work on
#==============================================================================
# data folder
#main_histo_data = r'D:\Doctoral_Programs\RCC\data'

# image folder
case_folder = r'D:\Doctoral_Programs\RCC\data'

#==============================================================================
# define a few parameters
#==============================================================================
size_small_object = 1e4 
size_neighborhood = 40 #size of the neighborhood for the texture filters
x_width = 50
y_height = 50
x_overlap = 5
y_overlap = 5
save_subimages = True
plot_images = True
mask_area_threshold = 0.5 * x_width * y_height

# Look for .scn files
file_scn = [f for f in os.listdir(case_folder) if '.scn' in f] #find .scn file

for i, f in enumerate(file_scn):
    path_image_scn = os.path.join(case_folder,f) # full path
#==============================================================================
# define a few functions
#==============================================================================

    def is_number(s): #check whether a character is a number
        try:
            float(s)
            return True
        except ValueError:
            return False
        
    def run_from_ipython():
        try:
            __IPYTHON__
            return True
        except NameError:
            return False
    # get image info
    command_show = [opslide_show_props_exe, path_image_scn]
    output = subprocess.check_output(command_show)
    lines = output.splitlines()
    bounds_x_field = [str(line) for line in lines if "openslide.bounds-x" in str(line)]
    bounds_x = [char for char in bounds_x_field[0] if is_number(char)]
    bounds_x = int("".join(bounds_x))

    bounds_y_field = [str(line) for line in lines if "openslide.bounds-y" in str(line)]
    bounds_y = [char for char in bounds_y_field[0] if is_number(char)]
    bounds_y = int("".join(bounds_y))

    total_width_field = [str(line) for line in lines if "openslide.bounds-width" in str(line)]
    total_width = [char for char in total_width_field[0] if is_number(char)]
    total_width = int("".join(total_width))

    total_height_field = [str(line) for line in lines if "openslide.bounds-height" in str(line)]
    total_height = [char for char in total_height_field[0] if is_number(char)]
    total_height = int("".join(total_height)) 
    
# load image and separate channels, mean, min, max (over the three channels)
    level = 3; # select resolution level to work with

    mask_name=f.split('.scn')[0]
    if mask_name==f.split('.scn')[0]:               
        img = skimage.io.imread(os.path.join(case_folder,mask_name+'-mask.png'))
        img_original = np.array(img[:,:,:3], dtype=np.float64)
        img_original = img_original.sum(axis=2) == 0

        close("all")
            
        if not run_from_ipython():
            figManager.window.showMaximized()
            show()

        figure(), imshow(img_original)
        figure(), imshow(img_original, cmap='gray',  interpolation='nearest'), axis('off'), title('initial ROI')

        nnz = np.nonzero(img_original)
        y_min = np.min(nnz[0])
        y_max = np.max(nnz[0])
        x_min = np.min(nnz[1])
        x_max = np.max(nnz[1])

#==============================================================================
# Create the needed folders if they do not exist
#==============================================================================
        if save_subimages:
            subimages_folder = os.path.join(case_folder,str(i),"subimages")
            skeletons_folder = os.path.join(case_folder,str(i),"skeletons")
            overlays_folder = os.path.join(case_folder,str(i),"overlays")
            if not os.path.exists(subimages_folder):
                os.makedirs(subimages_folder)
            if not os.path.exists(skeletons_folder):
                os.makedirs(skeletons_folder)
            if not os.path.exists(overlays_folder):
                os.makedirs(overlays_folder)

#==============================================================================
# Plot and save the subimages
#==============================================================================

        print ("saving the subimages")
  
        idx_image = 0

# Subsample the main image
        range_x = range(x_min, x_max, x_width - x_overlap)
        n_x = size(range_x)
        range_y = range(y_min, y_max, y_height - y_overlap)
        n_y = size(range_y)

        for x in range_x:
            for y in range_y:
                idx_image += 1
                if save_subimages and (np.count_nonzero(img_original[y:(y + y_height), x:(x + x_width)]) > mask_area_threshold):
                    print ("saving image %d/%d" %(idx_image, n_x*n_y))
                    (idx_x, idx_y) = np.unravel_index(idx_image - 1, (n_y, n_x))
                    level = 3
                    x0 = bounds_x + (4**level)*x # top-left corner of the image
                    y0 = bounds_y + (4**level)*y
                    rect=cv2.rectangle(img, (x,y), (x+x_width,y+y_height), (0,255,0), 4)
#                    figure(), imshow(rect)
#                    show()
                    cv2.imwrite(case_folder+'/'+str(i)+'/img_subrect_0.25.png',rect)
                    out_file = os.path.join(case_folder,str(i),"subimages/level0_crop_x%d_y%d.png" %(idx_x, idx_y))
                    command_write = [opslide_write_png_exe, path_image_scn, str(x0), str(y0), "0", str(x_width*(4**level)), str(y_height*(4**level)), out_file]
                    subprocess.Popen(command_write, shell = False).communicate() 
        with open(case_folder+'/index_information.txt','a+',encoding='utf-8') as b:
            dex_info=(str(i),f)
            index_info=":".join(dex_info)
            b.write(index_info+'\n')
            b.close()
        
        print ("finished!")
    else:
        print("original image don't match mask image!")
