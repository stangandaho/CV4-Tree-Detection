from matplotlib import pyplot as plt
import numpy as np

oned = np.array(
    [[[0, 2, 2],
     [2, 3, 1],
     [2, 0, 0]],

     [[0, 2, 2],
     [2, 7, 1],
     [2, 0, 0]]]
    )

plt.imshow(oned)
plt.show()