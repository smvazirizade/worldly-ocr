classdef WLangGenerator
% W-Language generator. It contains methods for encoding and decoding
% strings in the W-language described in the paper:
%
%       Deductron - A Recurrent Neural Network
%
% published at <https://arxiv.org/abs/1806.09038>.

    properties
        H = [0, 0, 1];                  % High pixel
        M = [0, 1, 0];                  % Middle pixel
        L = [1, 0, 0];                  % Low pixel
        Z = [0, 0, 0];                  % Zero pixel
        max_stretch = 1;                % Maximum number of repetitions
                                        % for a row
    end
    
    properties(Dependent = true)

        seq_Z                           % Sequence for blank
        seq_X                           % Sequence for 'X'
        seq_O                           % Sequence for 'O'

    end

    methods(Access = private)
        function out = write_seq(ob, seq, count)
            nargchk(2, 3, nargin);
            if nargin < 3
                count = 1;
            end
            out = [];
            for c=1:count
                % Determine the random number of repetitions
                % of each segment
                for i=1:size(seq, 1)
                    rowrep(i) = randi(ob.max_stretch);
                    out = [out; repmat(seq(i,:),[rowrep(i),1])];
                end
            end
        end
    end


    methods
        function ob = WLangGenerator(max_stretch)
        %Constructor
        % OB = WLANGGENERATOR(MAX_STRETCH) returns a new WLangGenerator
        % object for generalized W-language with maximum number of
        % repetitions of each pixel MAX_STRETCH.
            nargchk(0,1, nargin);
            if nargin < 1
                max_stretch = 1;
            end
            ob.max_stretch = max_stretch;
        end
        
        function v = get.seq_Z(ob)
        % Sequence for blank
            v = ob.Z;  
        end

        function v = get.seq_X(ob)
        % Sequence for 'X'
            v = [ ob.H; ob.M; ob.L; ob.M; ob.H];  
        end

        function v = get.seq_O(ob)
        % Sequence for 'O'
            v = [ ob.L; ob.M; ob.H; ob.M; ob.L];
        end

        function out = write(ob, symbol, count) 
        %Writes a random generalized W-language pattern for a symbol.
        % OUT = WRITE_SEQ(OB, SYMBOL, COUNT) writes an M-by-3 matrix  of 0-1
        % in which rows represent parts of the characters of the
        % W-language representing sequence SEQ of characters
        % in the set {'X', 'O', '_'}. If COUNT is provided, this many copies
        % of the string are produced.
            switch symbol
              case '_'
                out = write_seq(ob, ob.seq_Z, count);
              case 'X'
                out = write_seq(ob, ob.seq_X, count);
              case 'O'
                out = write_seq(ob, ob.seq_O, count);
              otherwise
                error('Invalid symbol');
            end
        end

        function out = main(ob)
        %Write a test sequence
        % OUT = MAIN(OB) outputs an M-by-3 matrix of 0-1 representing
        % the sequence '_XOXXO_'.
            out = [write(ob, '_', 1);
                   write(ob, 'X', 1);
                   write(ob, 'O', 2);
                   write(ob, 'X', 1);
                   write(ob, 'X', 2);
                   write(ob, 'O', 3);
                   write(ob, '_', 1)];
        end

        function out = write_str(ob, str)
        %Write a string in W-language
        % OUT = WRITE_STR(OB, STR) takes a string written using
        % characters {'X','O','_'} and outputs a pattern in W-language.
        % The string is padded with two '_' at each end to eliminate
        % ambiguity upon decoding.
            out = [];
            out = [out; write(ob, '_', 1)];
            out = [out; write(ob, '_', 1)];            
            for i = 1:length(str)
                out = [out; write(ob, str(i), 1)];
            end
            out = [out; write(ob, '_', 1)];
            out = [out; write(ob, '_', 1)];            
        end

        function response = decode(ob, out)
        %A W-language decoder
        % RESPONSE = DECODE(OB, OUT) takes any potential encoded string OUT,
        % which is a pattern in the W-language, and it returns a RESPONSE,
        % which is a string of {'X','O','_'} representing a potential input
        % that resulted in pattern OUT.
            response = ['_'];           % Padd to the same length as data

            z(1) = 0;
            z(2) = 0;

            for w = 1:(size(out,1)-1)
                x = [out(w,:)', out(w+1,:)'];

                y(1) = ~x(2,1) & ~x(3,1) & x(3,2);
                y(2) = ~x(2,1) & ~x(1,1) & x(1,2);

                if y(1) 
                    z(1) = 1;
                    z(2) = 0;
                elseif y(2) 
                    z(1) = 0;
                    z(2) = 1;
                end
                emit_X = x(1,2) & z(1);
                emit_O = x(3,2) & z(2);

                if emit_X
                    response = [response;'X'];
                elseif emit_O
                    response = [response;'O'];
                else
                    response = [response;'_'];
                end
            end
        end

    end
end