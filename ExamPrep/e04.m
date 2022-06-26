%% ---------------------------------
section Parametric Model Identification
%-----------------------------------


%% ---------------------------------
subsection Prepare Data

if periods > 1 
    split_idx = round((1-1/periods)*length(y));
else 
    split_idx = round(3/4*length(y));
end 

% identification data
idt_u = u(1:split_idx);
idt_y = detrend(y(1:split_idx),0);
idt_data = iddata(idt_y, idt_u , Ts, ...
                    'Name',         'Identification Data', ...
                    'InputName',    io_data.InputName, ...
                    'InputUnit',    io_data.InputUnit, ...
                    'OutputName',   io_data.OutputName, ...
                    'OutputUnit',   io_data.OutputUnit);

% validation data
val_u = u(split_idx+1:end);
val_y = detrend(y(split_idx+1:end),0);
val_data = iddata(val_y, val_u , Ts, ...
                    'Name',         'Validation Data', ...
                    'InputName',    io_data.InputName, ...
                    'InputUnit',    io_data.InputUnit, ...
                    'OutputName',   io_data.OutputName, ...
                    'OutputUnit',   io_data.OutputUnit);

fprintf("\tdone\n")

%% ---------------------------------
subsection Create Models

% set unset orders for parametric models
nc = na;
nd = na;
nf = na;

% create parametric models 
model_arx    = arx(idt_data,    [na, nb, nk],           'Name', 'ARX');
% model_iv4    = iv4(idt_data, [na, nb, nk], iv4Options('EnforceStability', true)); % this causes mysterious toolbox errors
model_iv4    = iv4(idt_data,    [na, nb, nk],           'Name', 'IV4');
model_armax  = armax(idt_data,  [na, nb, nc, nk],       'Name', 'ARMAX');
model_oe     = oe(idt_data,     [nb, nf, nk],           'Name', 'OE');
model_bj     = bj(idt_data,     [nb, nc, nd, nf, nk],   'Name', 'BJ');
model_n4sid  = n4sid(idt_data,  n,                      'Name', 'N4SID');

% prepare for plotting 
models = {model_arx, model_iv4, model_armax, model_oe, model_bj, model_n4sid};
model_names = cellfun(@(M) M.Name, models, 'UniformOutput', false);

fprintf("\tdone\n")
