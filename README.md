# Acoustic-Echo-Cancellation

Acoustic echo cancellers is based on adaptive appproximation of the echo path. However, the adaptive filter faces the risk of divergence during Double-Talk periods when both echo and near end signal are present. So, the filter adaptation should be stopped during this period. Hence there is need for Double-Talk Detection (DTD) algorithm. Regularized Normalized Least Mean Square (NLMS) algorithm is used to generate the coefficients of the adaptive filter. To have a control over the filter adaptation double talk detector using cross correlation is used to extract the local speech signal.

![image](https://user-images.githubusercontent.com/80693116/176561602-96576d0b-aa4c-4a57-9b15-13f678767fec.png)

For evaluating the system performance, we generate several microphone signals with occurence of local speech signal at various instants after system initialization. We use metrics like system echo return loss enhancement in addition to simple auditory listening of the obtained error signal. In addition, we also view the normalised correlation of the open loop and closed loop methods.



