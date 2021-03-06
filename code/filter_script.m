close all
global GPSCOUNTER WHEELCOUNTER IMUCOUNTER GPS_X GPS_Y GPS_X_START GPS_Y_START theta_counter X Y GPS_ready theta map cmd_mode THETA x_prev y_prev IM
WHEELCOUNTER = 10;
GPSCOUNTER = 10; 
IMUCOUNTER = 10;
% WHEELCOUNTER = 50000;
% GPSCOUNTER = 50000; 
% IMUCOUNTER = 120000;
GPS_X_START=GPS_X(GPSCOUNTER);
GPS_Y_START=GPS_Y(GPSCOUNTER);
theta_counter = 0;

X = [0];
Y = [0];
X2 = [];
Y2 = [];
X3 = [];
Y3 = [];
THETA = [];
GPS_theta = [];
z = [0,0,0,0,0,0];
dt = 0;
THETA_imu=0;
Theta_imu_dot=0;
gps_theta = 0;
theta_gps = 0;
theta_imu = 0;
theta_odom = 0;
theta_dot=0;
Theta_odom = [];
z_gps_1=0;
z_gps_2=0;
R=0;
dt=0;
x_prev = 0;
y_prev = 0;
R_diff = [];
[theta,theta_dot]=KF_SVA(theta_gps,theta_odom,theta_dot,dt,0);
[x,y]=KF_XY(z_gps_1,z_gps_2,R,dt,0);
%[x,y]=KF_XY_velo(z_gps_1,z_gps_2,R,dt,0);
init_map(20,15,40);
disp('Greatings! This will take some time. It is suggested to go and get some coffie at this time. Approximatly 20 minutes on a crappy computer.')
figure
while (isMoreData())
    string = NextData();
    if strcmp(string, 'GPS')
        [z_gps] = get_new_gps(0);
        z_gps_1=z_gps(1);
        z_gps_2=z_gps(2);

        gps_theta = GPS_theta_calc();
        GPSCOUNTER = GPSCOUNTER + 1;
   
     elseif strcmp(string, 'IMU')
         dt = IMU_TimeStamp(IMUCOUNTER) - IMU_TimeStamp(IMUCOUNTER - 1);
          z = get_new_IMU(z);
          theta_imu = z(5);%(z(5)+z(6))/2;
          [THETA_imu, Theta_imu_dot] = IMU_integrate(theta_imu, dt, THETA_imu);
        IMUCOUNTER = IMUCOUNTER + 1;    elseif strcmp(string,'WHEEL')
        delta_time = Enc_TimeStamp(WHEELCOUNTER) - Enc_TimeStamp(WHEELCOUNTER - 1);  
        theta_gps =gps_theta;
        theta_odom = ((Odom_ori_Z(WHEELCOUNTER)-Odom_ori_Z(WHEELCOUNTER-1)))/delta_time;% + bias;
        if R_wheel(WHEELCOUNTER)~=0 && L_wheel(WHEELCOUNTER)~=0
            R = sqrt((Odom_pos_X(WHEELCOUNTER)-Odom_pos_X(WHEELCOUNTER-1))^2+(Odom_pos_Y(WHEELCOUNTER)-Odom_pos_Y(WHEELCOUNTER-1))^2);
        else
            R=0;
        end
        if R_wheel(WHEELCOUNTER)<0 && L_wheel(WHEELCOUNTER)<0
            R=-R;
        end
        
%         WHeel_R = sqrt((Odom_pos_X(WHEELCOUNTER+5)-Odom_pos_X(WHEELCOUNTER-5))^2+(Odom_pos_Y(WHEELCOUNTER+5)-Odom_pos_Y(WHEELCOUNTER-5))^2);
%         length_gps = size(GPS_TimeStamp);
%         if GPSCOUNTER+5<length_gps(2)
%             GPS_R = sqrt((GPS_X(GPSCOUNTER+5) - GPS_X(GPSCOUNTER-5))^2 + (GPS_Y(GPSCOUNTER+5) - GPS_Y(GPSCOUNTER-5))^2); 
%         end
% %          disp(R_dot - 0.2 * abs(R)/delta_time)
%         R_diff = [R_diff, GPS_R-WHeel_R];
%         if all_fix(500)%GPS_R < 0.5 * abs(WHeel_R) && all_fix(1000)
%             [theta,theta_dot]=KF_SVA(theta_gps,theta_odom,Theta_imu_dot,dt,1);
%             [x,y]=KF_XY(z_gps_1,z_gps_2,R,delta_time,1);
%             X3 = [X3, x];
%             Y3 = [Y3, y];
%         else
%             [theta,theta_dot]=KF_SVA_tweak(theta_gps,theta_odom,Theta_imu_dot,dt,1);
%             [x,y]=KF_XY_velo(z_gps_1,z_gps_2,R,delta_time,1);
%             X2 = [X2, x];
%             Y2 = [Y2, y];
% 
%         end
            [theta,theta_dot]=KF_SVA(theta_gps,theta_odom,Theta_imu_dot,dt,1);
            [x,y]=KF_XY(z_gps_1,z_gps_2,R,delta_time,1);
%         [x,y]=KF_XY(z_gps_1,z_gps_2,R,delta_time,1);
%           [x,y]=KF_XY_velo(z_gps_1,z_gps_2,R,delta_time,1);
        x_prev = z_gps_1;
        y_prev = z_gps_2;
        WHEELCOUNTER = WHEELCOUNTER + 1;
    end
    
    if Loop_Front_center(WHEELCOUNTER-1) < 0 && Loop_Front_center(WHEELCOUNTER) > 0%|| Loop_Front_center_F(WHEELCOUNTER) < 0 || Loop_Front_center_N(WHEELCOUNTER) < 0       
        if oposite_rotation_direction()
            if cell_flag_hit(x,y) == 1
%              Occupy_cells(x+15,y+5,(THETA(end)*180/pi)+45);
               Occupy_cells_left(x+15,y+5,(THETA(end)*180/pi)-90);
            end
        else
            if cell_flag_hit(x,y) == 1
             Occupy_cells_right(x+15,y+5,(THETA(end)*180/pi)-90);
            show(map)
            drawnow;
            end
        end
            
%         
%         if cell_flag_hit(x,y) == 1 && cmd_mode(WHEELCOUNTER) == 2 && WHEELCOUNTER > 50
%         Occupy_cells(x+15,y+5,(THETA(end-50)*180/pi)-90);
%         end
    elseif Loop_Front_center(WHEELCOUNTER-1) > 0
        if cell_flag_clear(x,y) == 1 && cmd_mode(WHEELCOUNTER) == 2 && WHEELCOUNTER > 50            
            Clear_cells(x+15,y+5,(THETA(end)*180/pi)-90);
        end
    end
        X = [X, x];
        Y = [Y, y];
        THETA = [THETA, theta];


end% show(map)
% figure(1)
% plot(X,Y)
% hold on
% plot(GPS_X(1:GPSCOUNTER)-GPS_X_START,GPS_Y(1:GPSCOUNTER)-GPS_Y_START)
% figure(2)
% plot(THETA)
% hold on
% plot(GPS_theta)
% hold on
% plot(Theta_odom)

mat = occupancyMatrix(map);
IM = mat;
% filename = ''%input('Save as: ', 's')
% save(filename, mat)


