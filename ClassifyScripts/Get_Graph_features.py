#!/usr/bin/env python
# coding: utf-8
# Author: Rudan XIAO

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

import skl_map as mp_
from skl_fgraph import skl_graph_t
import skimage.io as siio
from skl_graph import plot_mode_e
import matplotlib.pyplot as pl_
import numpy as np
import networkx as nx
import collections  

def listdir(path, list_name):  
    for file in os.listdir(path):  
        file_path = os.path.join(path, file)  
        if os.path.isdir(file_path):  
            listdir(file_path, list_name)  
        else:  
            list_name.append(file_path)

def main():
    root_folder = r'D:/test_vascular_mask/test'
    
    file_png = []
    slice_num=[]
    case_folder = os.path.join(root_folder+'/skel/')  
    for file in os.listdir(case_folder):  
        file_path = os.path.join(case_folder, file)  
        if os.path.isdir(file_path):  
            listdir(file_path, file_png)  
        else:  
            file_png.append(file_path)
            slice_num.append(len(file_path))

    label_lists = []
    for k in file_png:    
        label_str = k.split("/")[4].split("_")[0].rstrip("RCC")
        label = 1 if label_str == "cc" else 2
        label_lists.append(label)
    print(label_lists)
    with open(root_folder+'/SKEL_graph_features_test/'+"SKEL_graph_labels.txt", "a+") as doc_accessor:
        for label_list in label_lists:
            doc_accessor.write(f"{label_list}\n")

    root_folder = r'D:/test_vascular_mask/test'
    
    file_png = []
    slice_num=[]
    case_folder = os.path.join(root_folder+'/skel/')  
    for file in os.listdir(case_folder):  
        file_path = os.path.join(case_folder, file)  
        if os.path.isdir(file_path):  
            listdir(file_path, file_png)  
        else:  
            file_png.append(file_path)
            slice_num.append(len(file_path))
    print(file_png)

    list_node=[1]
    for s,f in enumerate(file_png):
        print ("analysis image %d : %s" %(s, f))
        img = siio.imread(f)
        skl_map, skl_width = mp_.SKLMapFromObjectMap(img)
        mp_.CheckSkeletonMap(skl_map, check_validity="multi")
        skl_graph = skl_graph_t.FromSKLMap(skl_map, width=skl_width)
        A = nx.adjacency_matrix(skl_graph)
        adjacency = A.A
        adjacency = np.logical_or(adjacency, adjacency.T).astype(np.uint8)
        edges = np.nonzero(adjacency)
        edges = np.array(edges).T
        list_node.append(len(unique(edges[:,0])))
        edges = edges + sum(list_node[:-1])
        print(list_node)
        print(skl_graph.n_nodes)
    
        nodes_num = list_node[s+1]
        graph_labels = [s+1] * nodes_num
        print(nodes_num)

        my_list = edges[:,0] 
    
        print(len(unique(my_list)))
        ctr = collections.Counter(my_list)  
        node_labels = ctr.values()
        

        with open(root_folder+'/SKEL_graph_features_test/'+"SKEL_A.txt", "a+") as doc_accessor:
            for edge in edges:
                doc_accessor.write(f"{edge[1]:5},{edge[0]:5}\n")

            
        with open(root_folder+'/SKEL_graph_features_test/'+"SKEL_graph_indicator.txt", "a+") as doc_accessor:
            for graph_label in graph_labels:
                doc_accessor.write(f"{graph_label}\n")

        with open(root_folder+'/SKEL_graph_features_test/'+"SKEL_node_labels.txt", "a+") as doc_accessor:
            for node_label in node_labels:
                doc_accessor.write(f"{node_label}\n")

if __name__ == "__main__":
    main()
