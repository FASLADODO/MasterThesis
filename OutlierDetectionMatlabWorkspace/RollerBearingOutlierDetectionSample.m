%% Support Vector Data Description (SVDD) of Roller Bearing time series
% Detection of Outliers in Rolling Element Bearing Datasets using Support
% Vector Data Description
%% SVDD sample
% Creates a banana-shaped one-class dataset and calculates three different
% SVDD mappings with Radial Basis Functions with different Sigma values (1)
a = gendatb([30 30]);
% Setting of the second class as target class
a = oc_set(a,'1');
a = target_class(a);
% Generation of test data
b = oc_set(gendatb(200),'1');
V = axis; axis(1.5*V);
% Training of three SVDDs
H=[0;0];
fracrej = 0.2;
figure(1); clf; hold on;
s=scatterd(a);
w1 = svdd(a,fracrej,2);
h=plotc(w1,'k--');
H(1)=s;
H(2)=h;
legend(H,'Target Data','SVDD with RBF, Sigma=2');
hold off;
figure(2); clf; hold on;
s=scatterd(a);
w2 = svdd(a,fracrej,3);
h=plotc(w2,'k--');
H(1)=s;
H(2)=h;
legend(H,'Target Data','SVDD with RBF, Sigma=3');
hold off;
figure(3); clf; hold on;
s=scatterd(a);
w3 = svdd(a,fracrej,5);
h=plotc(w3,'k--');
H(1)=s;
H(2)=h;
legend(H,'Target Data','SVDD with RBF, Sigma=5');
axis equal;
axis image;
%% Preprocessing 
% Partitions Roller Bearing time signals into segments of 5 revolutions (2,3)
numberOfRevolutionsPerSegment=5;
rpm=1796;
sampleFrequency=48000;
normalSegments=SegmentRotationTimeSignal(...
    normalRawData1797rpm48k,...
    rpm,...
    sampleFrequency,...
    numberOfRevolutionsPerSegment); 
ballFaultSegments=SegmentRotationTimeSignal(...
    ballFaultRawData1797rpm48k,...
    rpm,...
    sampleFrequency,...
    numberOfRevolutionsPerSegment); 
innerRacewayFaultSegments=SegmentRotationTimeSignal(...
    innerRacewayFaultRawData1797rpm48k,...
     rpm,...
     sampleFrequency,...
     numberOfRevolutionsPerSegment); 
 outerRacewayFaultSegments=SegmentRotationTimeSignal(...
    outerRacewayRawData1797rpm48k,...
     rpm,...
     sampleFrequency,...
     numberOfRevolutionsPerSegment);
 
 numberOfDataPoints = size(normalSegments,1);
 deltaX = numberOfRevolutionsPerSegment/numberOfDataPoints;
 xScale = (0+deltaX):deltaX:numberOfRevolutionsPerSegment;
 
%Plots the first segment of each dataset
figure(1); clf;
subplot(4,1,1), 
    plot(xScale,normalSegments(:,1)),
    title('First five revolutions of Rolling Element Bearing Data')
    ylabel('Normal');
subplot(4,1,2), 
    plot(xScale,ballFaultSegments(:,1)),
    ylabel('Ball fault');
subplot(4,1,3), 
    plot(xScale,innerRacewayFaultSegments(:,1)),
    ylabel('IR fault');
subplot(4,1,4), 
    plot(xScale,outerRacewayFaultSegments(:,1));
    ylabel('OR fault');
    %% Feature Extraction
    % Extracts Kurtosis (k),Mel Frequency Cepstrum Coefficients (c) and Multifractal
    % Dimensions (m) as 27-tupels in the format (c1...c13,m1...,m13,k) (3)
    normalFeatures = ...
        ExtractRollerBearingFeatures(normalSegments, sampleFrequency);
    %First normal features vector:
    normalFeatures(1,:)
    ballFaultFeatures =...
        ExtractRollerBearingFeatures(ballFaultSegments,sampleFrequency);
    %First ball fault features vector
    ballFaultFeatures(1,:)
    innerRacewayFaultFeatures =...
        ExtractRollerBearingFeatures(innerRacewayFaultSegments,sampleFrequency);
    %First inner raceway fault features
    innerRacewayFaultFeatures(1,:)
    outerRacewayFaultFeatures=...
        ExtractRollerBearingFeatures( outerRacewayFaultSegments,sampleFrequency);
    %First outer raceway fault features
    outerRacewayFaultFeatures(1,:)
    %ToDo: PCA to remove redundancies in dataset
    
    %% Training and test set generation 
    % Creates a target dataset with normal features for training and a
    % dataset with target and outlier samples for testing a Support Vector
    % Data Description (1)
    normalFeaturesDataSet=dataset(normalFeatures);
    ballFaultFeaturesDataSet=dataset(ballFaultFeatures);
    innerRacewayFaultFeaturesDataset=dataset( innerRacewayFaultFeatures );
    outerRacewayFaultFeaturesDataset=dataset(  outerRacewayFaultFeatures);
    %Creates a target data training set with normal features
    targetData =...
        gendatoc(normalFeaturesDataSet);
    %Creates an outlier dataset with ball fault features
    ballFaultOutliers =...
        gendatoc([],  ballFaultFeaturesDataSet);
    %Creates an outlier dataset with inner raceway fault features
    innerRacewayFaultOutliers=...
        gendatoc([],  innerRacewayFaultFeaturesDataset);
    %Creates an outlier dataset with outer raceway fault features
    outerRacewayFaultOutliers=...
        gendatoc([],  outerRacewayFaultFeaturesDataset);
   
   %Creates a test dataset with 50 random samples drawn from each dataset
   numberOfTestSamples=50;
   [targetTestData,targetTrainingData]=...
       gendat(targetData, numberOfTestSamples);
   [ballFaultTestData,]=...
       gendat(ballFaultOutliers, numberOfTestSamples);
   [innerRacewayFaultTestData,]=...
       gendat(innerRacewayFaultOutliers,numberOfTestSamples);
   [outerRacewayFaultTestData,]=...
       gendat(outerRacewayFaultOutliers,numberOfTestSamples);
   testData=[targetTestData;...
             ballFaultTestData;...
             innerRacewayFaultTestData;...
             outerRacewayFaultTestData];
   

   %% SVDD Training
   % Uses the target data to calculate an SVD mapping with a rejection rate of 0.2 and an RBF-Kernel with Sigma=5 (4)     
   w = svdd( targetData,0.2,5);
   
   %% Error evaluation
   % Calculates false negative (rejected targets) and false positive
   % (accepted outliers) rates and plots a ROC curve (1)
   e = dd_error(testData,w);
   %False Negatives:
   e(1)
   %False Positives:
   e(2)
   %Roc
   figure(2); clf;
   plotroc(dd_roc(testData*w),'r');

   %% References
   %%
   % # PRTools4, A Matlab Toolbox for Pattern Recognition Version 4.1
   % (R.P.W. Duin,D.M.J. Tax et al.)
   % # <http://csegroups.case.edu/bearingdatacenter/pages/welcome-case-western-reserve-university-bearing-data-center-website>
   % # "Early Classification Of Bearing Faults Using Hidden Markov Models,Gaussian Mixture Models, Mel-Frequency Cepstral Coefficients and Fractals" (Marwala et al)
   % # "Support Vector Data Description" (Tax,Duin) <http://mediamatica.ewi.tudelft.nl/sites/default/files/ML_SVDD_04.pdf>
   

  