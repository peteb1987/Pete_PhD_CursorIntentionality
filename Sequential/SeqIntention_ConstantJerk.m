function [ correct_proportion ] = SeqIntention_ConstantJerk( track, click_times, click_locs, handles )
%SEQINTENTION Sequential intention tracking using drift model method

global CONSTANTS;
global FLAGS;

BUFFER_LENGTH = 10;

% Set click index - which click is next
click_ind = 1;

% time array
end_proc_time = cell(track.N,1);
end_proc_time{1} = clock;

% performance eval
right_time = 0;
wrong_time = 0;

chosen_button = 1;

for k = 1:track.N
    
%     if ~FLAGS.PLOT
%         disp([num2str(k) ' out of ' num2str(track.N)]);
%     end
    
    if (k==1) || (track.t(k) > click_times(click_ind))
        
        % Increment click pointer
        click_ind = click_ind + 1;
        
        if click_ind > length(click_times)
            break;
        end
        
        [ dummy_locs, correct_button, handles ] = NextClick( click_ind, click_locs, handles );
        N_locs = length(dummy_locs);
        
        % Reset everything
        time_buffer = zeros(0,1);
        like_buffer = zeros(0,N_locs);
        
    end
    
    %%%%%
    
    if k > 3
        
        % Get positions and times
        pos_m0 = [track.x(k) track.y(k)];
        time_m0 = track.t(k);

        pos_m1 = [track.x(k-1) track.y(k-1)];
        time_m1 = track.t(k-1);
        
        pos_m2 = [track.x(k-2) track.y(k-2)];
        time_m2 = track.t(k-2);
        
        pos_m3 = [track.x(k-3) track.y(k-3)];
        time_m3 = track.t(k-3);
        
        % Step sizes
        del_m0 = (time_m0 - time_m1);
        del_m1 = (time_m1 - time_m2);
        del_m2 = (time_m2 - time_m3);
        
        % Estimate derivatives
        vel_m0 = (pos_m0 - pos_m1)/del_m0;
        vel_m1 = (pos_m1 - pos_m2)/del_m1;
        vel_m2 = (pos_m2 - pos_m3)/del_m2;
        
        acc_m0 = (vel_m0 - vel_m1)/(0.5*(del_m0+del_m1));
        acc_m1 = (vel_m1 - vel_m2)/(0.5*(del_m1+del_m2));
        
        jerk_m0 = (acc_m0 - acc_m1)/(0.25*del_m1+0.5*(del_m0+del_m2));
        
        % Find components in direction of travel
        dir_vec = vel_m0/sqrt(sum(vel_m0.^2));
        v0 = sum(vel_m0.*dir_vec);
        a0 = sum(acc_m0.*dir_vec);
        j0 = sum(jerk_m0.*dir_vec);
        
        % Find stopping point
        t_stop = (-a0 - sqrt(a0^2-2*v0*j0))/j0;
        mu = pos_m0 + v0*dir_vec*t_stop + a0*dir_vec*0.5*t_stop^2 + j0*dir_vec*(1/6)*t_stop^3;
        sigma = t_stop^3;
        
        % Work out likelihood
        if isreal(t_stop)&&(j0<0)
            like = log(normpdf(dummy_locs(:,1), mu(1), sqrt(sigma)));
            like = like + log(normpdf(dummy_locs(:,2), mu(2), sqrt(sigma)));
        else
            like = zeros(length(dummy_locs),1);
        end
        
        if all(isinf(like))||all(like==0)
            like=[];
        end
        
        % Add time and likelihoods to buffer
        if numel(like)>0
            time_buffer = [time_buffer; time_m0];
            like_buffer = [like_buffer; like'];
        end
        
        % Remove old things from the front of the buffer
        while numel(time_buffer)>0 && (time_buffer(1) < time_m0-BUFFER_LENGTH)
            time_buffer(1, :) = [];
            like_buffer(1, :) = [];
        end
        
        % Find ML button
        if numel(like_buffer)>0
            total_like = sum(like_buffer, 1);
            chosen_button = find(total_like==max(total_like),1);
        end
        
    end
    
    %%%%%
    
    if k>3
        
        if chosen_button == correct_button
            right_time = right_time + (track.t(k)-track.t(k-1));
        else
            wrong_time = wrong_time + (track.t(k)-track.t(k-1));
        end
        
        if FLAGS.PLOT
            
            [ handles ] = UpdateFigure( k, track, dummy_locs, chosen_button, handles );
            disp(['Correct button: ' num2str(right_time) '. Wrong button: ' num2str(wrong_time) '.']);
            
        end
    end
    
    % Wait
    if (k > 1) && (FLAGS.PLOT)
        end_proc_time{k} = clock;
        time_rem = (track.t(k)-track.t(k-1))/(1000/CONSTANTS.SLOWDOWN) - etime(end_proc_time{k}, end_proc_time{k-1});
        if time_rem > 0
            pause(time_rem);
        else
%             disp(time_rem);
        end
    end
    
end

disp(['   Correct button: ' num2str(right_time) '. Wrong button: ' num2str(wrong_time) '.']);

correct_proportion = right_time / (right_time+wrong_time);

end

