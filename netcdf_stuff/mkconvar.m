%script mkconvar.m
% MKCONVAR: sets up equivalent names between Old Buoy format and EPIC

%script to make convar structure, which aids conversion 
%to epic variables vrom old Buoy format data files
% called by fix_buoy_ts.m

convar(45).epicname = 'P_1';
convar(45).buoyname = ['pre'];
convar(45).buoyunit = ['dec'];

convar(1).epicname = 'T_20';
convar(1).buoyname = ['tem'];
convar(1).buoyunit = ['deg'; 'cel'];

convar(2).epicname = 'AT_21';
convar(2).buoyname = ['air'];
convar(2).buoyunit = ['cel'];

convar(3).epicname = 'T_25';
convar(3).buoyname = ['sea'];
convar(3).buoyunit = ['cel'];

convar(4).epicname = 'S_40';
convar(4).buoyname = ['sal'];
convar(4).buoyunit = ['ppt'; 'psu'];

convar(5).epicname = 'C_50';
convar(5).buoyname = ['con'];
convar(5).buoyunit = ['mho'; 'mmh'];

convar(44).epicname = 'C_51';
convar(44).buoyname = ['con'];
convar(44).buoyunit = ['s/m'];

convar(6).epicname = 'ATTN_55';
convar(6).buoyname = ['att'];
convar(6).buoyunit = ['1/m'; 'vol'];

convar(7).epicname = 'O_60';
convar(7).buoyname = ['dis'];
convar(7).buoyunit = ['mg/'];

convar(8).epicname = 'OST_62';
convar(8).buoyname = ['oxy'];
convar(8).buoyunit = ['per'];

convar(9).epicname = 'ST_70';
convar(9).buoyname = ['sig'];
convar(9).buoyunit = ['kg/'];

convar(10).epicname = 'STH_71';
convar(10).buoyname = ['den'; 'sig'];
convar(10).buoyunit = ['sig'];

convar(46).epicname = 'SV_80';
convar(46).buoyname = ['snd'];
convar(46).buoyunit = ['m/s'];

convar(47).epicname = 'FAC_81';
convar(47).buoyname = ['fac'];
convar(47).buoyunit = ['non'];

convar(11).epicname = 'TRN_107';
convar(11).buoyname = ['tra'];
convar(11).buoyunit = ['vol'];

convar(42).epicname = 'QH_137';
convar(42).buoyname = ['lat'];
convar(42).buoyunit = ['wat'];

convar(43).epicname = 'QB_138';
convar(43).buoyname = ['sen'];
convar(43).buoyunit = ['wat'];

convar(12).epicname = 'CS_300';
convar(12).buoyname = ['vsp'; 'vec'];
convar(12).buoyunit = ['cm/'];

convar(13).epicname = 'CD_310';
convar(13).buoyname = ['vdi'];
convar(13).buoyunit = ['deg'];

convar(14).epicname = 'WS_400';
convar(14).buoyname = ['vsp';'win'];
convar(14).buoyunit = ['met';'m/s'];

convar(15).epicname = 'WD_410';
convar(15).buoyname = ['vdi';'win'];
convar(15).buoyunit = ['deg'];

convar(16).epicname = 'WU_422';
convar(16).buoyname = ['u_1'];
convar(16).buoyunit = ['met'; 'm/s'];

convar(17).epicname = 'WV_423';
convar(17).buoyname = ['v_1'];
convar(17).buoyunit = ['met'; 'm/s'];

convar(39).epicname = 'TX_440';
convar(39).buoyname = ['eas'];
convar(39).buoyunit = ['dyn'];

convar(40).epicname = 'TY_441';
convar(40).buoyname = ['nor'];
convar(40).buoyunit = ['dyn'];

convar(41).epicname = 'Txy_448';
convar(41).buoyname = ['mag'; 'vsp'];
convar(41).buoyunit = ['dyn'];

convar(18).epicname = 'SDP_850';
convar(18).buoyname = ['psd'];
convar(18).buoyunit = ['   '; 'mba'];

convar(19).epicname = 'BP_915';
convar(19).buoyname = ['atm'];
convar(19).buoyunit = ['mil'];

convar(20).epicname = 'w_1204';
convar(20).buoyname = ['w_1'; 'w_2'];
convar(20).buoyunit = ['cm/'];

convar(21).epicname = 'u_1205';
convar(21).buoyname = ['eas'; 'u_1'; 'u_2'];
convar(21).buoyunit = ['cm/'];

convar(22).epicname = 'v_1206';
convar(22).buoyname = ['nor'; 'v_1'; 'v_2'];
convar(22).buoyunit = ['cm/'];

convar(23).epicname = 'van_1403';
convar(23).buoyname = ['van'];
convar(23).buoyunit = ['ang'];

convar(24).epicname = 'comp_1404';
convar(24).buoyname = ['com'];
convar(24).buoyunit = ['ang'];

convar(25).epicname = 'upr_4001';
convar(25).buoyname = ['int'];
convar(25).buoyunit = ['cms'];

convar(26).epicname = 'lowr_4003';
convar(26).buoyname = ['int'];
convar(26).buoyunit = ['cms'];

convar(27).epicname = 'rdif_4004';
convar(27).buoyname = ['r1-'];
convar(27).buoyunit = ['cms'];

convar(28).epicname = 'rot_4005';
convar(28).buoyname = ['rot'];
convar(28).buoyunit = ['cou'];

convar(29).epicname = 'tran_4010';
convar(29).buoyname = ['tra'];
convar(29).buoyunit = ['vol'];

convar(30).epicname = 'ptrn_4011';
convar(30).buoyname = ['per'];
convar(30).buoyunit = ['per'];

convar(48).epicname = 'tiltx_4017';
convar(48).buoyname = ['til'];
convar(48).buoyunit = ['ang'];

convar(49).epicname = 'tilty_4018';
convar(49).buoyname = ['til'];
convar(49).buoyunit = ['ang'];

convar(31).epicname = 'P_4020';
convar(31).buoyname = ['zzz'];
convar(31).buoyunit = ['   '];

convar(32).epicname = 'P_4022';
convar(32).buoyname = ['pre'];
convar(32).buoyunit = ['mil'];

convar(33).epicname = 'P_4023';
convar(33).buoyname = ['pre'];
convar(33).buoyunit = ['mil'; 'mba'];

convar(34).epicname = 'wp_4060';
convar(34).buoyname = ['wav'];
convar(34).buoyunit = ['sec'];

convar(35).epicname = 'wh_4061';
convar(35).buoyname = ['wav'];
convar(35).buoyunit = ['met'];

convar(36).epicname = 'wd_4062';
convar(36).buoyname = ['wav'];
convar(36).buoyunit = ['ang'];

convar(37).epicname = 'time';
convar(37).buoyname = ['tim'];
convar(37).buoyunit = ['day'];

convar(38).epicname = 'time2';
convar(38).buoyname = ['tim'];
convar(38).buoyunit = ['mil'];

% at this point, last number 49
% these are the added ones needed in variance files
convar(50).epicname = 'UVAR_4050';
convar(50).buoyname = ['uvariance_1, uvariance_2'];
convar(50).buoyunit = ['cm2/s2'];

convar(51).epicname = 'UVCOV_4051';
convar(51).buoyname = ['uvcovar_1, uvcovar_2'];
convar(51).buoyunit = ['cm2/s2'];

convar(52).epicname = 'VVAR_4052';
convar(52).buoyname = ['vvariance_1, nvariance_2'];
convar(52).buoyunit = ['cm2/s2'];

convar(53).epicname = 'UWCOV_4053';
convar(53).buoyname = ['uwcovar_1, uwcovar_2'];
convar(53).buoyunit = ['cm2/s2'];

convar(54).epicname = 'VWCOV_4054';
convar(54).buoyname = ['vwcovar_1, vwcovar_2'];
convar(54).buoyunit = ['cm2/s2'];

convar(55).epicname = 'WVAR_4055';
convar(55).buoyname = ['wvariance_1, wvariance_2'];
convar(55).buoyunit = ['cm2/s2'];

convar(56).epicname = 'peru_4056';
convar(56).buoyname = ['uperiod_1, uperiod_2'];
convar(56).buoyunit = ['seconds'];

convar(57).epicname = 'perv_4057';
convar(57).buoyname = ['vperiod_1, vperiod_2'];
convar(57).buoyunit = ['seconds'];


