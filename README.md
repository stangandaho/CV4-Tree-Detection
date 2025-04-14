# 🌳 Tree Segmentation from Drone Imagery using YOLO

This project leverages drone imagery and a YOLO-based segmentation model to detect and annotate tree locations. The pipeline processes high-resolution mosaic images into structured datasets ready for YOLO training, allowing for accurate tree detection and segmentation.

## 📌 Workflow Summary

1. **Image Tiling**: Large mosaic images are split into smaller tiles (10×10 per large image).

2. **Mask Generation**: Binary masks are created for each tile to detect the presence of trees.

3. **Coordinate Extraction**: Tree presence in the masks is translated into coordinates for YOLO annotation format.

4. **Image Filtering & Conversion**: Only tiles containing trees are kept and converted into JPEG format.

5. **YOLO Directory Setup**: Data is organized into a standard YOLO structure with `images/train`, `labels/train`, etc.

6. **Model Training**: A pre-trained segmentation model (`yolov11n-seg.pt`) is fine-tuned over 120 epochs for tree segmentation.

## 🗂️ Project Structure

```
scripts/
│
├── 01_images_cropping.R         # Splits mosaics into 10x10 tiles
├── 02_make_mask.R               # Creates binary tree masks
├── 03_delineation.py            # Extracts tree coordinates from masks
├── 04_remove_empty_images.py    # Filters out tiles with no trees
├── 05_to_jpeg.py                # Converts image tiles to JPEG
├── 06_yolo_dir_architector.py   # Creates YOLO-compliant directory structure
├── 07_predict.py                # Performs segmentation using YOLO model
```

## 🧪 Requirements
Make sure the requierements are installed:
- Python 3.8+
- R (for running the `.R` scripts)

Install Python dependencies:

```bash
pip install -r requirements.txt
```

## 💻 Training in Google Colab

The model was trained using Google Colab with a free T4 GPU. The notebook can be accessed [here](https://colab.research.google.com/drive/1yaLMNFknULmYvejrNa8PprN-dFlgpbtz?usp=sharing). After mounting Google Drive and navigating to the project folder, required libraries (`ultralytics`, `rasterio`) were installed, and the model was trained with `yolo11n-seg.pt` for 120 epochs. Ensure paths in `treeseg.yaml` are updated to match your Drive directory (e.g., `/gdrive/MyDrive/CV4 Tree detection`).