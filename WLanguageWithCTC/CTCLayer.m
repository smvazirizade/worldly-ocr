classdef CTCLayer < nnet.layer.ClassificationLayer
    
    properties
        % (Optional) Layer properties.
        % Layer properties go here.
    end
    
    properties(Dependent)

    end
    
    methods
        function layer = CTCLayer()
        % (Optional) Create a CTCLayer.
            layer.Name = 'CTCLayer';
        end

        function loss = forwardLoss(layer, Y, T)
        % Return the loss between the predictions Y and the 
        % training targets T.
        %
        % For CTC layer, the loss is the log-likelihood
        % of all training targets, which are label sequences.
        % 
        % Due to the pecularity of MATLAB Deep Learning Toolkit, We receive
        % targets as vectors of dimension equal to the size of the extended
        % alphabet. The columns are vectors of the standard basis (one-hot
        % encoding), with the last vector [0 0 0 ... 1] expressing the
        % blank. Blanks in the target are used for padding, so that the
        % targets can be expressed as a matrix.  Thus, in CTC calculations,
        % this padding should be dropped.
        % 
        % For sequence-to-sequence mapping, the documentation says that T is
        % 3-D array of size K-by-N-by-S, where K is the number of classes, N
        % is the mini-batch size, and S is the sequence length.
        %
        % Inputs:
        %         layer - Output layer
        %         Y     – Predictions made by network
        %         T     – Training targets
        %
        % Output:
        %         loss  - Loss between Y and T

        % Layer forward loss function goes here.
            loss = 0;
            assert(all(size(Y) == size(T)));

            [K, N, S] = size(T);

            for n = 1 : N
                [label, blank] = CTCLayer.target2label(squeeze(T(:,n,:)));
                lPrime = CTCLayer.paddWith(label, blank);
                alpha = zeros([S,length(lPrime)],'single');
                

                alpha(1,1) = Y(blank, n, 1);
                alpha(1,2) = Y(lPrime(1), n, 1);

                for s = 2 : length(lPrime)
                    alpha(1,s) = 0;
                end
                    
                for t = 2 : S
                    for s = 1 : length(lPrime)
                        if s == 1 
                            tmp = alpha(t-1,s);
                        elseif lPrime(s) == blank || s == 2 || lPrime(s) == lPrime(s-2)
                            tmp = alpha(t-1, s) + alpha(t-1,s-1);
                        else
                            tmp = alpha(t-1, s) + (alpha(t-1,s) + alpha(t-1,s-1) + alpha(t-1, s-2));
                        end
                        alpha(t,s) = Y(lPrime(s), n, t) * tmp;
                    end
                end
                
                p = alpha(S, length(lPrime)); 
                if length(lPrime) > 1
                    p = p + alpha(S, length(lPrime) - 1);
                end
                loss = loss - log(p);
            end
            loss = loss ./ N;
        end

        function dLdY = backwardLoss(layer, Y, T)
        % Backward propagate the derivative of the loss function.
        %
        % Inputs:
        %         layer - Output layer
        %         Y     – Predictions made by network
        %         T     – Training targets
        %
        % Output:
        %         dLdY  - Derivative of the loss with respect to the predictions Y

        % Layer backward loss function goes here.
            assert(all(size(Y) == size(T)));

            [K, N, S] = size(T);
            
            dLdY = zeros(size(Y),'single');

            for n = 1 : N
                [label, blank] = CTCLayer.target2label(squeeze(T(:,n,:)));
                lPrime = CTCLayer.paddWith(label, blank);
                
                alpha = zeros([S,length(lPrime)],'single');

                alpha(1,1) = Y(blank, n, 1);
                alpha(1,2) = Y(lPrime(1), n, 1);

                for s = 2 : length(lPrime)
                    alpha(1,s) = 0;
                end
                    
                for t = 2 : S
                    for s = 1 : length(lPrime)
                        if s == 1 
                            tmp = alpha(t-1,s);
                        elseif lPrime(s) == blank || s == 2 || lPrime(s) == lPrime(s-2)
                            tmp = alpha(t-1, s) + alpha(t-1,s-1);
                        else
                            tmp = alpha(t-1, s) + (alpha(t-1,s) + alpha(t-1,s-1) + alpha(t-1, s-2));
                        end
                        alpha(t,s) = Y(lPrime(s), n, t) * tmp;
                    end
                end

                beta = zeros([S,length(lPrime)],'single');

                beta(S,length(lPrime)) = Y(blank, n, S);
                if ~isempty(label)
                    beta(S,length(lPrime)-1) = Y(label(end), n, S);
                end

                for s=1:(length(lPrime)-2)
                    beta(S,s) = 0;
                end
                    
                for t = (S-1):-1:1
                    for s = 1 : length(lPrime)
                        if s == length(lPrime)
                            tmp = beta(t+1,s);
                        elseif lPrime(s) == blank || s == length(lPrime)-1 || lPrime(s) == lPrime(s+2)
                            tmp = beta(t+1, s) + beta(t+1,s+1);
                        else
                            tmp = beta(t+1, s) + (beta(t+1,s) + beta(t+1,s+1) + beta(t+1, s+2));
                        end
                        beta(t,s) = Y(lPrime(s), n, t) * tmp;
                    end
                end

                p = alpha(S, length(lPrime)); 
                if length(lPrime) > 1
                    p = p + alpha(S, length(lPrime) - 1);
                end
                p = p + eps;            % Regularize
                
                dp = zeros(size(Y),'single');
                for t = 1:S
                    for k=1:blank
                        for s=1:length(lPrime)
                            if lPrime(s) == k
                                dp(k,t) = dp(k,t) + ...
                                    alpha(t,s).* beta(t, s) ...
                                    ./ (eps + Y(k, n, t)).^2;
                            end
                        end
                    end
                end
                dLdY = dLdY - dp ./ p;
            end
        end
    end


    methods(Static)
        function [label, blank] = target2label(T)
            [label, blank] = vec2ind(T);
            label = label(label~=blank);
        end

        function lPrime = paddWith(l, blank)
            lPrime = zeros(1,2*length(l)+1);
            lPrime(:)=blank;
            lPrime(2:2:2*length(l)) = l;
        end
    end
end