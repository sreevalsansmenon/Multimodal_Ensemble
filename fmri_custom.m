%% Program by Sreevalsan S. Menon (sm2hm@mst.edu)

function fmri_custom(XTrain,YTrain,XTest,YTest,crossfold)

dlXTest = dlarray(XTest,'SSSCB');
classes = categories(YTrain);% retrieve the class information with the type of categorical
numClasses = numel(classes);

dlnet1=createLayer_1(XTrain);

velocity1 = [];velocity2 = [];velocity3 = [];
numEpochs = 50;
miniBatchSize = 32;
numObservations = numel(YTrain);
numIterationsPerEpoch = floor(numObservations./miniBatchSize);
averageSqGrad1=[];
averageSqGrad2=[];
averageSqGrad3=[];
averageGrad1=[];
averageGrad2=[];
averageGrad3=[];
epsilon=0.001;
learnRate = 0.001;
GradDecay=0.9;
sqGradDecay= 0.9;
executionEnvironment = "gpu";

figure
lineLossTrain = animatedline;
xlabel("Iteration")
ylabel("Loss")

accu = 0;
iteration = 0;
start = tic;
% Loop over epochs.
for epoch = 1:numEpochs
    % Shuffle data.
    idx = randperm(numel(YTrain));
    XTrain = XTrain(:,:,:,:,idx);
    YTrain = YTrain(idx);
    
    % Loop over mini-batches.
    for i = 1:numIterationsPerEpoch
        iteration = iteration + 1;
        
        % Read mini-batch of data and convert the labels to dummy
        % variables.
        idx = (i-1)*miniBatchSize+1:i*miniBatchSize;
        X1 = XTrain(:,:,:,:,idx);
        % convert the label into one-hot vector to calculate the loss
        Y = zeros(numClasses, miniBatchSize, 'single');
        for c = 1:numClasses
            Y(c,YTrain(idx)==classes(c)) = 1;
        end
        
        % Convert mini-batch of data to dlarray.
        dlX1 = dlarray(single(X1),'SSSCB');
        
        % If training on a GPU, then convert data to gpuArray.
        if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "gpu"
            dlX1 = gpuArray(dlX1);
        end
        %the traning loss and the gradients after the backpropagation were
        %calculated using the helper function modelGradients_demo
        [gradients1,loss] = dlfeval(@modelGradients_demo,dlnet1,dlX1,dlarray(Y));
        % Update the network parameters using the RMSProp optimizer.
        % Update the parameters in dlnet1 to 3 sequentially
        [dlnet1,averageGrad1, averageSqGrad1] = adamupdate(dlnet1, gradients1,averageGrad1, averageSqGrad1,iteration,learnRate,GradDecay,sqGradDecay,epsilon);
        % Display the training progress.
        D = duration(0,0,toc(start),'Format','hh:mm:ss');
        addpoints(lineLossTrain,iteration,double(gather(extractdata(loss))))
        title("Epoch: " + epoch + ", Elapsed: " + string(D))
        drawnow
            dlYPred = predict(dlnet1,dlXTest);
            [~,idx] = max(extractdata(dlYPred),[],1);
            YPred = classes(idx);
            accuracy = sum(categorical(str2double(YPred))==YTest')/size(dlXTest,5);
            if accuracy >= accu
                save(['dwi_' num2str(crossfold) '_test.mat'],'dlnet1','YPred','YTest')
                accuracy == accu
                patience_ini = patience_ini + (accu = accuracy);
            end
            if patience_ini>19
                epoch = numEpochs;
                break;
            end
    end
end


    function dlnet=createLayer_1(XTrain)
        layers = [
            image3dInputLayer([91 109 91 4],'Name','fmri_input',"Mean",mean(XTrain,5))
            convolution3dLayer(3,4,'Padding','same','Name','conv_f1')
            reluLayer('Name','relu_f1')
            maxPooling3dLayer(2,'Stride',2, 'Name','maxpool_f1')
            convolution3dLayer(3,8,'Padding','same','Name','conv_f2')
            reluLayer('Name','relu_f2')
            maxPooling3dLayer(2,'Stride',2, 'Name','maxpool_f2')
            dropoutLayer(0.5,'Name','dp_1')
            fullyConnectedLayer(64,"Name","fc_1")
            dropoutLayer(0.8,'Name','dp_2')
            fullyConnectedLayer(2,"Name","fc_2")
            softmaxLayer('Name','softmax')
            ];
        lgraph = layerGraph(layers);
        dlnet = dlnetwork(lgraph);
    end


    function [gradients1, loss] = modelGradients_demo(dlnet1,dlX1,Y)
        dlYPred = forward(dlnet1,dlX1);
        loss = crossentropy(dlYPred,Y);
        gradients1 = dlgradient(loss,dlnet1.Learnables);
    end
end
