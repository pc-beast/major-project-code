% fc = 1575.42*10^6; % frequency of gps signal
fc=1e9;
c = 3*10^8;
lambda = c/fc;

array = phased.ULA('NumElements',10,'ElementSpacing',lambda/2);
array.Element.FrequencyRange = [8e8 1.2e9];
% 
% 
% t = linspace(0,0.3,300)';
% testsig = zeros(size(t));
% testsig(201:205) = 1;
% 
% 
angle_of_arrival = [80 90 100 120;0 0 0 0];
% x = collectPlaneWave(array,testsig,angle_of_arrival,fc);
% 
% 
convbeamformer = phased.PhaseShiftBeamformer('SensorArray',array,...
    'OperatingFrequency',1e9,'Direction',angle_of_arrival,...
    'WeightsOutputPort',true);
% 
% rng default
% npower = 0.5;
% x = x + sqrt(npower/2)*(randn(size(x)) + 1i*randn(size(x)));
% 
jamsig = sqrt(10)*randn(300,1);
jammer_angle = [0;0];
jamsig = collectPlaneWave(array,jamsig,jammer_angle,fc);

noisePwr = 1e-5;
rng(2008);
noise = sqrt(noisePwr/2)*...
    (randn(size(jamsig)) + 1j*randn(size(jamsig)));
jamsig = jamsig + noise;
% rxsig = x + jamsig;
rxsig = get_signal();
[yout,w] = convbeamformer(rxsig');

steeringvector = phased.SteeringVector('SensorArray',array,...
    'PropagationSpeed',physconst('LightSpeed'));
LCMVbeamformer = phased.LCMVBeamformer('DesiredResponse',1,...
    'TrainingInputPort',true,'WeightsOutputPort',true);
LCMVbeamformer.Constraint = steeringvector(fc,angle_of_arrival);
LCMVbeamformer.DesiredResponse = 4;
[yLCMV,wLCMV] = LCMVbeamformer(rxsig',jamsig);

subplot(211)
plot(t,abs(yout))
axis tight
title('Conventional Beamformer')
ylabel('Magnitude')
subplot(212)
plot(t,abs(yLCMV))
axis tight
title('LCMV (Adaptive) Beamformer')
xlabel('Seconds')
ylabel('Magnitude')


%%
subplot(211)
pattern(array,fc,[-180:180],0,'PropagationSpeed',physconst('LightSpeed'),...
    'CoordinateSystem','rectangular','Type','powerdb','Normalize',true,...
    'Weights',w)
title('Array Response with Conventional Beamforming Weights');
subplot(212)
pattern(array,fc,[-180:180],0,'PropagationSpeed',physconst('LightSpeed'),...)
    'CoordinateSystem','rectangular','Type','powerdb','Normalize',true,...
    'Weights',wLCMV)
title('Array Response with LCMV Beamforming Weights');
