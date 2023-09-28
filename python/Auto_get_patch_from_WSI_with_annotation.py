#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Thu Dec  5 15:06:38 2019

@author: Rudan XIAO
"""
from __future__ import division
import os
import subprocess
#import cv2
#from xml.etree.ElementTree import parse
import numpy as np
#from PIL import Image
#import multiresolutionimageinterface as mir 
#import openslide
import matplotlib.pyplot as plt 
from xml.etree import ElementTree as ET
import skimage
import skimage.io
import skimage.exposure
import skimage.filters
from pylab import *
#==============================================================================
# define a few functions
#==============================================================================
#def is_number(s): # check whether a character is a number
#    try:
#        float(s)
#        return True
#    except ValueError:
#        return False

#def location_and_capture(search_str,full_context):
#    location=re.search(search_str,full_context)  #return a match object
#    span=location.span()
#    start,end=span
#    capture_content=full_context[end+2:end+11]
#    return capture_content

#==============================================================================
# define a few parameters
#==============================================================================

#==============================================================================
RIGHT = "RIGHT" 
LEFT = "LEFT" 

def inside_convex_polygon(point, vertices): 
    previous_side = None 
    n_vertices = len(vertices) 
    for n in range(n_vertices): 
     a, b = vertices[n], vertices[(n+1)%n_vertices] 
     affine_segment = v_sub(b, a) 
     affine_point = v_sub(point, a) 
     current_side = get_side(affine_segment, affine_point) 
     if current_side is None: 
      return False #outside or over an edge 
     elif previous_side is None: #first segment 
      previous_side = current_side 
     elif previous_side != current_side: 
      return 0 
    return 1 

def get_side(a, b): 
    x = x_product(a, b) 
    if x < 0: 
     return LEFT 
    elif x > 0: 
     return RIGHT 
    else: 
     return None 

def v_sub(a, b): 
    return (a[0]-b[0], a[1]-b[1]) 

def x_product(a, b): 
    return a[0]*b[1]-a[1]*b[0] 
#==============================================================================



x_width = 2000
y_height = 2000
x_overlap = 100
y_overlap = 100
save_subimages = True

#mask_area_threshold = 0.25 * x_width * y_height
# image folder
case_folder = r'D:/Doctoral_Programs/RCC/orignal_data/pre/pRCC/'
opslide_show_props_exe = r'D:/Doctoral_Programs/RCC/test_Alexis_coding/openslide-win64-20171122/bin/openslide-show-properties.exe'
opslide_write_png_exe = r'D:/Doctoral_Programs/RCC/test_Alexis_coding/openslide-win64-20171122/bin/openslide-write-png.exe'

# Look for .scn files
file_scn = [f for f in os.listdir(case_folder) if '.scn' in f] #find .scn file

for i, f in enumerate(file_scn):
    path_image_scn = os.path.join(case_folder,f) # full path
    
#==============================================================================
# get xml info
#==============================================================================
    
    xml_name=f.split('.scn')[0]
    if xml_name==f.split('.scn')[0]:               
        root = ET.parse(os.path.join(case_folder,xml_name+'.xml')).getroot()
        result_coordinate = {}
        groups=['necrosis','fiber','tumor','normal']
        
        num_groups = {'necrosis':0,'fiber':0,'tumor':0,'normal':0}
        list_name = {'necrosis':[],'fiber':[],'tumor':[],'normal':[]}

        for Annotations in root:
            for Annotation in Annotations:
                for j in range(4):
                    if Annotation.attrib['PartOfGroup']==groups[j]:
                        num_groups[groups[j]]=num_groups[groups[j]]+1
                        list_name[groups[j]].append(Annotation.attrib['Name'])
                        
        for Annotations in root:
            for m in range(len(groups)):
                list_all={}
                for Annotation in Annotations:
                        #print (Annotation.tag)
                    # print(list_all) 
                    if Annotation.attrib['PartOfGroup']==groups[m]:
                        for n in range(num_groups[groups[m]]):
                            if Annotation.attrib['Name']==list_name[groups[m]][n]:
                                print (list_name[groups[m]][n])
                                _list_=[]
                                # print (Annotation.attrib['PartOfGroup'])
                                for Coordinates in Annotation:
                                    for Coordinate in Coordinates:
                                        _list_.append([float(Coordinate.get('X')),float(Coordinate.get('Y'))])
                                #print(_list_)
                                    list_all[list_name[groups[m]][n]]=_list_
                        result_coordinate[groups[m]]=list_all
    # print (len(result_coordinate['necrosis']))
                   
#==============================================================================
# get coordinate info from xml
#==============================================================================        
        name_list=[]
        for name in result_coordinate:
            name_list.append(name)
                        
        x={}
        y={}
        
        for idx in range(len(name_list)):
            Max_x=[]
            Max_y=[]
            for r in range(num_groups[name_list[idx]]):
                __x__=[]
                __y__=[]
                for s in range(len(result_coordinate[name_list[idx]][list_name[name_list[idx]][r]])):
                    __x__.append(result_coordinate[name_list[idx]][list_name[name_list[idx]][r]][s][0])
                    __y__.append(result_coordinate[name_list[idx]][list_name[name_list[idx]][r]][s][1])
                max_x=max(__x__)
                max_y=max(__y__)
                min_x=min(__x__)
                min_y=min(__y__)
                Max_x.append([max_x,min_x])
                Max_y.append([max_y,min_y])
                #if name_list[idx]=='tumor':
                #    break
            x[name_list[idx]]=Max_x
            y[name_list[idx]]=Max_y
#==============================================================================
# Create the needed folders if they do not exist
#==============================================================================
        
        for idx in name_list:
            for p in range(num_groups[idx]):
                if save_subimages:
                    subimages_folder = os.path.join(case_folder,str(i),str(idx),str(list_name[idx][p])+"\subimages")
                    skeletons_folder = os.path.join(case_folder,str(i),str(idx),str(list_name[idx][p])+"\skeletons")
                    overlays_folder = os.path.join(case_folder,str(i),str(idx),str(list_name[idx][p])+"\overlays")
                    # print(subimages_folder)
                    if not os.path.exists(subimages_folder):
                        os.makedirs(subimages_folder)
                    if not os.path.exists(skeletons_folder):
                        os.makedirs(skeletons_folder)
                    if not os.path.exists(overlays_folder):
                        os.makedirs(overlays_folder)
                    
#==============================================================================
#save the subimages
#==============================================================================
        #print ('x:',x)
        #print ('y:',y)    
        for idx_i in range(len(name_list)):
            for k in range(num_groups[name_list[idx_i]]):
                print ("saving the subimages:",[name_list[idx_i]])

                idx_image = 0
                
                # Subsample the main image
                range_x = range(int(float(x[str(name_list[idx_i])][k][1])), int(float(x[str(name_list[idx_i])][k][0])), x_width - x_overlap)
                n_x = size(range_x)
                range_y = range(int(float(y[str(name_list[idx_i])][k][1])), int(float(y[str(name_list[idx_i])][k][0])), y_height - y_overlap)
                n_y = size(range_y)
            
                for x0 in range_x:
                    for y0 in range_y:
                        idx_image += 1
                        if save_subimages:
                            print ("saving image %d/%d" %(idx_image, n_x*n_y))
                            (idx_x, idx_y) = np.unravel_index(idx_image-1, (n_y, n_x))
                            out_file = os.path.join(case_folder,str(i),str(name_list[idx_i]),str(list_name[name_list[idx_i]][k])+"\subimages\crop_x%d_y%d.png" %(idx_x, idx_y))
                            points=[[x0,y0],[x0+x_width,y0],[x0+x_width,y0+y_height],[x0,y0+y_height]]
                            num_interieur=0
                            for point in points:
                                #print (point)
                                #print (inside_convex_polygon(point,result_coordinate[name_list[idx]][list_name[name_list[idx]][k]]))
                                if inside_convex_polygon(point,result_coordinate[name_list[idx_i]][list_name[name_list[idx_i]][k]]) ==1:
                                    num_interieur=num_interieur+1
                            # print(num_interieur)
                            if num_interieur>0:
                                print (str(name_list[idx_i]),str(list_name[name_list[idx_i]][k]),num_interieur)
                                #print(str(x0), str(y0))
                                command_write = [opslide_write_png_exe, path_image_scn, str(x0), str(y0), "0", str(x_width), str(y_height), out_file]
                                subprocess.Popen(command_write, shell = False).communicate() 
                                

#==============================================================================
#save sample index file
#==============================================================================

        with open(case_folder+'/index_information.txt','a+',encoding='utf-8') as b:
            dex_info=(str(i),f)
            index_info=":".join(dex_info)
            b.write(index_info+'\n')
            b.close() 




































