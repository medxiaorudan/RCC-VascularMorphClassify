# Extract low resolution images from a .scn (Leica) file.
# change accordingly:
    # - path to data
    # - path to (and name of) openslide binaries
    # - resolution level desired



from __future__ import division
import os
import subprocess

def is_number(s): # check whether a character is a number
    try:
        float(s)
        return True
    except ValueError:
        return False

# get image path
#~ main_histo_data = r'C:\Users\Rita Simoes\Documents\Data\histo_kidney\Lame virtuelle\10.08.2014'
main_histo_data = r'D:\Doctoral_Programs\RCC\data'
#~ case_folder = os.path.join(main_histo_data,'hp09.5392') # folder with .scn file(s)
case_folder = os.path.join(main_histo_data,'test2')
file_scn = [f for f in os.listdir(case_folder) if '.scn' in f][0] #find .scn file
path_image_scn = os.path.join(case_folder,file_scn) # full path


# paths to openslide executables
#~ opslide_bin_folder = r'C:\Program Files\openslide-win64-20140125\bin'
#~ opslide_show_props_exe = os.path.join(opslide_bin_folder,'openslide-show-properties.exe')
#~ opslide_write_png_exe = os.path.join(opslide_bin_folder,'openslide-write-png.exe')
opslide_show_props_exe = r'D:/Doctoral_Programs/RCC/openslide-win64-20171122/bin/openslide-show-properties.exe'
opslide_write_png_exe = r'D:/Doctoral_Programs/RCC/openslide-win64-20171122/bin/openslide-write-png.exe'

# LEVEL 1 #######################################################################
level = 1

## Get image information (initial point (x,y); total size)

command_show = [opslide_show_props_exe, path_image_scn]
output = subprocess.check_output(command_show)
lines = output.splitlines()

bounds_x_field = [str(line) for line in lines if "openslide.bounds-x" in str(line)]
bounds_x = [char for char in bounds_x_field[0] if is_number(char)]
bounds_x = int("".join(bounds_x))

# print bounds_x
# print bounds_x_field

bounds_y_field = [str(line) for line in lines if "openslide.bounds-y" in str(line)]
bounds_y = [char for char in bounds_y_field[0] if is_number(char)]
bounds_y = int("".join(bounds_y))

total_width_field = [str(line) for line in lines if "openslide.bounds-width" in str(line)]
total_width = [char for char in total_width_field[0] if is_number(char)]
total_width = int("".join(total_width))

total_height_field = [str(line) for line in lines if "openslide.bounds-height" in str(line)]
total_height = [char for char in total_height_field[0] if is_number(char)]
total_height = int("".join(total_height))


## Extract Level 1

size_x = int(total_width/(4**level)) # downsample 4^level from the highest resolution
size_y = int(total_height/(4**level))

out_file = os.path.join(case_folder,'level%d.png' % (level)) # change according to desired output folder

command_write = [opslide_write_png_exe, path_image_scn, str(bounds_x), str(bounds_y), str(level), str(size_x), str(size_y), out_file]
subprocess.Popen(command_write, shell = False).communicate()

# LEVEL 2 #######################################################################
level = 2

## Get image information (initial point (x,y); total size)

command_show = [opslide_show_props_exe, path_image_scn]
output = subprocess.check_output(command_show)
lines = output.splitlines()

bounds_x_field = [str(line) for line in lines if "openslide.bounds-x" in str(line)]
bounds_x = [char for char in bounds_x_field[0] if is_number(char)]
bounds_x = int("".join(bounds_x))

print (bounds_x)
print (bounds_x_field)

bounds_y_field = [str(line) for line in lines if "openslide.bounds-y" in str(line)]
bounds_y = [char for char in bounds_y_field[0] if is_number(char)]
bounds_y = int("".join(bounds_y))

total_width_field = [str(line) for line in lines if "openslide.bounds-width" in str(line)]
total_width = [char for char in total_width_field[0] if is_number(char)]
total_width = int("".join(total_width))

total_height_field = [str(line) for line in lines if "openslide.bounds-height" in str(line)]
total_height = [char for char in total_height_field[0] if is_number(char)]
total_height = int("".join(total_height))


## Extract Level 2

size_x = int(total_width/(4**level)) # downsample 4^level from the highest resolution
size_y = int(total_height/(4**level))

out_file = os.path.join(case_folder,'level%d.png' % (level)) # change according to desired output folder

command_write = [opslide_write_png_exe, path_image_scn, str(bounds_x), str(bounds_y), str(level), str(size_x), str(size_y), out_file]
subprocess.Popen(command_write, shell = False).communicate()


# LEVEL 3 #######################################################################
level = 3

## Get image information (initial point (x,y); total size)

command_show = [opslide_show_props_exe, path_image_scn]
output = subprocess.check_output(command_show)
lines = output.splitlines()

bounds_x_field = [str(line) for line in lines if "openslide.bounds-x" in str(line)]
bounds_x = [char for char in bounds_x_field[0] if is_number(char)]
bounds_x = int("".join(bounds_x))

print (bounds_x)
print (bounds_x_field)

bounds_y_field = [str(line) for line in lines if "openslide.bounds-y" in str(line)]
bounds_y = [char for char in bounds_y_field[0] if is_number(char)]
bounds_y = int("".join(bounds_y))

total_width_field = [str(line) for line in lines if "openslide.bounds-width" in str(line)]
total_width = [char for char in total_width_field[0] if is_number(char)]
total_width = int("".join(total_width))

total_height_field = [str(line) for line in lines if "openslide.bounds-height" in str(line)]
total_height = [char for char in total_height_field[0] if is_number(char)]
total_height = int("".join(total_height))


## Extract Level 3

size_x = int(total_width/(4**level)) # downsample 4^level from the highest resolution
size_y = int(total_height/(4**level))

out_file = os.path.join(case_folder,'level%d.png' % (level)) # change according to desired output folder

command_write = [opslide_write_png_exe, path_image_scn, str(bounds_x), str(bounds_y), str(level), str(size_x), str(size_y), out_file]
subprocess.Popen(command_write, shell = False).communicate()
