import numpy as np
import cv2 as cv
from pathlib import Path
import re

## Define directory
mask_dir = "mask"
mask_txt_dir = "mask_txt"
Path(mask_txt_dir).mkdir(exist_ok=True)

file_number = 0; total_file = len(list(Path(mask_dir).glob("*.tif")))
for msk in Path(mask_dir).glob("*.tif"):
    file_number += 1
    print(f"On mask {file_number}/{total_file}")
    mask_file = str(msk)
    txt_file = str(Path(mask_txt_dir,  Path(mask_file).stem + ".txt"))
    
    single_img = cv.imread(mask_file, cv.IMREAD_UNCHANGED)
    # Update nan to 0
    single_img[np.isnan(single_img)] = 0
    ## Force binary format to BGR
    gray_image = cv.cvtColor(single_img.astype(np.uint8), cv.COLOR_GRAY2BGR)
    ## From BGR to grayscale
    gray_image = cv.cvtColor(gray_image, cv.COLOR_BGR2GRAY)
    # Apply threshold
    thres, img = cv.threshold(gray_image, 0 , 1, cv.THRESH_BINARY)
    ## Fun coontours
    outlines, _ = cv.findContours(img, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)
    # Retrive image height and width of image
    img_height = img.shape[0]; img_width = img.shape[1]
    outl = 0

    for otl in outlines:
        outl += 1
        number_of_point = len(otl)
        plg_list = []
        for pt in range(number_of_point):
            x = round(otl[pt][0][0]/img_width, 6)
            y = round(otl[pt][0][1]/img_height, 6)
            plg_list.append((x, y))
        plg_list.append((plg_list[0][0], plg_list[0][1])) # close with first point
        plg_str = f"0 {plg_list}"
        
        plg_str = re.sub(",|\\[|\\(|\\]|\\)", "", plg_str)+"\n"

        with open(txt_file, "a") as f:
            f.write(plg_str)


