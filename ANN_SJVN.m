function ANN_SJVN_Model
    close all; clc;

    %% Load Data from Excel File
    filePath = 'C:\Users\ACER\Desktop\SJVN\GUI Prototype\Model_Data.xlsx';
    sheetName = 'm';
    data = xlsread(filePath, sheetName);

    inputs = data(:, 1:end-1);
    targets = data(:, end);

    %% Normalize Inputs and Outputs between 0 and 1
    minX = min(inputs); maxX = max(inputs);
    minY = min(targets); maxY = max(targets);

    inputs_norm = (inputs - minX) ./ (maxX - minX);
    targets_norm = (targets - minY) ./ (maxY - minY);

    %% Split Data into Training and Testing Sets (80-20 split)
    total_samples = size(inputs_norm, 1);
    idx = randperm(total_samples);
    train_idx = idx(1:round(0.8 * total_samples));
    test_idx = idx(round(0.8 * total_samples)+1:end);

    xtrain = inputs_norm(train_idx, :)';
    ytrain = targets_norm(train_idx)';
    xtest = inputs_norm(test_idx, :)';
    ytest = targets_norm(test_idx)';

    %% Create and Train ANN Model
    trainFcn = 'trainlm';
    hiddenLayerSize = 20;
    net = fitnet(hiddenLayerSize, trainFcn);
    net.divideParam.trainRatio = 80/100;
    net.divideParam.valRatio = 20/100;
    net.divideParam.testRatio = 20/100;

    [net, tr] = train(net, xtrain, ytrain);

    %% GUI Creation
    f = uifigure('Name','ANN Model for UCS Prediction','Position',[100 100 500 350]);
    g = uigridlayout(f, [7, 2]);

    % Create input fields for parameters
    uilabel(g, 'Text', 'RMR:', 'FontSize', 12);
    RMRField = uieditfield(g, 'numeric', 'FontSize', 12);
    
    uilabel(g, 'Text', 'UCS (MPa):', 'FontSize', 12);
    UCSField = uieditfield(g, 'numeric', 'FontSize', 12);
    
    uilabel(g, 'Text', 'Ei (GPa):', 'FontSize', 12);
    EiField = uieditfield(g, 'numeric', 'FontSize', 12);
    
    uilabel(g, 'Text', 'Poisson’s Ratio:', 'FontSize', 12);
    PoissonField = uieditfield(g, 'numeric', 'FontSize', 12);
    
    uilabel(g, 'Text', 'Tensile Strength (MPa):', 'FontSize', 12);
    TensileStrengthField = uieditfield(g, 'numeric', 'FontSize', 12);
    
    uilabel(g, 'Text', 'Friction Angle (Degree):', 'FontSize', 12);
    FrictionAngleField = uieditfield(g, 'numeric', 'FontSize', 12);
    
    uilabel(g, 'Text', 'C (MPa):', 'FontSize', 12);
    CField = uieditfield(g, 'numeric', 'FontSize', 12);
    
    % Prediction button
    predictButton = uibutton(g, 'Text', 'Predict Deformation', 'FontSize', 12, 'ButtonPushedFcn', @predictDeformation);

    % Output label for predicted deformation
    uilabel(g, 'Text', 'Predicted Deformation:', 'FontSize', 12);
    outputField = uilabel(g, 'Text', '', 'FontSize', 12);

    %% Nested function for prediction
    function predictDeformation(~, ~)
        % Get the user inputs
        RMR_val = RMRField.Value;
        UCS_val = UCSField.Value;
        Ei_val = EiField.Value;
        Poisson_val = PoissonField.Value;
        TensileStrength_val = TensileStrengthField.Value;
        FrictionAngle_val = FrictionAngleField.Value;
        C_val = CField.Value;
        
        % Normalize the inputs
        input_vals = [RMR_val, UCS_val, Ei_val, Poisson_val, TensileStrength_val, FrictionAngle_val, C_val];
        input_vals_norm = (input_vals - minX) ./ (maxX - minX);

        % Reshape for prediction
        input_vals_norm = input_vals_norm';

        % Predict the deformation (output)
        deformation_norm = net(input_vals_norm);

        % Denormalize the output
        deformation = deformation_norm * (maxY - minY) + minY;

        % Display the predicted deformation
        outputField.Text = sprintf('%.4f', deformation);
    end
end
