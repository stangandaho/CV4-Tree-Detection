from pathlib import Path
import shutil

# Set path
img_path = [img.name for img in Path("cropped").glob("*.tif")]
mask_path = [img.name for img in Path("mask").glob("*.tif")]
# Create a directory where to store romed image
Path("removed").mkdir(exist_ok=True)

for img in img_path:
    if not img in mask_path:
        shutil.copy(src=str(f"cropped/{img}"), dst=f"removed/{img}")
        Path(f"cropped/{img}").unlink()


