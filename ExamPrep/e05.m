%% ---------------------------------
section Model Choice
%-----------------------------------


%% ---------------------------------
subsection Time Domain Comparison

% compare models and find best time-domain fit 
[~, time_fit, ~] = compare(val_data, models{:});
[~, time_best_idx] = max(cell2mat(time_fit));

fprintf("\t%s\n", sprintcells('%s : %4.1f%%', model_names, time_fit));
fprintf("\tbest time-domain model is %s\n", model_names{time_best_idx})

% visualize for sanity check
fig = figure('Name', 'Simulated Response');
compare(val_data, models{:})
fig.Children(3).String{1} = val_data.Name;
legend('location', 'best')
drawnow
saveas(fig, "img/51_time_comparison.png")


%% ---------------------------------
subsection Frequency Domain Comparison

% spectrum of the validation data using a large window
model_spa = spa(val_data, round(length(val_data.y)/2));
% model_spa = spa(val_data);
model_spa.Name = val_data.Name;

% compare models and find best freq-domain fit 
[~, freq_fit, ~] = compare(model_spa, models{:});
[~, freq_best_idx] = max(cell2mat(freq_fit));

fprintf("\t%s\n", sprintcells('%s : %4.1f%%', model_names, freq_fit));
fprintf("\tbest freq-domain model is %s\n", model_names{freq_best_idx})

% visualize for sanity check
fig = figure('Name', 'Frequency Response');
compare(model_spa, models{:})
fig.Children(3).String{1} = model_spa.Name;
fig.Children(3).Location = 'best';
drawnow
saveas(fig, "img/52_freq_comparison.png")


%% ---------------------------------
subsection Statistical Validation

is_OK = cell(size(models));
for i = 1:length(models)
    [E, R] = resid(val_data, models{i});
    Ryynorm  = [flipud(R(2:end,1,1)); R(:,1,1)]./max(R(:,1,1)); % the residuals of the auto-corr
    Ryenorm  = [flipud(R(2:end,1,2)); R(:,2,1)]./sqrt(max(R(:,1,1))*max(R(:,2,2)));
%     e      = 2*sqrt(E.Ts * var(E.OutputData))/max(R(:,1,1));
    e      = 0.114; % heuristic 
    if any(abs(Ryynorm(Ryynorm~=1)) > e) || any(abs(Ryenorm) > e)
        is_OK{i} = ['[' 8 'not]' 8 ' OK'];
    else 
        is_OK{i} = 'OK';
    end
%     figure("Name",model_names{i})
%     stem((1-size(R,1)):(size(R,1)-1), [Ryynorm, Ryenorm]), yline([-e, e],'r--'), grid on,
end 
fprintf("\t%s\n", sprintcells('%s is %s', cellstr(model_names), is_OK));


% visualize for sanity check
fig = figure('Name', 'Residuals');
resid(val_data, models{:})
legend(model_names), grid on
legend('location', 'best')
drawnow
saveas(fig, "img/53_resid_comparison.png")

% for i = 1:length(models)
%     fig = figure('Name', sprintf('%s Residuals', model_names{i}));
%     resid(val_data, models{i})
%     legend(model_names{i}, 'location', 'best')
%     grid on
% end


%% ---------------------------------
subsection Final Model Choice 

scores = 100 - sqrt((100-cell2mat(time_fit)) .* (100-cell2mat(freq_fit)));
[~, best_idx] = max(scores);

if strcmp(is_OK{best_idx}, 'OK')
    fprintf("\tbest validated model is %s\n", model_names{best_idx});
else 
    fprintf("\tbest model is %s, but is is %s\n", model_names{best_idx}, is_OK{i});
    
    val_idx = cell2mat(cellfun(@(c) strcmp(c, 'OK'), is_OK, 'UniformOutput', false));
    if any(val_idx)
        [~, best_val_idx] = max(scores(val_idx));
        best_val_idx = find(val_idx, best_val_idx);
        fprintf("\tthe best validated model is %s\n", model_names{best_val_idx(end)})
    end
end


