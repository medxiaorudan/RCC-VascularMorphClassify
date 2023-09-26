Skel2Graph3D: calculate the network graph of a 3D skeleton

This function converts a 3D binary voxel skeleton into a network graph described by nodes and edges.

The input is a 3D binary image containing a one-dimensional voxel skeleton, generated e.g. using the "Skeleton3D" thinning function available on MFEX. The output is the adjacency matrix of the graph, and the nodes and links of the network as MATLAB structure. 

Note that the boundary layer of the skeleton is converted to zeros before calculating the graph.

Usage:

[A,node,link] = Skel2Graph(skel,THR),

where "skel" is the input 3D binary image, A is the adjacency matrix, and node/link are the structures describing node and link properties.

The only parameter "THR" is a threshold for the minimum length of branches (edges that do not end at another node), to filter out skeletonization artifacts.

A second function, "Graph2Skel3D.m", converts the network graph back into a cleaned-up voxel skeleton image.

An example of how to use these functions is given in the script "Test_Skel2Graph3D.m", including a test image. In this example, it is also demonstrated how to iteratively combine both conversion functions in order to obtain a completely cleaned skeleton graph.

Any comments, corrections or suggestions are highly welcome. If you include this in your own work, please cite our original publicaton [1].

Philip Kollmannsberger 09/2013
philipk@gmx.net

[1] Kerschnitzki, Kollmannsberger et al.,
"Architecture of the osteocyte network correlates with bone material quality."
Journal of Bone and Mineral Research, 28(8):1837-1845, 2013.
