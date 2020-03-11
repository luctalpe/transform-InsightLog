

$global:HourTraceFormatRegularExpression = "[\d]*\d\d/\d\d/\d\d[- ](?<HHMMSSms>\d\d:\d\d:\d\d[.]\d*)"
# transform -File .\enduser_embedded-!FMT.txt -WPRInit "2020/02/28 17:18:21.4794054" -FirstLinePb 8079 -EndLinePb 8689 

Function global:transform-InsightLog {
<#
.SYNOPSIS
        This script will add relative time to a ETL log file. This will allow to correlate time easily in your log 
        and another event ( example : wpr trace startup) 

.DESCRIPTION
        A new file will be created containing relative times from the date specified in -WPRINit time and from the time found in line -EndLinePb
        ex: transform-InsightLog .\enduser_embedded-!FMT.txt -WPRInit "2020/02/28 17:18:21.4794054" -FirstLinePb 8079 -EndLinePb 8689

.EXAMPLE
        transform-InsightLog .\enduser_embedded-!FMT.txt -WPRInit "2020/02/28 17:18:21.4794054" -FirstLinePb 8079 -EndLinePb 8689 

        will output  :
## Processing .\enduser_embedded-!FMT.txt , 8710 lines
## WPR trace origin is 2020/02/28 17:18:21.4794054 (see System Configuration - Traces - Start Time )
#
# line 8079 :  Problem started [0]0998.1C14::02/28/20-17:19:47.9697898 [Debug ] Starting document job 2 for printer Microsoft Print to PDF succeeded. See the event user data for context information. SpoolThisJob, 0x0, 2
# Problem started 86.4903844 second(s) after WPR trace start

#
# line 8688 : Problem ended [0]0998.2898::02/28/20-17:19:51.8464777 [Operational ] Document 2, Print Document owned by ep.paul.lawson on \\WIN10-DEV03 was printed on Microsoft Print to PDF through port C:\pjltest\test.pdf.  Size in bytes: 75028. Pages printed: 1. No user action is required.
# Problem ended  90.3670723 after second(s) WPR trace start
# Problem duration 3.8766879

Results in .\enduser_embedded-!FMT.txt.inpb.txt

        will create this file  .\enduser_embedded-!FMT.txt.inpb.txt" :
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

#>

        [cmdletBinding()]
        Param ( 
            # Specify the InsightClient log file to process 
            [Parameter(Mandatory=$true)][string]$File , 
            # Specify the reference time ( ex : WPR Start time I.e: "2020/02/28 17:18:21.4794054" )
            [Parameter(Mandatory=$true)][string]$WPRInit ,  
            # First Line of Interest to analyze the log in your InsightLog 
            [uint32]$FirstLinePb = [uint32]::MinValue , 
            # Last Line of Interest to analyze the log in your InsightLog 
            [uint32]$EndLinePb = [uint32]::MaxValue , 
            # Regular expression used to extract HHMMSS.ms in your log file and in $WPRInit argument.
            # default to "[\d]*\d\d/\d\d/\d\d[- ](?<HHMMSSms>\d\d:\d\d:\d\d[.]\d*)"
            [string]$HourTraceFormat = $HourTraceFormatRegularExpression  ) 

        if( -not (test-path "$file") ) {
            throw "$file doesn\'t exist"
        }
    
        try {
            if( -not ($WPRInit -match "$HourTraceFormat") ) {
                throw "WPRInit parameter $WPRInit doesn't respect $HourTraceFormat specified"
            }

            $EtwInit = [timespan]$Matches["HHMMSSms"]
    
        }
        catch {
            throw $Error[0];
            return;
        }
        
        $contents = Get-Content "$file";
        $size = $contents.Count;
        write-host -BackgroundColor Green -ForegroundColor Black  "## Processing $file , $size lines "
        write-host -BackgroundColor Green -ForegroundColor Black  "## WPR trace origin is $WPRInit (see System Configuration - Traces - Start Time )"
        if( $size -lt $FirstLinePb) {
            throw "Error $FirstLinePb greater than file size $size"
        }

        $FirstLine = $contents[$FirstLinePb];
        $FirstLineTimeSpanPb = [TimeSpan]"0";
        $LastLineTimeSpanPb = [TimeSpan]::MaxValue;
        if( $FirstLine -match "$HourTraceFormat" ) {
            $FirstLineTimeSpanPb = [TimeSpan]$Matches["HHMMSSms"]
        } else {
            throw "No valid hour in Firstlinepb $Firstlinepb : $FirstLine "
        }
        
        $result = @("Pb# DelayPb s # DelayWPR s# Event Message " )
        $inpb = $false;
        $i = 0;
        $lasttime = [timespan]"0"
        $meetpb = $false
        $startpb =  $lasttime 

        for( $i = 0 ; $i -lt $size ; $i++ ) {
            $line = $contents[$i];
            if(  $line -match $HourTraceFormat ) {
                # "---$i  $FirstLinePb " 
                $lasttime = [timespan]$Matches["HHMMSSms"]
                $FromStartWPR =  $($lasttime - $EtwInit).TotalSeconds;
                $FromStartLog =  $($lasttime - $FirstLineTimeSpanPb).TotalSeconds;
                # ($i -ge $FirstLinePb )
                if ( ( $meetpb -eq $false ) -and ($i -ge $FirstLinePb ) ) { 
                    $meetpb = $true;
                    write-host "#" 
                    write-host "# line $i :  Problem started $line"
                    write-host "# Problem started $FromStartWPR second(s) after WPR trace start"
                    write-host " " 
                    $startpb =  $lasttime;
                    $inpb = $true;
                }
                elseif ( ($i+1) -ge $EndLinePb -and $inpb ) {
                    $LastLineTimeSpanPb = $lasttime;
                    write-host "#" 
                    write-host "# line $i : Problem ended $line"
                    write-host "# Problem ended  $FromStartWPR after second(s) WPR trace start"
                    write-host ( "# Problem duration " + [string]($LastLineTimeSpanPb - $FirstLineTimeSpanPb ).TotalSeconds)
                    write-host "" 
                    $inpb = $false;
                } 
            }
            $elapsedfromwpr =  ("{0:N6}" -f $FromStartWPR).PadLeft(11)
            if( $inpb) { $in = "##"} else { $in = "  " }
            $elapsedfrompb = ("{0:N6}" -f  $FromStartLog).PadLeft(11)
            $format = "{0}#{1}#{2}# {3} " 
            $result += ($format  -f $in,$elapsedfrompb, $elapsedfromwpr, $line )
        }

    
        $newfilename = $file +".inpb.txt"
        write-host -ForegroundColor Black -BackgroundColor Green "Results in $newfilename "
        $result | out-file -Force -Encoding ascii -FilePath $newfilename

}
write-host ""
write-host "transform-InsightLog function imported in your powershell sesssion"
write-host "Use get-help transform-InsightLog -full to get more information"
write-host 'Function Usage : transform-InsightLog .\enduser_embedded-!FMT.txt -WPRInit "2020/02/28 17:18:21.4794054" -FirstLinePb 8079 -EndLinePb 8689'


