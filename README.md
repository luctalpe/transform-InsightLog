# transform-InsightLog

Powershell script to add relative time to a  log file. 
This will allow to correlate time easily in your log and another event ( example : wpr trace startup) 

Times in the Log file should be expressed in format dd:mm.ss.ms  ( 10:41:56.10213 )

Execute TransformLog.ps1 :
- transform-InsightLog function imported in your powershell sesssion
- Use get-help transform-InsightLog -full to get more information
- Function Usage : transform-InsightLog .\enduser_embedded-!FMT.txt -WPRInit "2020/02/28 17:18:21.4794054" -FirstLinePb 8079 -EndLinePb 8689

Pb# DelayPb s # DelayWPR s# Event Message 
  #-126.447536# -39.957152# [0] 0998.099C::02/28/20-17:17:41.5222537 [SPOOLSV] splctrlh_c65 SpoolerCtrlHandler() - Control request received op 0x4 type 0x0 
  #-126.446946# -39.956561# [1] 0998.099C::02/28/20-17:17:41.5228440 [SPOOLSV] splctrlh_c65 SpoolerCtrlHandler() - Control request received op 0x4 type 0x0 
  #-101.717127# -15.226743# [0] 0A60.0A44::02/28/20-17:18:06.2526629 [PERFLIB] init_c811 DllMain() - 0(ERROR_SUCCESS) 
...
  #  -0.044694#  86.445690# [0]0998.1C14::02/28/20-17:19:47.9250955 [Operational ] Spooling job 2.  
###   0.000000#  86.490384# [0]0998.1C14::02/28/20-17:19:47.9697898 [Debug ] Starting document job 2 for printer Microsoft Print to PDF succeeded. See the event user data for context information. SpoolThisJob, 0x0, 2 
...
###   3.876110#  90.366495# [1] 195C.28CC::02/28/20-17:19:51.8459002 [PRNNTFY] prnntfy_cxx2939 TPrintTrayNotification::CheckToShowJobSentUI() - kJP_PARAMETERS not found or NULL for Microsoft Print to PDF. HR S_OK 
###   3.876600#  90.366985# [0]0998.2898::02/28/20-17:19:51.8463902 [Operational ] Rendering job 2. 2, 75028, 0, 2, 600, 600, 600, 1 
  #   3.876688#  90.367072# [0]0998.2898::02/28/20-17:19:51.8464777 [Operational ] Document 2, Print Document owned by ep.paul.lawson on \\WIN10-DEV03 was printed on Microsoft Print to PDF through port C:\pjltest\test.pdf.  Size in bytes: 75028. Pages printed: 1. No user action is required.  
  #   3.877085#  90.367469# [0] 195C.28CC::02/28/20-17:19:51.8468745 [PRNNTFY] prnntfy_cxx1938 TPrintTrayNotification::OnJobDelete() - TPrintTrayNotification::OnJobDelete 



