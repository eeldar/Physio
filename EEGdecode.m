function [decodability, pval, predicted, regs] = EEGdecode(Y, X)
    % INPUT:   Y [N x 1] -          N quantities we want to predict (e.g., prediction errors)
    %          eadata [N x F] -     data that we want to decode with N trials and F features
    % OUTPUT:  decodability -       cross-validated correlation between decoded and actual quantities
    %          pval -               significance of correlation
    %          predicted -          predicted quantities
    %          regs -               best regularization settings per iteration

    addpath(genpath('libsvm-3.23'));
    
    [~,I] = sort(Y);
    Nreg = 45;
    predicted = nan(size(Y,1),1);
    
    for ireg = 1:Nreg
        reg3(ireg) = 1*1/size(X,2);
        reg2(ireg) = 0.1 + mod(ireg-1,9)*0.1;
        reg1(ireg) = 2^(ceil(ireg/9)-3);
    end
    
    for j =1:5
        iTest{j} = I(j:5:size(X,1));
        iTrain{j} = setdiff(1:size(X,1),iTest{j});
        Ytrain{j} = double(Y(iTrain{j},:)); 
        Xtrain{j} = X(iTrain{j},:); 
    end
    
    for j = 1:5
        for ireg = 1:Nreg
            acc{j}(ireg,1) = svmtrain(Ytrain{j}, Xtrain{j}, sprintf('-q -s 4 -c %d -n %d -g %d -v 5',reg1(ireg), reg2(ireg), reg3(ireg))); %#ok<*SVMTRAIN,*PFOUS,*PFBNS>
        end
        [~,reg(j)] = min(acc{j});
        model = svmtrain(Ytrain{j}, Xtrain{j}, sprintf('-q -s 4 -c %d -n %d -g %d',reg1(reg(j)), reg2(reg(j)), reg3(reg(j))));
        Xtest = X(iTest{j},:); 
        Ypred{j} = svmpredict(double(Y(iTest{j},:)), Xtest,model);

    end
    
    for j =1:5
        predicted(iTest{j},1) = Ypred{j};
        regs(j,:) = [reg1(reg(j)) reg2(reg(j)) reg3(reg(j))];
    end
    
    [decodability, pval] = corr(predicted,Y);
end