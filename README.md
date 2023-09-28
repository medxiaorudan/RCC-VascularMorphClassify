# RCC-VascularMorphClassify: Renal Cell Carcinoma Classification from Vascular Morphology (MICCAI 2021)
<a href="https://link.springer.com/chapter/10.1007/978-3-030-87231-1_59"><img src="https://img.shields.io/badge/link.springer-10.1007-%23B31B1B"></a>
<a href="https://drive.google.com/file/d/14B3B8v7sqBfjbbfv0JRBoDAwEvked1v4/view?usp=drive_link"><img src="https://img.shields.io/badge/Poster%20-online-brightgreen"></a>
<a href="https://drive.google.com/file/d/14HVZhJHgCjXJv8ckNz6lYVOBwBU_vMzA/view?usp=drive_link"><img src="https://img.shields.io/badge/Presentation%20-online-brightgreen"></a>
<br>

<center>
<img src="https://github.com/medxiaorudan/RCC-VascularMorphClassify/blob/main/images/classification_pipeline.png" width="700" > 
</center>

This is the official implementation of the paper "Renal Cell Carcinoma Classification from Vascular Morphology" with hybrid codes. The Python code is mainly used to obtain patch images, graph feature extraction, and machine learning classification, while the Matlab code is mainly used to extract the manual features we proposed.

## Introduction
We present the first work to investigate the importance of geometric and topological properties of the vascular network for Renal Cell Carcinoma (RCC) classification. Our proposed two sets of hand-crafted features, skeleton, and lattice features, which are extracted from the vascular network segmentation images, can classify RCC subtypes robustly.

## Data preparation and hand-crafted features extraction
<p float="left">
  <img src="https://github.com/medxiaorudan/RCC-VascularMorphClassify/blob/main/images/HandCraftedFeatures_extraction.png" width="700" />
</p>
The data preparation steps can be found in [K-planes](https://github.com/sarafridov/K-Planes)
[Steps for Generating Sub_Images](https://github.com/medxiaorudan/RCC-VascularMorphClassify/blob/main/Data_preparation_and_folder_structure.md)

Get patch ```subimages``` with anotations
```
python python/Auto_get_patch_from_WSI_with_annotation.py
```

Convert ```Vascular mask``` into the ```skeleton```
```
run matlab/mask2skel.m
```

Extract ```Hand-crafted features```
```
run matlab/collect_data_from_skeleton.m
```

## Graph features extraction


## Features classification


## Citation
If you use this work, please cite our paper:
```
@inproceedings{xiao2021renal,
  title={Renal cell carcinoma classification from vascular morphology},
  author={Xiao, Rudan and Debreuve, Eric and Ambrosetti, Damien and Descombes, Xavier},
  booktitle={Medical Image Computing and Computer Assisted Intervention--MICCAI 2021: 24th International Conference, Strasbourg, France, September 27--October 1, 2021, Proceedings, Part VI 24},
  pages={611--621},
  year={2021},
  organization={Springer}
}
```
