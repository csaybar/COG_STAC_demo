import rasterio as rio
from matplotlib import pyplot as plt
from rasterio import features

fp = "http://storage.googleapis.com/rgee_dev/stac_demo/s2_COGdemo.tif"
#rasterio.windows.Window(col_off, row_off, width, height)
window = rio.windows.Window(1024, 1024, 1280, 2560)

with rio.open(fp) as src:
    subset = src.read(1, window=window)

plt.figure(figsize=(6,8.5))
plt.imshow(subset)
plt.colorbar(shrink=0.5)
plt.title(f'Band 4 Subset\n{window}')
plt.xlabel('Column #')
plt.ylabel('Row #')
plt.show()
