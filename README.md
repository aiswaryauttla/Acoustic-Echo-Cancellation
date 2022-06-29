# Acoustic-Echo-Cancellation

Acoustic echo cancellers is based on adaptive appproximation of the echo path. However, the adaptive filter faces the risk of divergence during Double-Talk periods when both echo and near end signal are present. So, the filter adaptation should be stopped during this period. Hence there is need for Double-Talk Detection (DTD) algorithm. Regularized Normalized Least Mean Square (NLMS) algorithm is used to generate the coefficients of the adaptive filter. To have a control over the filter adaptation double talk detector using cross correlation is used to extract the local speech signal.

![image](https://user-images.githubusercontent.com/80693116/176561326-aaf84a86-7182-4b9e-a820-e44cf9596531.png)

