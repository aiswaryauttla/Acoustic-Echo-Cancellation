%% DSP Lab: AEC with correlation-based double-talk detector

close all
clear

%% Parameters

% 0 = no double talk, 1 = double talk
flagDT = 1;

% signal duration (in seconds)
duration = 20;

% regularization for ERLE computation
deltaERLE = eps;

% LMS algorithm parameters
filterLength = 2001; % length of the adaptive filter
mu = 0.1; % LMS algorithm step size
delta = 1e-6; % regularization constant for normalization


%% Load and preprocess audio signals
% Load recorded signals
[x,fs] = audioread('G:\smester 1\DSP_Lab_Project_AEC\DSP_Lab_Project_AEC\Data\playback_tvaudio.wav');
[y_far,fs] = audioread('G:\smester 1\DSP_Lab_Project_AEC\DSP_Lab_Project_AEC\Data\recorded_echo.wav');
Ir=load('G:\smester 1\DSP_Lab_Project_AEC\DSP_Lab_Project_AEC\Data\IR.mat');
% Limit signal duration
x = x(1:duration*fs);
y_far = y_far(1:duration*fs);

% If desired, add a double-talk speaker; Near-end speaker is active only in
% range [90000;208000] samples (5.625s to 13s) (chosen arbitrarily)
y_near = zeros(duration*fs,1);
if flagDT
    [tmp,fs] = audioread('Data/speech.wav');
    
    y_near(90000:208000) = tmp(90000:208000);
    
end

% Microphone signal is the superposition of near-end and far-end contributions
y = y_far + y_near;



%% Reference DTD based on ground-truth
flagAdaptRef = true(length(x),1);
flagAdaptRef(90000:208000) = false;


%% LMS algorithm
% coefficients of the adaptive filter
h_hat = zeros(filterLength,1);

% block of input samples used for convolution
xb = zeros(filterLength,1);

% estimated microphone signal (output of the adaptive filter)
y_hat = zeros(size(y));

% error signal (ideally should contain only near-end signal)
e = zeros(size(y));

% binary flag, whether to adapt filter or not
flagAdapt = logical(size(y));

for k = 1:length(x)
    
    % Block extraction (beware order of samples!)
    xb = [x(k); xb(1:end-1)]; % used for filtering, "reversed" time axis
    
    % Filtering
    y_hat(k) = xb.' * h_hat;
    
    % Error signal
    e(k) = y(k) - y_hat(k);
   
    % Adaptation control
      
%     flagAdapt(k) = flagAdaptRef(k); % ideal DTD based on prior knowledge (not available in practice!)

    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %closed loop correlation between microphone signal and the estimated
    %signal y_hat
    % 
  

if k<2000
            pcl(k)=1;
else
    
        den =0;
        num=0;
        for t=0:2000
            if(k-t>0)
            num = num + y_hat(k-t)*y(k-t);
            den = den + abs(y_hat(k-t)*y(k-t));
            
            end   
            
       end
  
     num = abs(num);
        pcl(k) = num/den;
        
end
 
  % open loop correlation between loudspeaker signal and microphone signal  
      
         num1=0;
       den1=0;

     for l=1:350 
            
         for n=0:2000
            if(k-n-l>0)
          den1 = den1 + abs(x(k-n-l)*y(k-n));
          num1 = num1 + x(k-n-l)*y(k-n);
        
            end
         
         end
       num1 = abs(num1);
            p(l)=num1/den1;
              
      end
      
            pol(k)=max(p);
      
% Adaptation Control and NLMS Implementation

            if pcl(k)>0.98 || pol(k)>0.85
                
            flagAdapt(k)=true;
              delta_h_hat = (e(k) * xb) ./ ( (xb' * xb) + delta);
              h_hat = h_hat + mu * flagAdapt(k) * delta_h_hat; 
             end  
               
end    
            
         
    figure(3);
    plot(pcl);
    title('Closed loop graph');
    figure(4);
    plot(pol);
    title('Open loop graph');

r = y_far - y_hat;

% Echo Return Loss Enhancement (ERLE), temporally smoothed
ERLE = conv(abs(y_far).^2, 1./1024 * ones(1024,1),'same') ./ ...
    (conv(abs(r).^2, 1./1024 * ones(1024,1),'same') + deltaERLE);


%% Visualization
% ERLE over time
figure(1);
plot(10*log10(ERLE));
grid on;
title('Echo Return Loss Enhancement (ERLE)');
xlabel('sample index');
ylabel('ERLE [dB]');


% Signal waveforms
figure(2);
subplot(4,1,1);
plot(y_far);
title('far-end signal (echo)');

subplot(4,1,2);
plot(y_near);
title('near-end signal (local speaker)');

subplot(4,1,3);
plot(y);
title('microphone signal');

subplot(4,1,4);
hold off;
plot(e);
hold on;
plot(r);
title('error signal with adaptation control');

linkaxes();

%% Write audio files
audiowrite('signal_near.wav',y_near,fs);
audiowrite('signal_far.wav',y_far,fs);
audiowrite('signal mic.wav',y,fs);
audiowrite('signal_err.wav',e,fs);
audiowrite('signal_res.wav',r,fs);