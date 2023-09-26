# Steps for Generating Sub_Images

## 1. Marking Areas

- Use ASAP software to mark areas about tumor and non-tumor (necrosis, fiber, normal). Each selected area corresponds to an annotation; the number of the annotation has no relationship with the size and position of the selected area.
![image](https://github.com/medxiaorudan/RCC-VascularMorphClassify/assets/22127304/8e4220e5-67cc-484b-b855-70faf2a5becc)

## 2. Saving Mark Results

- Save the mark result as an XML file, which contains the edge coordinates of each marked area.
- ![image](https://github.com/medxiaorudan/RCC-VascularMorphClassify/assets/22127304/d1b523d1-2719-4676-bfb5-c2be00fc0295)

## 3. Obtaining Sub_Images

- Use the steps in the figure below to obtain the sub_images of each histopathological section.
![image](https://github.com/medxiaorudan/RCC-VascularMorphClassify/assets/22127304/438303c5-8e1f-495d-842b-405290055603)

# About Names of Folders and Files

## 1) First-Level Folder

- The first folder is named with numbers. The original whole slide image's name is too long and irregular, so I replaced the original film name with its four index values. The other numbers in the file represent the number of sub_images.
- Explanation of the original whole slide images name: Take `HP19.10064.A6.ccRCC.scn` as an example:
  - `HP19` represents the patient's admission time.
  - `10064` is the patient number.
  - `A6` is the patient's histopathological section number.
  - `ccRCC` is the disease type.
  - `scn` is the file type suffix.
  - Therefore, `HP19.10064.A6.ccRCC.scn` and `HP19.10064.A7.ccRCC.scn` are different histopathological slices belonging to the same patient.

## 2) Second-Level Folder

- The second-level folder names represent four categories: tumor and non-tumor (necrosis, fiber, normal). However, not all WSIs contain these four categories, and some include only one or a few.

## 3) Third-Level File

- The third layer file named `Annotation` represents the selected area. The number of `Annotation` represents the number of selected ROI areas.

## 4. Fourth Layer File

- The fourth layer file ‘subimages’ contains the sub_images you need. Under the tumor folder, you will find two folders ‘skeletons’ and ‘overlays’. Those are the folders used to save extracted the skeleton.

## 5. Picture Naming

- For the naming of the picture, take ‘crop_xi_yj.png’ as an example. This naming is not essential. This is automatically generated when traversing the selected area. You can change it to any name according to your needs.

# The Data Structure

- **Index Number of the Patient**
  - **Categories (e.g., tumor, necrosis, fiber, normal)**
    - **Annotation**
      - **subimages**
        - `crop_xi_yj.png`
        - `... (other images)`
      - **skeletons**
      - **overlays**
    - `... (other Annotations)`
  - `... (other Categories)`
- `... (other First-Level Folders with the index number of the patient)`
