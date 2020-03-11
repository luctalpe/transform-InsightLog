# transform-InsightLog

Powershell script to add relative time to a  log file. 
This will allow to correlate time easily in your log and another event ( example : wpr trace startup) 

Times in the Log file should be expressed in format dd:mm.ss.ms  ( 10:41:56.10213 )

Execute TransformLog.ps1 :
- transform-InsightLog function imported in your powershell sesssion
- Use get-help transform-InsightLog -full to get more information
- Function Usage : transform-InsightLog .\enduser_embedded-!FMT.txt -WPRInit "2020/02/28 17:18:21.4794054" -FirstLinePb 8079 -EndLinePb 8689

