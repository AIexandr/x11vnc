#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"

#
# Copyright (c) 2006 by Karl J. Runge <runge@karlrunge.com>
#
# ssl_tightvncviewer.tcl: gui wrapper to the , etc. programs in this
# ssl_tightvncviewerpackage. Also sets up service port forwarding.
#

set buck_zero $argv0

proc center_win {w} {
	set W [winfo screenwidth  $w]
	set W [expr $W + 1]
	wm geometry $w +$W+0
	update
	set x [expr [winfo screenwidth  $w]/2 - [winfo width  $w]/2]
	set y [expr [winfo screenheight $w]/2 - [winfo height $w]/2]
	wm geometry $w +$x+$y
	update
}

proc apply_bg {w} {
	global is_windows system_button_face
	if {$is_windows && $system_button_face != ""} {
		catch {$w configure -bg "$system_button_face"}
	}
}

proc scroll_text {fr {w 80} {h 35}} {
	global help_font is_windows

	catch {destroy $fr}
	
	frame $fr -bd 0

	eval text $fr.t -width $w -height $h $help_font \
		 -setgrid 1 -bd 2 -yscrollcommand {"$fr.y set"} -relief ridge 

	apply_bg $fr.t

	scrollbar $fr.y -orient v -relief sunken -command "$fr.t yview"
	pack $fr.y -side right -fill y
	pack $fr.t -side top -fill both -expand 1

	focus $fr.t
}

proc scroll_text_dismiss {fr {w 80} {h 35}} {
	global help_font

	scroll_text $fr $w $h

	set up $fr
	regsub {\.[^.]*$} $up "" up

	button $up.d -text "Dismiss" -command "destroy $up"
	bind $up <Escape> "destroy $up"
	pack $up.d -side bottom -fill x
	pack $fr -side top -fill both -expand 1
}

proc help {} {
	catch {destroy .h}
	toplevel .h

	scroll_text_dismiss .h.f

	center_win .h
	wm title .h "SSL TightVNC Viewer Help"

	set msg {
    Enter the VNC host and display in the 'VNC Server' entry box.
    
    It is of the form "host:number", where "host" is the hostname of the
    machine running the VNC Server and "number" is the VNC display number;
    it is often "0".  Examples:

           snoopy:0
           far-away.east:0
           sunray-srv1.west:17
           24.67.132.27:0
    
    Then click on "Connect".  When you do so the STUNNEL program will be
    started locally to provide you with an outgoing SSL tunnel.

    Once the STUNNEL is running, the TightVNC Viewer will be automatically
    started directed to the local SSL tunnel which, in turn, encrypts and
    redirects the connection to the remote VNC server.

    The remote VNC server must support an initial SSL handshake before
    using the VNC protocol (i.e. VNC is tunnelled through the SSL channel
    after it is established).  "x11vnc -ssl ..."  does this, and any VNC
    server can be made to do this by using, e.g., STUNNEL on the remote side.

    Click on "Options ..." if you want to use an *SSH* tunnel instead of
    SSL (then the VNC Server does not need to speak SSL or use STUNNEL).


    Note that on Windows when the Viewer connection is finished you may
    need to terminate STUNNEL manually from the System Tray (right click
    on dark green icon) and selecting "Exit".


    Proxies: If an intermediate proxy is needed to make the SSL connection
    (e.g. web gateway out of a firewall), supply both hosts separated
    by spaces (with the proxy 2nd):

           host:number   gwhost:port 

    E.g.:  far-way.east:0   mygateway.com:8080

    See the ssl_vncviewer description and x11vnc FAQ for info on proxies:

           http://www.karlrunge.com/x11vnc/#ssl_vncviewer
           http://www.karlrunge.com/x11vnc/#faq-ssl-java-viewer-proxy


    If you want to use a SSL Certificate (PEM) file to authenticate yourself
    to the VNC server ("MyCert") or to verify the identity of the VNC Server
    ("ServerCert" or "CertsDir") import the certificate file by clicking
    the "Certs ..." button before connecting.

    Certificate verification is needed to prevent Man In the Middle attacks.
    See the x11vnc documentation: 

           http://www.karlrunge.com/x11vnc/ssl.html

    for how to create and use PEM SSL certificate files.  An easy way is:

           x11vnc -ssl SAVE ...

    where it will print out its automatically generated certificate to
    the screen and that can be safely copied to the viewer side.


    To set other Options, e.g. to use SSH instead of STUNNEL SSL,
    click on the "Options ..." button and read the Help there.

    See these links for more information:

           http://www.karlrunge.com/x11vnc/#faq-ssl-tunnel-ext
           http://www.stunnel.org
           http://www.tightvnc.com


    Tips:

     1) On Unix to get a 2nd GUI (e.g. for a 2nd connection) press Ctrl-N
        on the GUI.  If only the xterm window is visible you can press
        Ctrl-N or try Ctrl-LeftButton -> New SSL_VNC_GUI.  On Windows you
        will have to manually Start a new one: Start -> Run ..., etc.

     2) If you use "user@hostname cmd=SHELL" then you get an SSH shell only:
        no VNC viewer will be launched.  On Windows "user@hostname cmd=PUTTY"
        will try to use putty.exe (better terminal emulation than plink.exe)
        A shortcut for this is Ctrl-S.
}

	.h.f.t insert end $msg
	#raise .h
}

proc help_certs {} {
	catch {destroy .ch}
	toplevel .ch

	scroll_text_dismiss .ch.f 90 33

	center_win .ch
	wm resizable .ch 1 0

	wm title .ch "SSL Certificates Help"

	set msg {
    Only with SSL Certificate verification can Man In the Middle attacks be
    prevented. Otherwise, only passive snooping attacks are prevented with SSL.

    You can specify your own SSL certificate (PEM) file in "MyCert" in which case it
    is used to authenticate you (the viewer) to the remote VNC Server.  If this fails
    the remote VNC Server will drop the connection.
    
    Server certs can be specified in one of two ways:
    
        - A single certificate (PEM) file for a single server
          or a single Certificate Authority (CA)
    
        - A directory of certificate (PEM) files stored in
          the special OpenSSL hash fashion.
    
    
    The former is set via "ServerCert" in this gui.
    The latter is set via "CertsDir" in this gui.
    
    The former corresponds to the "CAfile" STUNNEL parameter.
    The latter corresponds to the "CApath" STUNNEL parameter.
    See stunnel(8) or www.stunnel.org for more information.
    
    If the remote VNC Server fails to authenticate itself with respect to the specified
    certificate(s), then the VNC Viewer (your side) will drop the connection.

    If "Use SSH instead" has been selected then SSL certs are disabled.

    See the x11vnc and STUNNEL documentation for how to create and use PEM
    certificate files:

        http://www.karlrunge.com/x11vnc/#faq-ssl-tunnel-ext
        http://www.karlrunge.com/x11vnc/ssl.html
        http://www.stunnel.org
}

	.ch.f.t insert end $msg
	#raise .ch
}

proc help_opts {} {
	catch {destroy .oh}
	toplevel .oh

	scroll_text_dismiss .oh.f

	center_win .oh

	wm title .oh "SSL Viewer Options Help"

set msg {
  Use SSH:  Instead of using STUNNEL SSL, use ssh(1) for the encrypted
            tunnel.  You must be able to log in via ssh to the remote host.

            On Unix the cmdline ssh(1) program will be run in an xterm
            for authentication, etc. On Windows the cmdline plink.exe
            program will be launched in a Windows Console window.

            You can set the "VNC Server" to "user@host:disp" to indicate
            ssh should log in as "user" on "host".  On Windows you must
            always supply the "user@" part (due to a plink deficiency). E.g.:

                  fred@far-away.east:0

            If a gateway machine must be used (e.g. to enter a firewall;
            the VNC Server is not running on it), put something like this
            in the "VNC Server" entry box:

                  workstation:0   user@gateway-host:port
  
            ssh is used to login to user@gateway-host and then a -L port
            redirection is set up to go to workstation:0 from gateway-host.
            ":port" is optional, use it if the gateway-host SSH port is
            not the default value 22.

            At the very end of the entry box, you can also append a
            cmd=... string to indicate that command should be run via ssh
            on the remote machine instead of the default "sleep 15".  E.g.:

                  user@host:0   cmd=x11vnc -nopw -display :0

            (if a gateway is also needed, put it just before the cmd=...)

            Trick: If you use "cmd=SHELL" then you get an SSH shell only:
            no VNC viewer will be launched.  On Windows "cmd=PUTTY" will
            try to use putty.exe (better terminal emulation than plink.exe)
            Ctrl-S is a shortcut for this.

  Use SSH and SSL: Tunnel the SSL connection through a SSH tunnel.  Use this
            if you want end-to-end SSL and must use a SSH gateway (e.g. to
            enter a firewall) or if additional SSH port redirs are required
            (CUPS, Sound, SMB tunnelling: See Advanced options).


  Putty PW:  On Windows only: use the supplied password for plink SSH logins.
             Unlike the other options the value is not saved when 'Save
             Profile' is used.  This feature useful when options under
             "Advanced" are set that require 2 SSH's: you just have
             to type the password once in this entry box.  The bundled
             pagent.exe and puttygen.exe programs can also be used to avoid
             repeatedly entering passwords (note this requires setting up
             and distributing SSH keys).  Start up pagent.exe or puttygen.exe
             and read the instructions there.
                
  ssh-agent: On Unix only: restart the GUI in the presence of ssh-agent(1)
             (e.g. in case you forgot to start your agent before starting
             this GUI).  An xterm will be used to enter passphrases, etc.
             This can avoid repeatedly entering passphrases for the
             SSH logins (note this requires setting up and distributing
             SSH keys).


  View Only:               Have VNC Viewer ignore mouse and keyboard input.
  
  Fullscreen:              Start the VNC Viewer in fullscreen mode.
  
  Raise On Beep:           Deiconify viewer when bell rings.
  
  Use 8bit color:          Request a very low-color pixel format.
  
  Cursor Alphablending:    Use the x11vnc alpha hack for translucent cursors
                           (requires Unix, 32bpp and same endianness)
  
  Use XGrabServer:         On Unix only, use the XGrabServer workaround for
                           old window managers.

  Do not use JPEG:         Do not use the jpeg aspect of the tight encoding.

  Compress Level/Quality:  Set TightVNC encoding parameters.


  Save and Load:   You can Save the current settings by clicking on Save
                   Profile (.vnc file) and you can also read in a saved one
                   with Load Profile.

  Clear Options:   Set all options to their defaults (i.e. unset).

  Advanced:        Bring up the Advanced options dialog.
}
	.oh.f.t insert end $msg
	#raise .oh
}

proc win_nokill_msg {} {
	global help_font is_windows system_button_face
	catch {destroy .w}
	toplevel .w

	eval text .w.t -width 60 -height 11 $help_font
	button .w.d -text "Dismiss" -command {destroy .w}
	pack .w.t .w.d -side top -fill x

	apply_bg .w.t

	center_win .w
	wm resizable .w 1 0

	wm title .w "SSL Viewer: Warning"

	set msg {
    The TightVNC Viewer has exited.
    
    You will need to terminate STUNNEL manually.
    
    To do this go to the System Tray and right-click on the STUNNEL
    icon (dark green).  Then click "Exit".
    
    You can also double click on the STUNNEL icon to view the log
    for error messages and other information.
}
	.w.t insert end $msg
	#raise .w
}

proc win_kill_msg {pids} {
	global terminate_pids
	global help_font
	catch {destroy .w}
	toplevel .w

	eval text .w.t -width 72 -height 19 $help_font
	button .w.d -text "Dismiss" -command {destroy .w; set terminate_pids no}
	button .w.k -text "Terminate STUNNEL" -command {destroy .w; set terminate_pids yes}
	pack .w.t .w.k .w.d -side top -fill x

	apply_bg .w.t

	center_win .w
	wm resizable .w 1 0

	wm title .w "SSL Viewer: Warning"

	set msg {
    The TightVNC Viewer has exited.
    
    We can terminate the following still running STUNNEL process(es):
    
}
	append msg "         $pids\n"

	append msg {
    Click on the "Terminate STUNNEL" button below to do so.
    
    Before terminating STUNNEL you can double click on the STUNNEL
    Tray icon to view its log for error messages and other information.

    Note: You may STILL need to terminate STUNNEL manually if we are
    unable to kill it.  To do this go to the System Tray and right-click
    on the STUNNEL icon (dark green).  Then click "Exit".  You will
    probably also need to hover the mouse over the STUNNEL Tray Icon to
    make the Tray notice STUNNEL is gone...
}
	.w.t insert end $msg
	#raise .w
}

proc win9x_plink_msg {file} {
	catch {destroy .pl}
	global help_font win9x_plink_msg_done
	toplevel .pl

	eval text .pl.t -width 90 -height 26 $help_font
	button .pl.d -text "OK" -command {destroy .pl; set win9x_plink_msg_done 1}
	wm protocol .pl WM_DELETE_WINDOW {catch {destroy .pl}; set win9x_plink_msg_done 1}
	pack .pl.t .pl.d -side top -fill x

	apply_bg .pl.t

	center_win .pl
	wm resizable .pl 1 0

	wm title .pl "SSL Viewer: Win9x Warning"

	set msg {
    Due to limitations on Window 9x you will have to manually start up
    a COMMAND.COM terminal and paste in the following command:

}
	set pwd [pwd]
	regsub -all {/} $pwd "\\" pwd
	append msg "        $pwd\\$file\n"  

	append msg {
    The reason for this is a poor Console application implementation that
    affects many text based applications.
    
    To start up a COMMAND.COM terminal, click on the Start -> Run, and then
    type COMMAND in the entry box and hit Return or click OK.

    To select the above command, highlight it with the mouse and then press
    Ctrl-C.  Then go over the the COMMAND.COM window and click on the
    Clipboard paste button.  Once pasted in, press Return to run the script.
    
    This will start up a PLINK.EXE ssh login to the remote computer,
    and after you log in successfully and indicate (QUICKLY!!) that the
    connection is OK by clicking OK in this dialog. If the SSH connection
    cannot be autodetected you will ALSO need to click "Success" in the
    "plink ssh status?" dialog, the VNC Viewer will be started going
    through the SSH tunnel.
}
	.pl.t insert end $msg
	wm deiconify .pl
}

proc mesg {str} {
	set maxx 53
	if {[string length $str] > $maxx} {
		set str [string range $str 0 $maxx]
		append str " ..."
	}
	.l configure -text $str
	update
}

proc get_ssh_hp {str} {
	set str [string trim $str]
	regsub {[ 	].*$} $str "" str
	return $str
}

proc get_ssh_cmd {str} {
	set str [string trim $str]
	if [regexp {cmd=(.*$)} $str m cmd] {
		set cmd [string trim $cmd]
		regsub -nocase {^%x11vncr$} $cmd "x11vnc -nopw -display none -rawfb rand" cmd
		regsub -nocase {^%x11vnc$}  $cmd "x11vnc -nopw -display none -rawfb null" cmd
		return $cmd
	} else {
		return ""
	}
}

proc get_ssh_proxy {str} {
	set str [string trim $str]
	regsub {cmd=(.*$)} $str "" str
	set str [string trim $str]
	if { ![regexp {[ 	]} $str]} {
		return ""
	}
	regsub {^.*[ 	][ 	]*} $str "" str
	return $str
}

proc set_defaults {} {
	global mycert svcert crtdir
	global use_alpha use_grab use_ssh use_sshssl use_viewonly use_fullscreen use_bgr233
	global use_nojpeg use_raise_on_beep use_compresslevel use_quality
	global compresslevel_text quality_text
	global use_cups use_sound use_smbmnt
	global cups_local_server cups_remote_port cups_manage_rcfile
	global cups_local_smb_server cups_remote_smb_port
	global change_vncviewer change_vncviewer_path vncviewer_realvnc4
	global additional_port_redirs additional_port_redirs_list
	global sound_daemon_remote_cmd sound_daemon_remote_port sound_daemon_kill sound_daemon_restart
	global sound_daemon_local_cmd sound_daemon_local_port sound_daemon_local_kill sound_daemon_local_start 
	global smb_su_mode smb_mount_list
	global use_port_knocking port_knocking_list

	set use_ssh 0
	set use_sshssl 0
	putty_pw_entry check

	set use_viewonly 0
	set use_fullscreen 0
	set use_raise_on_beep 0
	set use_bgr233 0
	set use_alpha 0
	set use_grab 0
	set use_nojpeg 0
	set use_compresslevel "default"
	set use_quality "default"
	set compresslevel_text "Compress Level: $use_compresslevel"
	set quality_text "Quality: $use_quality"

	set mycert ""
	set svcert ""
	set crtdir ""

	set use_cups 0
	set use_sound 0
	set use_smbmnt 0

	set change_vncviewer 0 
	set change_vncviewer_path "" 
	set cups_manage_rcfile 0 
	set vncviewer_realvnc4 0

	set additional_port_redirs 0
	set additional_port_redirs_list ""

	set cups_local_server ""
	set cups_remote_port ""
	set cups_local_smb_server ""
	set cups_remote_smb_port ""

	set smb_su_mode "su"
	set smb_mount_list ""

	set sound_daemon_remote_cmd ""
	set sound_daemon_remote_port ""
	set sound_daemon_kill 0
	set sound_daemon_restart 0

	set sound_daemon_local_cmd ""
	set sound_daemon_local_port ""
	set sound_daemon_local_start 0
	set sound_daemon_local_kill 0

	set use_port_knocking 0
	set port_knocking_list ""
}

proc do_viewer_windows {n} {
	global use_alpha use_grab use_ssh use_sshssl use_viewonly use_fullscreen use_bgr233
	global use_nojpeg use_raise_on_beep use_compresslevel use_quality
	global change_vncviewer change_vncviewer_path vncviewer_realvnc4

	set cmd "vncviewer"
	if {$change_vncviewer && $change_vncviewer_path != ""} {
		set cmd [string trim $change_vncviewer_path]
		regsub -all {\\} $cmd {/} cmd
		if {[regexp {[ \t]} $cmd]} {
			if {[regexp -nocase {\.exe$} $cmd]} {
				if {! [regexp {["']} $cmd]} { #"
					# hmmm, not following instructions, are they?
					set cmd "\"$cmd\""
				}
			}
		}
	}
	if {$use_viewonly} {
		if {$vncviewer_realvnc4} {
			append cmd " viewonly=1"
		} else {
			append cmd " /viewonly"
		}
	}
	if {$use_fullscreen} {
		if {$vncviewer_realvnc4} {
			append cmd " fullscreen=1"
		} else {
			append cmd " /fullscreen"
		}
	}
	if {$use_bgr233} {
		if {$vncviewer_realvnc4} {
			append cmd " lowcolourlevel=1"
		} else {
			append cmd " /8bit"
		}
	}
	if {$use_nojpeg} {
		if {! $vncviewer_realvnc4} {
			append cmd " /nojpeg"
		}
	}
	if {$use_raise_on_beep} {
		if {! $vncviewer_realvnc4} {
			append cmd " /belldeiconify"
		}
	}
	if {$use_compresslevel != "" && $use_compresslevel != "default"} {
		if {$vncviewer_realvnc4} {
			append cmd " zliblevel=$use_compresslevel"
		} else {
			append cmd " /compresslevel $use_compresslevel"
		}
	}
	if {$use_quality != "" && $use_quality != "default"} {
		if {! $vncviewer_realvnc4} {
			append cmd " /quality $use_quality"
		}
	}
	append cmd " localhost:$n"
	
	mesg $cmd
	set emess ""
	set rc [catch {eval exec $cmd} emess]
	if {$rc != 0} {
		tk_messageBox -type ok -icon error -message $emess -title "Error: $cmd"
	}
}

proc get_netstat {} {
	set ns ""
	catch {set ns [exec netstat -an]}
	return $ns
}

proc get_ipconfig {} {
	global is_win9x
	set ip ""
	if {! $is_win9x} {
		catch {set ip [exec ipconfig]}
		return $ip
	}

	set file "ip"
	append file [pid]
	append file ".txt"

	catch {[exec winipcfg /Batch $file]}

	if [file exists $file] {
		set fh [open $file "r"]
		while {[gets $fh line] > -1} {
			append ip "$line\n"
		}
		close $fh
		catch {file delete $file}
	}
	return $ip
}

proc guess_nat_ip {} {
	global save_nat last_save_nat
	set s ""

	if {! [info exists save_nat]} {
		set save_nat ""
		set last_save_nat 0
	}
	if {$save_nat != ""} {
		set now [clock seconds]
		if {$now < $last_save_nat + 45} {
			return $save_nat
		}
	}
	set s ""
	catch {set s [socket "www.whatismyip.com" 80]}
	set ip "unknown"
	if {$s != ""} {
		fconfigure $s -buffering none
		puts $s "GET / HTTP/1.1"
		puts $s "Host: www.whatismyip.com"
		puts $s "Connection: close"
		puts $s ""
		flush $s
		set on 0
		while { [gets $s line] > -1 } {
			if {! $on && [regexp {<HEAD>}  $line]} {set on 1}
			if {! $on && [regexp {<HTML>}  $line]} {set on 1}
			if {! $on && [regexp {<TITLE>} $line]} {set on 1}
			if {! $on} {
				continue;
			}
			if [regexp {([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*)} $line ip] {
				break
			}
		}
		close $s
	}
	if {$ip != "unknown"} {
		set save_nat $ip
		set last_save_nat [clock seconds]
	}
	return $ip
}

proc guess_ip {} {
	global env is_windows
	if {! $is_windows} {
		set out ""
		set out [get_hostname]
		if {$out != ""} {
			set hout ""
			catch {set hout [exec host $out]}
			if {$hout != ""} {
				if [regexp {has address ([.0-9][.0-9]*)} $hout mvar ip] {
					set ip [string trim $ip]
					return $ip
				}
			}
		}
		return ""
	} else {
		set out [get_ipconfig]
		set out [string trim $out]
		if {$out == ""} {
			return ""
		}
		foreach line [split $out "\n\r"] {
			if {[regexp -nocase {IP Address.*:[ \t]*([.0-9][.0-9]*)} $line mvar ip]} {
				set ip [string trim $ip]
				if [regexp {^[.0]*$} $ip] {
					continue
				}
				if [regexp {127\.0\.0\.1} $ip] {
					continue
				}
				if {$ip != ""} {
					return $ip
				}
			}
		}
	}
}

proc windows_start_sound_daemon {file} {
	global env
	global use_sound sound_daemon_local_cmd sound_daemon_local_start

	regsub {\.bat} $file "snd.bat" file2
	set fh2 [open $file2 "w"]

	puts $fh2 $sound_daemon_local_cmd
	puts $fh2 "del $file2"
	close $fh2

	mesg "Starting SOUND daemon..."
	if [info exists env(COMSPEC)] {
		exec $env(COMSPEC) /c $file2 &
	} else {
		exec cmd.exe /c $file2 &
	}
	after 1500
}

proc windows_stop_sound_daemon {} {
	global env is_win9x
	global use_sound sound_daemon_local_cmd sound_daemon_local_start

	set cmd [string trim $sound_daemon_local_cmd]

	regsub {[ \t].*$} $cmd "" cmd
	regsub {^.*\\} $cmd "" cmd
	regsub {^.*/} $cmd "" cmd

	if {$cmd == ""} {
		return
	}

	set output [get_task_list]
	
	foreach line [split $output "\n\r"] {
		if [regexp "$cmd" $line] {
			if [regexp {(-?[0-9][0-9]*)} $line m p] {
				set pids($p) $line
			}
		}
	}

	set count 0
	foreach pid [array names pids] {
		mesg "Stopping SOUND pid: $pid"
		if {$is_win9x} {
			catch {exec w98/kill.exe /f $pid}
		} else {
			catch {exec tskill.exe $pid}
		}
		if {$count == 0} {
			after 1200
		} else {
			after 500
		}
		incr count
	}
}

proc contag {} {
	global concount
	if {! [info exists concount]} {
		set concount 0
	}
	incr concount
	set str [pid]
	set str "-$str-$concount"
}

proc launch_windows_ssh {hp file n} {
	global is_win9x 
	global use_sshssl use_ssh putty_pw

	set hpnew  [get_ssh_hp $hp]
	set proxy  [get_ssh_proxy $hp]
	set sshcmd [get_ssh_cmd $hp]

	set vnc_host "localhost"
	set vnc_disp $hpnew
	regsub {^.*:} $vnc_disp "" vnc_disp

	if {![regexp {^[0-9][0-9]*$} $vnc_disp]} {
		if {[regexp {cmd=SHELL} $hp]} {
			;
		} elseif {[regexp {cmd=PUTTY} $hp]} {
			;
		} else {
			mesg "Bad vncdisp, missing :0 ?, $vnc_disp"
			bell
			return 0
		}
	}

	if {$vnc_disp < 200} {
		set vnc_port [expr $vnc_disp + 5900]
	} else {
		set vnc_port $vnc_disp
	}


	set ssh_port 22
	set ssh_host $hpnew
	regsub {:.*$} $ssh_host "" ssh_host

	if {$proxy != ""} {
		set ssh_host $proxy
		regsub {:.*$} $ssh_host "" ssh_host
		set ssh_port $proxy
		regsub {^.*:} $ssh_port "" ssh_port
		if {$ssh_port == ""} {
			set ssh_port 22
		}
		set vnc_host $hpnew
		regsub {:.*$} $vnc_host "" vnc_host
	}

	if {![regexp {^[^ 	][^ 	]*@} $ssh_host]} {
		mesg "You must supply a username: user@host..."
		bell
		return 0
	}

	set verb "-v"

	set pwd ""
	if {$is_win9x} {
		set pwd [pwd]
		regsub -all {/} $pwd "\\" pwd
	}

	set use [expr $n + 5900]

	set_smb_mounts
	
	global use_smbmnt use_sound sound_daemon_kill 
	set do_pre 0
	if {$use_smbmnt}  {
		set do_pre 1
	} elseif {$use_sound && $sound_daemon_kill} {
		set do_pre 1
	}

	global skip_pre
	if {$skip_pre} {
		set do_pre 0
		set skip_pre 0
	}

	set pw ""
	if {$putty_pw != ""} {
		if {! [regexp {"} $putty_pw]} {  #"
			set pw "                                                      -pw                                                   \"$putty_pw\""
		}
	}

	set tag [contag]

	set file_pre ""
	set file_pre_cmd ""
	if {$do_pre} {
		set setup_cmds [ugly_setup_scripts pre $tag] 
		
		if {$setup_cmds != ""} {
			regsub {\.bat} $file "pre.cmd" file_pre_cmd
			set fh [open $file_pre_cmd "w"]
			puts $fh "$setup_cmds sleep 10; "
			close $fh

			regsub {\.bat} $file "pre.bat" file_pre
			set fh [open $file_pre "w"]
			set plink_str "plink.exe -ssh -C -P $ssh_port -m $file_pre_cmd $verb -t" 

			global smb_redir_0
			if {$smb_redir_0 != ""} {
				append plink_str " $smb_redir_0"
			}

			append plink_str "$pw $ssh_host" 

			if {$pw != ""} {
				puts $fh "echo off"
			}
			puts $fh $plink_str

			if {$file_pre_cmd != ""} {
				puts $fh "del $file_pre_cmd"
			}
			puts $fh "del $file_pre"

			close $fh
		}
	}

	if {$is_win9x} {
		set sleep 35
	} else {
		set sleep 20
	}

	set setup_cmds [ugly_setup_scripts post $tag] 

	set do_shell 0
	if {$sshcmd == "SHELL"} {
		set setup_cmds ""
		set sshcmd {$SHELL}
		set do_shell 1
	} elseif {$sshcmd == "PUTTY"} {
		set setup_cmds ""
		set do_shell 1
	}

	set file_cmd ""
	if {$setup_cmds != ""} {
		regsub {\.bat} $file ".cmd" file_cmd
		set fh_cmd [open $file_cmd "w"]

		set str $setup_cmds
		if {$sshcmd != ""} {
			append str " $sshcmd; "
		} else {
			append str " sleep $sleep; "
		}
		puts $fh_cmd $str
		close $fh_cmd

		set sshcmd $setup_cmds
	}

	if {$sshcmd == ""} {
		set pcmd "echo; echo SSH connected OK.; echo If this state is not autodetected,; echo Go Click the Success button."
		set sshcmd "$pcmd; sleep $sleep"
	}

	global use_sound sound_daemon_local_cmd sound_daemon_local_start
	if {! $do_shell && ! $is_win9x && $use_sound && $sound_daemon_local_start && $sound_daemon_local_cmd != ""} {
		windows_start_sound_daemon $file
	}

	set fh [open $file "w"]
	if {$is_win9x} {
		puts $fh "cd $pwd"
		if {$file_pre != ""} {
			puts $fh "echo Press Ctrl-C --HERE-- when done with the Pre-Command shell work."
			puts $fh "start /w command.com /c $file_pre"
		}
	}

	global use_cups use_smbmnt
	set extra_redirs ""
	if {$use_cups} {
		append extra_redirs [get_cups_redir]
	}
	if {$use_sound} {
		append extra_redirs [get_sound_redir]
	}
	global additional_port_redirs
	if {$additional_port_redirs} {
		append extra_redirs [get_additional_redir]
	}

	set plink_str "plink.exe -ssh -P $ssh_port $verb -L $use:$vnc_host:$vnc_port $extra_redirs -t" 
	if {$extra_redirs != ""} {
		regsub {exe} $plink_str "exe -C" plink_str
	}
	if {$do_shell} {
		if {$sshcmd == "PUTTY"} {
		    if {$is_win9x} {
			set plink_str "putty.exe -ssh -C -P $ssh_port $extra_redirs -t $pw $ssh_host" 
		    } else {
			set plink_str "start \"putty $ssh_host\" putty.exe -ssh -C -P $ssh_port $extra_redirs -t $pw $ssh_host" 
		    }
		} else {
			set plink_str "plink.exe -ssh -C -P $ssh_port $extra_redirs -t $pw $ssh_host" 
			append plink_str { "$SHELL"}
		}
	} elseif {$file_cmd != ""} {
		append plink_str " -m $file_cmd$pw $ssh_host"
	} else {
		append plink_str "$pw $ssh_host \"$sshcmd\""
	}

	if {$pw != ""} {
		puts $fh "echo off"
	}
	puts $fh $plink_str
	if {$file_cmd != ""} {
		puts $fh "del $file_cmd"
	}
	puts $fh "del $file"
	close $fh

	catch {destroy .o}
	catch {destroy .oa}

	do_port_knock $ssh_host

	if {$is_win9x} {
		wm withdraw .
		update
		win9x_plink_msg $file
		global win9x_plink_msg_done
		set win9x_plink_msg_done 0
		vwait win9x_plink_msg_done
	} else {
		global env
		set com "cmd.exe"
		if [info exists env(COMSPEC)] {
			set com $env(COMSPEC)
		}

		if {$file_pre != ""} {
			exec $com /c $file_pre &
			set sl 0
			if {$use_smbmnt}  {
				global smb_su_mode
				if {$smb_su_mode == "su"} {
					set sl [expr $sl + 15]
				} elseif {$smb_su_mode == "sudo"} {
					set sl [expr $sl + 15]
				} else {
					set sl [expr $sl + 3]
				}
			}
			if {$pw == ""} {
				set sl [expr $sl + 5]
			}

			set sl [expr $sl + 5]
			set st [clock seconds]
			set dt 0
			global entered_gui_top
			set entered_gui_top 0

			while {$dt < $sl} {
				after 100
				set dt [clock seconds]
				set dt [expr $dt - $st]
				mesg "Click or Enter when done with 1st SSH $dt/$sl"
				update
				update idletasks
				if {$entered_gui_top != 0 && $dt >= 3} {
					mesg "Running 2nd SSH now ..."
					after 1000
					break
				}
			}
			mesg "Running 2nd SSH ..."
		}

		wm withdraw .
		update
		exec $com /c $file &
		after 1000
	}

	if {$do_shell} {
		wm deiconify .
		return 1
	}

	catch {destroy .plink}
	toplevel .plink
	wm title .plink "plink SSH status?"
	set wd 37
	label .plink.l1 -anchor w -text "Login via plink/ssh to the remote server" -width $wd
	label .plink.l2 -anchor w -text "(supply username and password as needed)." -width $wd
	label .plink.l3 -anchor w -text "" -width $wd
	label .plink.l4 -anchor w -text "After ssh is set up, AND if the connection" -width $wd
	label .plink.l5 -anchor w -text "success is not autodetected, please click" -width $wd
	label .plink.l6 -anchor w -text "one of these buttons:" -width $wd
	global plink_status
	button .plink.fail -text "Failed" -command {destroy .plink; set plink_status no}
	button .plink.ok   -text "Success" -command {destroy .plink; set plink_status yes}
	pack .plink.l1 .plink.l2 .plink.l3 .plink.l4 .plink.l5 .plink.l6 .plink.fail .plink.ok -side top -fill x

	wm geometry .plink +700+500
	wm deiconify .plink
	set plink_status ""
	set waited 0
	set cnt 0
	while {$waited < 30000} {
		after 500
		update
		set ns [get_netstat]
		set re ":$use"
		append re {[ 	][ 	]*[0:.][0:.]*[ 	][ 	]*LISTEN}
		if [regexp $re $ns] {
			set plink_status yes
		}
		if {$plink_status != ""} {
			catch {destroy .plink}
			break
		}

		if {$waited == 0} {
			wm deiconify .plink
		}
		set waited [expr "$waited + 500"]

		incr cnt
		if {$cnt >= 12} {
			set cnt 0
			#catch {wm deiconify .plink}
		}
	}
	if {$plink_status == ""} {
		vwait plink_status
	}

	if {$use_sshssl} {
		global launch_windows_ssh_files 
		if {$file != ""} {
			append launch_windows_ssh_files "$file "
		}
		if {$file_pre != ""} {
			append launch_windows_ssh_files "$file_pre "
		}
		if {$file_pre_cmd != ""} {
			append launch_windows_ssh_files "$file_pre_cmd "
		}
		regsub { *$} $launch_windows_ssh_files "" launch_windows_ssh_files
		return 1
	}

	if {$plink_status != "yes"} {
		wm deiconify .
	} else {
		after 1000
		do_viewer_windows $n
		wm deiconify .
		mesg "Disconnected from $hp"
	}

	if {$file != ""} {
		catch {file delete $file}	
	}
	if {$file_pre != ""} {
		catch {file delete $file_pre}	
	}
	if {$file_pre_cmd != ""} {
		catch {file delete $file_pre_cmd}	
	}

	global sound_daemon_local_kill
	if {! $is_win9x && $use_sound && $sound_daemon_local_kill && $sound_daemon_local_cmd != ""} {
		windows_stop_sound_daemon
	}
	return 1
}

proc check_ssh_needed {} {
	global use_cups use_sound use_smbmnt
	global sound_daemon_remote_cmd sound_daemon_remote_port sound_daemon_kill sound_daemon_restart
	global sound_daemon_local_cmd sound_daemon_local_port sound_daemon_local_kill sound_daemon_local_start 
	global cups_local_server cups_remote_port cups_manage_rcfile
	global cups_local_smb_server cups_remote_smb_port
	global smb_su_mode smb_mount_list
	global use_ssh use_sshssl
	
	if {$use_ssh || $use_sshssl} {
		return
	}
	set must 0
	if {$use_cups} {
		if {$cups_local_server != ""} {set must 1}
		if {$cups_remote_port != ""} {set must 1}
		if {$cups_local_smb_server != ""} {set must 1}
		if {$cups_remote_smb_port != ""} {set must 1}
		if {$cups_manage_rcfile != ""} {set must 1}
	}
	if {$use_sound} {
		if {$sound_daemon_remote_cmd != ""} {set must 1}
		if {$sound_daemon_remote_port != ""} {set must 1}
		if {$sound_daemon_kill} {set must 1}
		if {$sound_daemon_restart} {set must 1}
		if {$sound_daemon_local_cmd != ""} {set must 1}
		if {$sound_daemon_local_port != ""} {set must 1}
		if {$sound_daemon_local_kill} {set must 1}
		if {$sound_daemon_local_start} {set must 1}
	}
	if {$use_smbmnt} {
		if {[regexp {//} $smb_mount_list]} {set must 1}
	}
	if {$must} {
		set use_sshssl 1
		putty_pw_entry check
		mesg "Enabling \"Use SSH and SSL\" mode for port redir"
		update
		bell
		after 4000
	}
}

proc set_smb_mounts {} {
	global smb_redir_0 smb_mounts use_smbmnt 
	
	set smb_redir_0 ""
	set smb_mounts ""
	if {$use_smbmnt} {
		set l2 [get_smb_redir]
		set smb_redir_0 [lindex $l2 0]
		set smb_redir_0 [string trim $smb_redir_0]
		set smb_mounts  [lindex $l2 1]
	}
}

proc xterm_center_geometry {} {
	set sh [winfo screenheight .]
	set sw [winfo screenwidth .]
	set gw 500
	set gh 300
	set x [expr $sw/2 - $gw/2]
	set y [expr $sh/2 - $gh/2]
	if {$x < 0} {
		set x 10
	}
	if {$y < 0} {
		set y 10
	}

	return "+$x+$y"
}

proc smbmnt_wait {tee} {
	if {$tee != ""} {
		set start [clock seconds]
		set cut 30
		while {1} {
			set now [clock seconds]
			if {$now > $start + $cut} {
				break;
			}
			if [file exists $tee] {
				set sz 0
				catch {set sz [file size $tee]}
				if {$sz > 50} {
					set cut 50
				}
			}
			set g ""
			catch {set g [exec grep vnc-helper-exiting $tee]}
			if [regexp {vnc-helper-exiting} $g] {
				break
			}
			after 1000
		}
		catch {file delete $tee}
	} else {
		global smb_su_mode
		if {$smb_su_mode == "su"} {
			after 15000
		} elseif {$smb_su_mode == "sudo"} {
			after 10000
		}
	}
}

proc do_unix_pre {tag proxy hp pk_hp}  {
	global env smb_redir_0 use_smbmnt
	global did_port_knock
	
	set setup_cmds [ugly_setup_scripts pre $tag] 
	set c "ssl_vncviewer -ssh"

	if {$proxy == ""} {
		set pxy $hp
		regsub {:.*$} $pxy "" pxy
		set c "$c -proxy '$pxy'"
	} else {
		set c "$c -proxy '$proxy'"
	}

	if {$setup_cmds != ""} {
		set env(SSL_VNCVIEWER_SSH_CMD) "$setup_cmds sleep 10"
		set env(SSL_VNCVIEWER_SSH_ONLY) 1
		if {$smb_redir_0 != ""} {
			set c "$c -sshargs '$smb_redir_0'"
		}

		do_port_knock $pk_hp
		set did_port_knock 1

		if {$use_smbmnt} {
			set title "SSL VNC Viewer $hp -- SMB MOUNTS"
		} else {
			set title "SSL VNC Viewer $hp -- Pre Commands"
		}

		set tee ""
		if {$use_smbmnt} {
			set tee $env(HOME) 
			append tee "/.tee-etv$tag"
			set fh ""
			catch {set fh [open $tee "w"]}
			if {$fh == ""} {
				set tee ""
			} else {
				close $fh
				set c "$c | tee $tee"
			}
		}

		exec xterm -geometry "80x25+100+100" \
		    -title "$title" \
		    -e sh -c "set -xv; $c" &

		set env(SSL_VNCVIEWER_SSH_CMD) ""
		set env(SSL_VNCVIEWER_SSH_ONLY) ""

		if {$use_smbmnt} {
			smbmnt_wait $tee
		} else {
			after 2000
		}
	}
}

proc launch_unix {hp} {
	global mycert svcert crtdir env
	global use_alpha use_grab use_ssh use_sshssl use_viewonly use_fullscreen use_bgr233
	global use_nojpeg use_raise_on_beep use_compresslevel use_quality
	global change_vncviewer change_vncviewer_path vncviewer_realvnc4
	global additional_port_redirs additional_port_redirs_list
	global use_cups use_sound use_smbmnt
	global smb_redir_0 smb_mounts
	global sound_daemon_remote_cmd sound_daemon_remote_port sound_daemon_kill sound_daemon_restart
	global sound_daemon_local_cmd sound_daemon_local_port sound_daemon_local_kill sound_daemon_local_start 

	set cmd ""

	if [regexp {cmd=} $hp] {
		if {! $use_ssh && ! $use_sshssl} {
			set use_ssh 1
		}
	}
	check_ssh_needed

	set_smb_mounts

	global did_port_knock
	set did_port_knock 0
	set pk_hp ""

	if {$use_ssh || $use_sshssl} {
		if {$use_ssh} {
			set cmd "ssl_vncviewer -ssh"
		} else {
			set cmd "ssl_vncviewer -sshssl"
		}
		set hpnew  [get_ssh_hp $hp]
		set proxy  [get_ssh_proxy $hp]
		set sshcmd [get_ssh_cmd $hp]
		set hp $hpnew

		if {$proxy != ""} {
			set cmd "$cmd -proxy '$proxy'"
			set pk_hp $proxy
		}
		if {$pk_hp == ""} {
			set pk_hp $hp
		}

		set do_pre 0
		if {$use_smbmnt}  {
			set do_pre 1
		} elseif {$use_sound && $sound_daemon_kill} {
			set do_pre 1
		}
		global skip_pre
		if {$skip_pre} {
			set do_pre 0
			set skip_pre 0
		}

		set tag [contag]

		if {$do_pre} {
			do_unix_pre $tag $proxy $hp $pk_hp
		}


		set setup_cmds [ugly_setup_scripts post $tag] 

		if {$sshcmd == "SHELL"} {
			set env(SSL_VNCVIEWER_SSH_CMD) {$SHELL}
			set env(SSL_VNCVIEWER_SSH_ONLY) 1
		} elseif {$setup_cmds != ""} {
			set env(SSL_VNCVIEWER_SSH_CMD) "$setup_cmds$sshcmd"
		} else {
			if {$sshcmd != ""} {
				set cmd "$cmd -sshcmd '$sshcmd'"
			}
		}
		
		set sshargs ""
		if {$use_cups} {
			append sshargs [get_cups_redir]
		}
		if {$use_sound} {
			append sshargs [get_sound_redir]
		}
		if {$additional_port_redirs} {
			append sshargs [get_additional_redir]
		}

		set sshargs [string trim $sshargs]
		if {$sshargs != ""} {
			set cmd "$cmd -sshargs '$sshargs'"
			set env(SSL_VNCVIEWER_USE_C) 1
		}
		if {$sshcmd == "SHELL"} {
			set env(SSL_VNCVIEWER_SSH_ONLY) 1
			if {$proxy == ""} {
				set hpt $hpnew
				regsub {:[0-9]*$} $hpt "" hpt
				set cmd "$cmd -proxy '$hpt'"
			}
			set geometry [xterm_center_geometry]
			if {$pk_hp == ""} {
				set pk_hp $hp
			}
			if {! $did_port_knock} {
				do_port_knock $pk_hp
				set did_port_knock 1
			}

			exec xterm -geometry $geometry -title "SHELL to $hp" \
			    -e sh -c "$cmd" &
			set env(SSL_VNCVIEWER_SSH_CMD) ""
			set env(SSL_VNCVIEWER_SSH_ONLY) ""
			set env(SSL_VNCVIEWER_USE_C) ""
			return
		}
	} else {
		set cmd "ssl_tightvncviewer"
		set hpnew  [get_ssh_hp $hp]
		set proxy  [get_ssh_proxy $hp]
		if {$mycert != ""} {
			set cmd "$cmd -mycert '$mycert'"
		}
		if {$svcert != ""} {
			set cmd "$cmd -verify '$svcert'"
		} elseif {$crtdir != ""} {
			set cmd "$cmd -verify '$crtdir'"
		}
		if {$proxy != ""} {
			set cmd "$cmd -proxy '$proxy'"
		}
		set hp $hpnew
	}

	if {$use_alpha} {
		set cmd "$cmd -alpha"
	}
	if {$use_grab} {
		set cmd "$cmd -grab"
	}

	set cmd "$cmd $hp"

	if {$use_viewonly} {
		set cmd "$cmd -viewonly"
	}
	if {$use_fullscreen} {
		set cmd "$cmd -fullscreen"
	}
	if {$use_bgr233} {
		if {$vncviewer_realvnc4} {
			set cmd "$cmd -lowcolourlevel 1"
		} else {
			set cmd "$cmd -bgr233"
		}
	}
	if {$use_nojpeg} {
		if {! $vncviewer_realvnc4} {
			set cmd "$cmd -nojpeg"
		}
	}
	if {! $use_raise_on_beep} {
		if {! $vncviewer_realvnc4} {
			set cmd "$cmd -noraiseonbeep"
		}
	}
	if {$use_compresslevel != "" && $use_compresslevel != "default"} {
		if {$vncviewer_realvnc4} {
			set cmd "$cmd -zliblevel '$use_compresslevel'"
		} else {
			set cmd "$cmd -compresslevel '$use_compresslevel'"
		}
	}
	if {$use_quality != "" && $use_quality != "default"} {
		if {! $vncviewer_realvnc4} {
			set cmd "$cmd -quality '$use_quality'"
		}
	}
	if {$use_ssh || $use_sshssl} {
		# realvnc4 -preferredencoding zrle
		if {$vncviewer_realvnc4} {
			set cmd "$cmd -preferredencoding zrle"
		} else {
			set cmd "$cmd -encodings 'copyrect tight zrle zlib hextile'"
		}
	}

	if {$change_vncviewer && $change_vncviewer_path != ""} {
		global env
		set env(VNCVIEWERCMD) $change_vncviewer_path
	} else {
		set env(VNCVIEWERCMD) ""
	}

	catch {destroy .o}
	catch {destroy .oa}
	wm withdraw .
	update

	if {$sound_daemon_local_start && $sound_daemon_local_cmd != ""} {
		mesg "running: $sound_daemon_local_cmd"
		exec sh -c "$sound_daemon_local_cmd" >& /dev/null </dev/null &
		update
		after 500
	}

	if {$pk_hp == ""} {
		set pk_hp $hp
	}
	if {! $did_port_knock} {
		do_port_knock $pk_hp
		set did_port_knock 1
	}

	set geometry [xterm_center_geometry]
	set xrm1 "*.srinterCommand:true"
	set xrm2 $xrm1
	set xrm3 $xrm1
	if {[info exists env(SSL_VNC_GUI_CMD)]} {
		set xrm1 "*.printerCommand:env XTERM_PRINT=1 $env(SSL_VNC_GUI_CMD)"
		set xrm2 "XTerm*VT100*translations:#override Shift<Btn3Down>:print()\\nCtrl<Key>N:print()"
		set xrm3 "*mainMenu*print*Label:  New SSL_VNC_GUI"
	}
	exec xterm -geometry $geometry -xrm "$xrm1" -xrm "$xrm2" -xrm "$xrm3" \
	    -title "SSL VNC Viewer $hp" \
	    -e sh -c "set -xv; $cmd; set +xv; echo; echo Done. You Can X-out or Ctrl-C this Terminal whenever you like.; echo; echo sleep 15; echo; sleep 15"
	set env(SSL_VNCVIEWER_SSH_CMD) ""
	set env(SSL_VNCVIEWER_USE_C) ""

	if {$sound_daemon_local_kill && $sound_daemon_local_cmd != ""} {
		set daemon [string trim $sound_daemon_local_cmd]
		regsub {^gw[ \t]*} $daemon "" daemon
		regsub {[ \t].*$} $daemon "" daemon
		regsub {^.*/} $daemon "" daemon
		mesg "killing sound daemon: $daemon"
		if {$daemon != ""} {
			catch {exec sh -c "killall $daemon"  >/dev/null 2>/dev/null </dev/null &}
			catch {exec sh -c "pkill -x $daemon" >/dev/null 2>/dev/null </dev/null &}
		}
	}
	wm deiconify .
	mesg "Disconnected from $hp"
}

proc kill_stunnel {pids} {
	global is_win9x env

	set count 0
	foreach pid $pids {
		mesg "killing STUNNEL pid: $pid"
		if {$is_win9x} {
			catch {exec w98/kill.exe /f $pid}
		} else {
			catch {exec tskill.exe $pid}
		}
		if {$count == 0} {
			after 1200
		} else {
			after 500
		}
		incr count
	}
}

proc get_task_list {} {
	global env is_win9x
	
	set output1 ""
	set output2 ""
	if {! $is_win9x} {
		# try for tasklist on XP pro
		catch {set output1 [exec tasklist.exe]}
	}
	catch {set output2 [exec w98/tlist.exe]}

	set output $output1
	append output "\n"
	append output $output2

	return $output
}

proc note_stunnel_pids {when} {
	global env
	global is_win9x pids_before pids_after pids_new

	if {$when == "before"} {
		array unset pids_before
		array unset pids_after
		set pids_new {}
		set pids_before(none) "none"
		set pids_after(none)  "none"
	}

	set output [get_task_list]
	
	foreach line [split $output "\n\r"] {
		if [regexp -nocase {stunnel} $line] {
			if [regexp {(-?[0-9][0-9]*)} $line m p] {
				if {$when == "before"} {
					set pids_before($p) $line
				} else {
					set pids_after($p) $line
				}
			}
		}
	}
	if {$when == "after"} {
		foreach new [array names pids_after] {
			if {! [info exists pids_before($new)]} {
				lappend pids_new $new
			}
		}
	}
}

proc del_launch_windows_ssh_files {} {
	global launch_windows_ssh_files
	
	if {$launch_windows_ssh_files != ""} {
		foreach tf [split $launch_windows_ssh_files] {
			if {$tf == ""} {
				continue
			}
			catch {file delete $tf}
		}
	}
}

proc launch_shell_only {} {
	global vncdisplay is_windows
	global skip_pre

	set hp $vncdisplay
	regsub {cmd=.*$} $vncdisplay "" hp
	set hp [string trim $hp]
	if {$is_windows} {
		append hp " cmd=PUTTY"
	} else {
		append hp " cmd=SHELL"
	}
	set skip_pre 1
	launch $hp
}

proc launch {{hp ""}} {
	global vncdisplay env tcl_platform is_windows
	global mycert svcert crtdir
	global pids_before pids_after pids_new
	global use_ssh use_sshssl

	set debug 0
	if {$hp == ""} {
		set hp [string trim $vncdisplay]
	}

	if {[regexp {^[ 	]*$} $hp]} {
		mesg "No host:disp supplied."
		bell
		return
	}
	if {! [regexp ":" $hp]} {
		if {! [regexp {cmd=} $hp]} {
			append hp ":0"
		}
	}

	mesg "Using: $hp"
	after 600

	if {$debug} {
		mesg "\"$tcl_platform(os)\" | \"$tcl_platform(osVersion)\""
		after 1000
	}
	if {! $is_windows} {
		launch_unix $hp
		return
	}

	if [regexp {cmd=} $hp] {
		if {! $use_ssh && ! $use_sshssl} {
			set use_ssh 1
		}
	}
	check_ssh_needed

	if {! $use_ssh} {
		if {$mycert != ""} {
			if {! [file exists $mycert]} {
				mesg "MyCert does not exist: $mycert"
				bell
				return
			}
		}
		if {$svcert != ""} {
			if {! [file exists $svcert]} {
				mesg "ServerCert does not exist: $svcert"
				bell
				return
			}
		} elseif {$crtdir != ""} {
			if {! [file exists $crtdir]} {
				mesg "CertsDir does not exist: $crtdir"
				bell
				return
			}
		}
	}

	set prefix "stunnel-vnc"
	set suffix "conf"
	if {$use_ssh || $use_sshssl} {
		set prefix "plink-vnc"
		set suffix "bat"
	}

	# we avoid parsing netstat output on Windows (but I guess we do now elsewhere):
	set file ""
	set n ""
	set file2 ""
	set n2 ""
	set now [clock seconds]

	for {set i 30} {$i < 90} {incr i}  {
		set try "$prefix-$i.$suffix"
		if {[file exists $try]}  {
			set mt [file mtime $try]
			set age [expr "$now - $mt"]
			set week [expr "7 * 3600 * 24"]
			if {$age > $week} {
				catch {file delete $file}
			}
		}
		if {! [file exists $try]}  {
			if {$use_sshssl} {
				if {$file != ""} {
					set file2 $try
					set n2 $i
					break
				}
			}
			set file $try
			set n $i
			if {! $use_sshssl} {
				break
			}
		}
	}

	if {$file == ""} {
		mesg "could not find free stunnel file"
		bell
		return
	}

	global launch_windows_ssh_files 
	set launch_windows_ssh_files ""

	set did_port_knock 0

	if {$use_sshssl} {
		set rc [launch_windows_ssh $hp $file2 $n2]
		if {$rc == 0} {
			catch {file delete $file}
			catch {file delete $file2}
			del_launch_windows_ssh_files
			return
		}
		set did_port_knock 1
	} elseif {$use_ssh} {
		launch_windows_ssh $hp $file $n
		return
	}

	if [regexp {[ 	]} $hp] {
		# proxy or cmd case (should not happen? yet?) 
		regsub {[ 	].*$} $hp "" hp2
	} else {
		set list [split $hp ":"] 
		set host [lindex $list 0]
		set disp [lindex $list 1]
		set port [expr "$disp + 5900"]
	}

	set list [split $hp ":"] 
	set host [lindex $list 0]
	set disp [lindex $list 1]
	set port [expr "$disp + 5900"]

	if {$debug} {
		mesg "file: $file"
		after 1000
	}

	set fh [open $file "w"]

	puts $fh "client = yes"
	puts $fh "options = ALL"
	puts $fh "taskbar = yes"
	puts $fh "RNDbytes = 2048"
	puts $fh "RNDfile = bananarand.bin"
	puts $fh "RNDoverwrite = yes"
	puts $fh "debug = 6"
	if {$mycert != ""} {
		if {! [file exists $mycert]} {
			mesg "MyCert does not exist: $mycert"
			bell
			return
		}
		puts $fh "cert = $mycert"
	}
	if {$svcert != ""} {
		if {! [file exists $svcert]} {
			mesg "ServerCert does not exist: $svcert"
			bell
			return
		}
		puts $fh "CAfile = $svcert"
		puts $fh "verify = 2"
	} elseif {$crtdir != ""} {
		if {! [file exists $crtdir]} {
			mesg "CertsDir does not exist: $crtdir"
			bell
			return
		}
		puts $fh "CApath = $crtdir"
		puts $fh "verify = 2"
	}

	puts $fh "\[vnc$n\]"
	set port2 [expr "$n + 5900"] 
	puts $fh "accept = localhost:$port2"

	if {$use_sshssl} {
		set port [expr "$n2 + 5900"]
		puts $fh "connect = localhost:$port"
	} else {
		puts $fh "connect = $host:$port"
	}

	puts $fh "delay = no"
	puts $fh ""
	close $fh

	mesg "Starting STUNNEL on port $port2 ..."
	after 600

	note_stunnel_pids "before"

	set pids [exec stunnel $file &]

	after 1300

	note_stunnel_pids "after"

	if {$debug} {
		after 1000
		mesg "pids $pids"
		after 1000
	} else {
		catch {destroy .o}
		catch {destroy .oa}
		wm withdraw .
	}

	if {! $did_port_knock} {
		do_port_knock $host
		set did_port_knock 1
	}

	do_viewer_windows $n

	del_launch_windows_ssh_files

	catch {file delete $file}

	if {$debug} {
		;
	} else {
		wm deiconify .
	}
	mesg "Disconnected from $hp."

	if {[llength $pids_new] > 0} {
		set plist [join $pids_new ", "]
		global terminate_pids
		set terminate_pids ""
		win_kill_msg $plist
		update
		vwait terminate_pids
		if {$terminate_pids == "yes"} {
			kill_stunnel $pids_new
		}
	} else {
		win_nokill_msg
	}
	mesg "Disconnected from $hp."

	global is_win9x use_sound sound_daemon_local_kill sound_daemon_local_cmd
	if {! $is_win9x && $use_sound && $sound_daemon_local_kill && $sound_daemon_local_cmd != ""} {
		windows_stop_sound_daemon
	}
}

proc get_idir {str} {
	set idir ""
	if {$str != ""} {
		if [file isdirectory $str] {
			set idir $str
		} else {
			set idir [file dirname $str]
		}
	}
	if {$idir == ""} {
		global env
		if [info exists env(HOME)] {
			set t "$env(HOME)/.vnc/certs"	
			if [file isdirectory $t] {
				set idir $t
			}
		}
	}
	if {$idir == ""} {
		set idir [pwd]
	}
	return $idir
}

proc set_mycert {} {
	global mycert
	set idir [get_idir $mycert]
	if {$idir != ""} {
		set mycert [tk_getOpenFile -initialdir $idir]
	} else {
		set mycert [tk_getOpenFile]
	}
	catch {wm deiconify .c}
	update
}

proc set_svcert {} {
	global svcert crtdir
	set idir [get_idir $svcert]
	if {$idir != ""} {
		set svcert [tk_getOpenFile -initialdir $idir]
	} else {
		set svcert [tk_getOpenFile]
	}
	if {$svcert != ""} {
		set crtdir ""
	}
	catch {wm deiconify .c}
	update
}

proc set_crtdir {} {
	global svcert crtdir
	set idir [get_idir $crtdir]
	if {$idir != ""} {
		set crtdir [tk_chooseDirectory -initialdir $idir]
	} else {
		set crtdir [tk_chooseDirectory]
	}
	if {$crtdir != ""} {
		set svcert ""
	}
	catch {wm deiconify .c}
	update
}

proc getcerts {} {
	global mycert svcert crtdir
	global use_ssh use_sshssl
	catch {destroy .c}
	toplevel .c
	wm title .c "Set SSL Certificates"
	frame .c.mycert
	frame .c.svcert
	frame .c.crtdir
	label .c.mycert.l -anchor w -width 12 -text "MyCert:"
	label .c.svcert.l -anchor w -width 12 -text "ServerCert:"
	label .c.crtdir.l -anchor w -width 12 -text "CertsDir:"
	
	entry .c.mycert.e -width 32 -textvariable mycert
	entry .c.svcert.e -width 32 -textvariable svcert
	entry .c.crtdir.e -width 32 -textvariable crtdir
	button .c.mycert.b -text "Browse..." -command {set_mycert; catch {raise .c}}
	button .c.svcert.b -text "Browse..." -command {set_svcert; catch {raise .c}}
	button .c.crtdir.b -text "Browse..." -command {set_crtdir; catch {raise .c}}

	frame .c.b
	button .c.b.done -text "Done" -command {catch {destroy .c}}
	bind .c <Escape> {destroy .c}
	button .c.b.help -text "Help" -command help_certs
	pack .c.b.help .c.b.done -fill x -expand 1 -side left

	foreach w [list mycert svcert crtdir] {
		pack .c.$w.l -side left
		pack .c.$w.e -side left -expand 1 -fill x
		pack .c.$w.b -side left
		bind .c.$w.e <Return> ".c.$w.b invoke"
		if {$use_ssh} {
			.c.$w.l configure -state disabled	
			.c.$w.e configure -state disabled	
			.c.$w.b configure -state disabled	
		}	
	}

	pack .c.mycert .c.svcert .c.crtdir .c.b -side top -fill x
	center_win .c
	wm resizable .c 1 0

	focus .c
}

proc get_profiles_dir {} {
	global env is_windows
	
	set dir ""
	if {$is_windows} {
		set t [file dirname [pwd]]
		set t "$t/profiles"
		if [file isdirectory $t] {
			set dir $t
		}
	} elseif [info exists env(HOME)] {
		set t "$env(HOME)/.vnc"
		if [file isdirectory $t] {
			set dir $t
			set s "$t/profiles"
			if {! [file exists $s]} {
				catch {file mkdir $s}
			}
		}
	}
	
	if {$dir != ""} {
		
	} elseif [info exists env(SSL_VNC_BASEDIR)] {
		set dir $env(SSL_VNC_BASEDIR)
	} else {
		set dir [pwd]
	}
	if [file isdirectory "$dir/profiles"] {
		set dir "$dir/profiles"
	}
	return $dir
}
	
proc load_profile {} {
	global env
	global mycert svcert crtdir vncdisplay
	global use_alpha use_grab use_ssh use_sshssl use_viewonly use_fullscreen use_bgr233
	global use_nojpeg use_raise_on_beep use_compresslevel use_quality
	global compresslevel_text quality_text
	global use_smbmnt use_sound
	global use_cups cups_local_server cups_remote_port cups_manage_rcfile
	global cups_local_smb_server cups_remote_smb_port
	global smb_su_mode smb_mount_list
	global change_vncviewer change_vncviewer_path vncviewer_realvnc4
	global additional_port_redirs additional_port_redirs_list
	global sound_daemon_remote_cmd sound_daemon_remote_port sound_daemon_kill sound_daemon_restart
	global sound_daemon_local_cmd sound_daemon_local_port sound_daemon_local_kill sound_daemon_local_start 
	global use_port_knocking port_knocking_list
	global profdone

	set dir [get_profiles_dir]

	set file [tk_getOpenFile -defaultextension ".vnc" \
		-initialdir $dir -title "Load VNC Profile"]
	if {$file == ""} {
		set profdone 1
		return
	}
	set fh [open $file "r"]
	if {! [info exists fh]} {
		set profdone 1
		return
	}

	set_defaults

	while {[gets $fh line] > -1} {
		if [regexp {^disp=(.*)$} $line m val] {
			set vncdisplay $val 
		} elseif [regexp {^ssh=(.*)$} $line m val] {
			set use_ssh $val 
		} elseif [regexp {^sshssl=(.*)$} $line m val] {
			set use_sshssl $val 
		} elseif [regexp {^viewonly=(.*)$} $line m val] {
			set use_viewonly $val 
		} elseif [regexp {^fullscreen=(.*)$} $line m val] {
			set use_fullscreen $val 
		} elseif [regexp {^belldeiconify=(.*)$} $line m val] {
			set use_raise_on_beep $val 
		} elseif [regexp {^8bit=(.*)$} $line m val] {
			set use_bgr233 $val 
		} elseif [regexp {^alpha=(.*)$} $line m val] {
			set use_alpha $val 
		} elseif [regexp {^grab=(.*)$} $line m val] {
			set use_grab $val 
		} elseif [regexp {^nojpeg=(.*)$} $line m val] {
			set use_nojpeg $val 
		} elseif [regexp {^compresslevel=(.*)$} $line m val] {
			set use_compresslevel $val 
			set compresslevel_text "Compress Level: $val"
		} elseif [regexp {^quality=(.*)$} $line m val] {
			set use_quality $val 
			set quality_text "Quality: $val"
		} elseif [regexp {^mycert=(.*)$} $line m val] {
			set mycert $val 
		} elseif [regexp {^svcert=(.*)$} $line m val] {
			set svcert $val 
		} elseif [regexp {^crtdir=(.*)$} $line m val] {
			set crtdir $val 
		} elseif [regexp {^use_smbmnt=(.*)$} $line m val] {
			set use_smbmnt $val 
		} elseif [regexp {^use_sound=(.*)$} $line m val] {
			set use_sound $val 
		} elseif [regexp {^use_cups=(.*)$} $line m val] {
			set use_cups $val 
		} elseif [regexp {^cups_local_server=(.*)$} $line m val] {
			set cups_local_server $val 
		} elseif [regexp {^cups_remote_port=(.*)$} $line m val] {
			set cups_remote_port $val 
		} elseif [regexp {^cups_local_smb_server=(.*)$} $line m val] {
			set cups_local_smb_server $val 
		} elseif [regexp {^cups_remote_smb_port=(.*)$} $line m val] {
			set cups_remote_smb_port $val 
		} elseif [regexp {^cups_manage_rcfile=(.*)$} $line m val] {
			set cups_manage_rcfile $val 
		} elseif [regexp {^smb_mount_list=(.*)$} $line m val] {
			regsub -all {%%%} $val "\n" val
			set smb_mount_list $val 
		} elseif [regexp {^smb_su_mode=(.*)$} $line m val] {
			set smb_su_mode $val 
		} elseif [regexp {^port_knocking_list=(.*)$} $line m val] {
			regsub -all {%%%} $val "\n" val
			set port_knocking_list $val 
		} elseif [regexp {^use_port_knocking=(.*)$} $line m val] {
			set use_port_knocking $val 
		} elseif [regexp {^sound_daemon_remote_cmd=(.*)$} $line m val] {
			set sound_daemon_remote_cmd $val 
		} elseif [regexp {^sound_daemon_remote_port=(.*)$} $line m val] {
			set sound_daemon_remote_port $val 
		} elseif [regexp {^sound_daemon_kill=(.*)$} $line m val] {
			set sound_daemon_kill $val 
		} elseif [regexp {^sound_daemon_restart=(.*)$} $line m val] {
			set sound_daemon_restart $val 
		} elseif [regexp {^sound_daemon_local_cmd=(.*)$} $line m val] {
			set sound_daemon_local_cmd $val 
		} elseif [regexp {^sound_daemon_local_port=(.*)$} $line m val] {
			set sound_daemon_local_port $val 
		} elseif [regexp {^sound_daemon_local_start=(.*)$} $line m val] {
			set sound_daemon_local_start $val 
		} elseif [regexp {^sound_daemon_local_kill=(.*)$} $line m val] {
			set sound_daemon_local_kill $val 
		} elseif [regexp {^change_vncviewer=(.*)$} $line m val] {
			set change_vncviewer $val 
		} elseif [regexp {^change_vncviewer_path=(.*)$} $line m val] {
			set change_vncviewer_path $val 
		} elseif [regexp {^vncviewer_realvnc4=(.*)$} $line m val] {
			set vncviewer_realvnc4 $val 
		} elseif [regexp {^additional_port_redirs=(.*)$} $line m val] {
			set additional_port_redirs $val 
		} elseif [regexp {^additional_port_redirs_list=(.*)$} $line m val] {
			set additional_port_redirs_list $val 
		}
	}
	close $fh
	set profdone 1
	putty_pw_entry check
}

proc save_profile {} {
	global env is_windows
	global mycert svcert crtdir vncdisplay
	global use_alpha use_grab use_ssh use_sshssl use_viewonly use_fullscreen use_bgr233
	global use_nojpeg use_raise_on_beep use_compresslevel use_quality
	global profdone
	
	set dir [get_profiles_dir]

	set disp [string trim $vncdisplay]
	if {$disp != ""} {
		regsub {[ 	].*$} $disp "" disp
	}
	if {$is_windows} {
		regsub -all {:} $disp "_" disp
	}

	set file [tk_getSaveFile -defaultextension ".vnc" \
		-initialdir $dir -initialfile "$disp" -title "Save VNC Profile"]
	if {$file == ""} {
		set profdone 1
		return
	}
	set fh [open $file "w"]
	if {! [info exists fh]} {
		set profdone 1
		return
	}
	set h [string trim $vncdisplay]
	set p $h
	regsub {:.*$} $h "" h
	set host $h
	regsub {[ 	].*$} $p "" p
	regsub {^.*:} $p "" p
	if {$p == ""} {
		set p 0
	}
	if {$p < 200} {
		set port [expr $p + 5900]
	} else {
		set port $p
	}

	set h [string trim $vncdisplay]
	regsub {cmd=.*$} $h "" h
	set h [string trim $h]
	if {! [regexp {[ 	]} $h]} {
		set h ""
	} else {
		regsub {^.*[ 	]} $h "" h
	}
	if {$h == ""} {
		set proxy ""
		set proxyport ""
	} else {
		set p $h
		regsub {:.*$} $h "" h
		set proxy $h
		regsub {[ 	].*$} $p "" p
		regsub {^.*:} $p "" p
		if {$p == ""} {
			set proxyport 0
		} else {
			set proxyport $p
		}
	}
	
	puts $fh "\[connection\]"
	puts $fh "host=$host"
	puts $fh "port=$port"
	puts $fh "proxyhost=$proxy"
	puts $fh "proxyport=$proxyport"
	puts $fh "disp=$vncdisplay"
	puts $fh "\n\[options\]"
	puts $fh "ssh=$use_ssh"
	puts $fh "sshssl=$use_sshssl"
	puts $fh "viewonly=$use_viewonly"
	puts $fh "fullscreen=$use_fullscreen"
	puts $fh "belldeiconify=$use_raise_on_beep"
	puts $fh "8bit=$use_bgr233"
	puts $fh "alpha=$use_alpha"
	puts $fh "grab=$use_grab"
	puts $fh "nojpeg=$use_nojpeg"
	puts $fh "compresslevel=$use_compresslevel"
	puts $fh "quality=$use_quality"
	puts $fh "mycert=$mycert"
	puts $fh "svcert=$svcert"
	puts $fh "crtdir=$crtdir"

	global use_smbmnt use_sound
	puts $fh "use_smbmnt=$use_smbmnt"
	puts $fh "use_sound=$use_sound"

	global use_cups cups_local_server cups_remote_port cups_manage_rcfile
	global cups_local_smb_server cups_remote_smb_port
	puts $fh "use_cups=$use_cups"
	puts $fh "cups_local_server=$cups_local_server"
	puts $fh "cups_remote_port=$cups_remote_port"
	puts $fh "cups_local_smb_server=$cups_local_smb_server"
	puts $fh "cups_remote_smb_port=$cups_remote_smb_port"
	puts $fh "cups_manage_rcfile=$cups_manage_rcfile"

	global change_vncviewer change_vncviewer_path vncviewer_realvnc4
	global additional_port_redirs additional_port_redirs_list
	puts $fh "change_vncviewer=$change_vncviewer"
	puts $fh "change_vncviewer_path=$change_vncviewer_path"
	puts $fh "vncviewer_realvnc4=$vncviewer_realvnc4"
	puts $fh "additional_port_redirs=$additional_port_redirs"
	puts $fh "additional_port_redirs_list=$additional_port_redirs_list"

	global sound_daemon_remote_cmd sound_daemon_remote_port sound_daemon_kill sound_daemon_restart
	global sound_daemon_local_cmd sound_daemon_local_port sound_daemon_local_kill sound_daemon_local_start 
	puts $fh "sound_daemon_remote_cmd=$sound_daemon_remote_cmd"
	puts $fh "sound_daemon_remote_port=$sound_daemon_remote_port"
	puts $fh "sound_daemon_kill=$sound_daemon_kill"
	puts $fh "sound_daemon_restart=$sound_daemon_restart"
	puts $fh "sound_daemon_local_cmd=$sound_daemon_local_cmd"
	puts $fh "sound_daemon_local_port=$sound_daemon_local_port"
	puts $fh "sound_daemon_local_kill=$sound_daemon_local_kill"
	puts $fh "sound_daemon_local_start=$sound_daemon_local_start"

	global smb_su_mode smb_mount_list
	set list $smb_mount_list
	regsub -all "\n" $list "%%%" list
	puts $fh "smb_su_mode=$smb_su_mode"
	puts $fh "smb_mount_list=$list"

	global use_port_knocking port_knocking_list
	set list $port_knocking_list
	regsub -all "\n" $list "%%%" list
	puts $fh "use_port_knocking=$use_port_knocking"
	puts $fh "port_knocking_list=$list"

	close $fh
	set profdone 1
}

proc set_ssh {} {
	global use_ssh use_sshssl
	if {! $use_ssh && ! $use_sshssl} {
		set use_ssh 1
	}
	putty_pw_entry check
}

proc expand_IP {redir} {
	if {! [regexp {:IP:} $redir]} {
		return $redir
	}
	if {! [regexp {(-R).*:IP:} $redir]} {
		return $redir
	}

	set ip [guess_ip]
	set ip [string trim $ip]
	if {$ip == ""} {
		return $redir
	}

	regsub -all {:IP:} $redir ":$ip:" redir
	return $redir
}

proc get_cups_redir {} {
	global cups_local_server cups_remote_port
	global cups_local_smb_server cups_remote_smb_port
	set redir "$cups_remote_port:$cups_local_server"
	regsub -all {['" 	]} $redir {} redir; #"
	set redir " -R $redir"
	if {$cups_local_smb_server != "" && $cups_remote_smb_port != ""} {
		set redir2 "$cups_remote_smb_port:$cups_local_smb_server"
		regsub -all {['" 	]} $redir2 {} redir2; #"
		set redir "$redir -R $redir2"
	}
	set redir [expand_IP $redir]
	return $redir
}

proc get_additional_redir {} {
	global additional_port_redirs additional_port_redirs_list
	if {! $additional_port_redirs || $additional_port_redirs_list == ""} {
		return ""
	}
	set redir [string trim $additional_port_redirs_list]
	regsub -all {['"]} $redir {} redir; #"
	set redir " $redir"
	set redir [expand_IP $redir]
	return $redir
}

proc get_sound_redir {} {
	global sound_daemon_remote_port sound_daemon_local_port
	set loc $sound_daemon_local_port
	if {! [regexp {:} $loc]} {
		set loc "localhost:$loc"
	}
	set redir "$sound_daemon_remote_port:$loc"
	regsub -all {['" 	]} $redir {} redir; #"
	set redir " -R $redir"
	set redir [expand_IP $redir]
	return $redir
}

proc get_smb_redir {} {
	global smb_mount_list

	set s [string trim $smb_mount_list]
	if {$s == ""} {
		return ""
	}

	set did(0) 1
	set redir ""
	set mntlist ""

	foreach line [split $s "\r\n"] {
		set str [string trim $line] 
		if {$str == ""} {
			continue
		}
		if {[regexp {^#} $str]} {
			continue
		}

		set port ""
		if [regexp {^([0-9][0-9]*)[ \t][ \t]*(.*)} $str mvar port rest] {
			# leading port
			set str [string trim $rest]
		}

		# grab:  //share /dest [host[:port]]
		set share ""
		set dest ""
		set hostport ""
		foreach item [split $str] {
			if {$item == ""} {
				continue
			}
			if {$share == ""} {
				set share [string trim $item]
			} elseif {$dest == ""} {
				set dest [string trim $item]
			} elseif {$hostport == ""} {
				set hostport [string trim $item]
			}
		}

		regsub {^~/} $dest {$HOME/} dest

		# work out the local host:port
		set lhost ""
		set lport ""
		if {$hostport != ""} {
			if [regexp {(.*):(.*)} $hostport mvar lhost lport] {
				;
			} else {
				set lhost $hostport
				set lport 139
			}
		} else {
			if [regexp {//([^/][^/]*)/} $share mvar h] {
				if [regexp {(.*):(.*)} $h mvar lhost lport] {
					;
				} else {
					set lhost $h
					set lport 139
				}
			} else {
				set lhost localhost
				set lport 139
			}
		}

		if {$port == ""} {
			if [info exists did("$lhost:$lport")] {
				# reuse previous one:
				set port $did("$lhost:$lport")
			} else {
				# choose one at random:
				for {set i 0} {$i < 3} {incr i} {
					set port [expr 20100 + 9000 * rand()]	
					set port [expr round($port)]
					if { ! [info exists did($port)] } {
						break
					}
				}
			}
			set did($port) 1
		}

		if {$mntlist != ""} {
			append mntlist " "
		}
		append mntlist "$share,$dest,$port"

		if { ! [info exists did("$lhost:$lport")] } {
			append redir " -R $port:$lhost:$lport"
			set did("$lhost:$lport") $port
		}
	}

	regsub -all {['"]} $redir {} redir; #"
	set redir [expand_IP $redir]

	regsub -all {['"]} $mntlist {} mntlist; #"

	set l [list]
	lappend l $redir
	lappend l $mntlist
	return $l
}

proc ugly_setup_scripts {mode tag} {

set cmd(1) {
	SSHD_PID=""
	FLAG=$HOME/.vnc-helper-flag__PID__

	if [ "X$USER" = "X" ]; then
		USER=$LOGNAME
	fi

	DO_CUPS=0
	cups_dir=$HOME/.cups
	cups_cfg=$cups_dir/client.conf
	cups_host=localhost
	cups_port=NNNN

	DO_SMB=0
	DO_SMB_SU=0
	DO_SMB_WAIT=0
	smb_mounts=
	DONE_PORT=NNNN
	smb_script=$HOME/.smb-mounts__PID__.sh

	DO_SOUND=0
	DO_SOUND_KILL=0
	DO_SOUND_RESTART=0
	sound_daemon_remote_prog=
	sound_daemon_remote_args=

	findpid() {
		i=1
		back=10
		touch $FLAG

		if [ "X$TOPPID" = "X" ]; then
			TOPPID=$$
			back=50
		fi

		while [ $i -lt $back ]
		do
			try=`expr $TOPPID - $i`
			if ps $try 2>/dev/null | grep sshd >/dev/null; then
				SSHD_PID="$try"	
				echo SSHD_PID=$try
				echo
				break
			fi
			i=`expr $i + 1`
		done
	}

	wait_til_ssh_gone() {
		try_perl=""
		if type perl >/dev/null 2>&1; then
			try_perl=1
		fi
		uname=`uname`
		if [ "X$uname" != "XLinux" -a "X$uname" != "XSunOS" ]; then
			try_perl=""
		fi
		if [ "X$try_perl" = "X1" ]; then
			# try to avoid wasting pids:
			perl -e "while (1) {if(! -e \"/proc/$SSHD_PID\"){exit} if(! -f \"$FLAG\"){exit} sleep 1;}"
		else
			while [ 1 ]
			do
				ps $SSHD_PID > /dev/null 2>&1
				if [ $? != 0 ]; then
					break
				fi
				if [ ! -f $FLAG ]; then
					break
				fi
				sleep 1
			done
		fi
		rm -f $FLAG
		if [ "X$DO_SMB_WAIT" = "X1" ]; then
			rm -f $smb_script
		fi
	}
};

set cmd(2) {
	update_client_conf() {
		mkdir -p $cups_dir
		if [ -f $cups_cfg ]; then
			cp -p $cups_cfg $cups_cfg.back
		else
			touch $cups_cfg.back
		fi
		sed -e "s/^ServerName/#-etv-#ServerName/" $cups_cfg.back > $cups_cfg
		echo "ServerName $cups_host:$cups_port" >> $cups_cfg
		echo
		echo "--------------------------------------------------------------"
		echo "The CUPS $cups_cfg config file has been set to:"
		echo
		cat $cups_cfg
		echo
		echo "If there are problems automatically restoring it, edit or"
		echo "remove the file to go back to local CUPS settings."
		echo
		echo "A backup has been placed in: $cups_cfg.back"
		echo
		echo "See the help description for more details on printing."
		echo
		echo "done."
		echo "--------------------------------------------------------------"
		echo
	}

	reset_client_conf() {
		cp -p $cups_cfg $cups_cfg.tmp
		grep -v "^ServerName" $cups_cfg.tmp | sed -e "s/^#-etv-#ServerName/ServerName/" > $cups_cfg
		rm -f $cups_cfg.tmp
	}

	cupswait() {
		trap "" INT QUIT HUP
		wait_til_ssh_gone
		reset_client_conf
	}
};

#		if [ "X$DONE_PORT" != "X" ]; then
#			if type perl >/dev/null 2>&1; then
#				perl -e "use IO::Socket::INET; \$SIG{INT} = \"IGNORE\"; \$SIG{QUIT} = \"IGNORE\"; \$SIG{HUP} = \"INGORE\"; my \$client = IO::Socket::INET->new(Listen => 5, LocalAddr => \"localhost\", LocalPort => $DONE_PORT, Proto => \"tcp\")->accept(); \$line = <\$client>; close \$client; unlink \"$smb_script\";" </dev/null >/dev/null 2>/dev/null &
#				if [ $? = 0 ]; then
#					have_perl_done="1"
#				fi
#			fi
#		fi

set cmd(3) {
	smbwait() {
		trap "" INT QUIT HUP
		wait_til_ssh_gone
	}
	do_smb_mounts() {
		if [ "X$smb_mounts" = "X" ]; then
			return
		fi
		echo > $smb_script
		have_perl_done=""
		echo "echo" >> $smb_script 
		dests=""
		for mnt in $smb_mounts
		do
			smfs=`echo "$mnt" | awk -F, "{print \\\$1}"`
			dest=`echo "$mnt" | awk -F, "{print \\\$2}"`
			port=`echo "$mnt" | awk -F, "{print \\\$3}"`
			dest=`echo "$dest" | sed -e "s,__USER__,$USER,g" -e "s,__HOME__,$HOME,g"`
			if [ ! -d $dest ]; then
				mkdir -p $dest
			fi
			echo "echo SMBMOUNT:" >> $smb_script
			echo "echo smbmount $smfs $dest -o uid=$USER,ip=127.0.0.1,port=$port" >> $smb_script
			echo "smbmount \"$smfs\" \"$dest\" -o uid=$USER,ip=127.0.0.1,port=$port" >> $smb_script
			echo "echo; df \"$dest\"; echo" >> $smb_script
			dests="$dests $dest"
		done
		#}
};

set cmd(4) {
		echo "(" >> $smb_script
		echo "trap \"\" INT QUIT HUP" >> $smb_script

		try_perl=""
		if type perl >/dev/null 2>&1; then
			try_perl=1
		fi
		uname=`uname`
		if [ "X$uname" != "XLinux" -a "X$uname" != "XSunOS" ]; then
			try_perl=""
		fi

		if [ "X$try_perl" = "X" ]; then
			echo "while [ -f $smb_script ]" >> $smb_script
			echo "do" >> $smb_script
			echo "     sleep 1" >> $smb_script
			echo "done" >> $smb_script
		else
			echo "perl -e \"while (-f \\\\\"$smb_script\\\\\") {sleep 1;} exit 0;\"" >> $smb_script
		fi
		for dest in $dests
		do
			echo "echo smbumount $dest" >> $smb_script
			echo "smbumount \"$dest\"" >> $smb_script
		done
		echo ") &" >> $smb_script
		echo "--------------------------------------------------------------"
		if [ "$DO_SMB_SU" = "0" ]; then
			echo "We now run the smbmount script as user $USER"
			echo
			echo sh $smb_script
			sh $smb_script
			rc=0
		elif [ "$DO_SMB_SU" = "1" ]; then
			echo "We now run the smbmount script via su(1)"
			echo
			echo "The first \"Password:\" will be for that of root to run the smbmount script."
			echo
			echo "Subsequent \"Password:\" will be for the SMB share(s) (hit Return if no passwd)"
			echo
			echo SU:
			echo "su root -c \"sh $smb_script\""
			su root -c "sh $smb_script"
			rc=$?
		elif [ "$DO_SMB_SU" = "2" ]; then
			echo "We now run the smbmount script via sudo(8)"
			echo
			echo "The first \"Password:\" will be for that of the sudo(8) password."
			echo
			echo "Subsequent \"Password:\" will be for the SMB shares (hit enter if no passwd)"
			echo
			echo SUDO:
			echo sudo sh $smb_script
			sudo sh $smb_script
			rc=$?
		fi
};

set cmd(5) {
		#{
		echo
		if [ "$rc" = 0 ]; then
			if [ "X$have_perl_done" = "X1" -o 1 = 1 ] ; then
				echo
				echo "Your SMB shares will be be unmounted when the VNC connection"
				echo "closes.  If that fails follow these instructions:"
			fi
			echo
			echo "To unmount your SMB shares make sure no applications are still using"
			echo "any of the files and no shells are still cd-ed into the share area,"
			echo "then type:"
			echo 
			echo "   rm -f $smb_script"
			echo 
			echo "(to avoid a 2nd ssh, try to do this before terminating the VNC Viewer)"
			echo
			echo "In the worst case run: smbumount /path/to/mount/point for each mount."
		else
			echo 
			if [ "$DO_SMB_SU" = "1" ]; then
				echo "su(1) to run smbmount(8) failed."
			elif [ "$DO_SMB_SU" = "2" ]; then
				echo "sudo(8) to run smbmount(8) failed."
			fi
			rm -f $smb_script
		fi
		echo
		echo "done."
		echo "--------------------------------------------------------------"
		echo
	}
};

set cmd(6) {

	setup_sound() {
		dpid=""
		d=$sound_daemon_remote_prog
		if type pgrep >/dev/null 2>/dev/null; then
			dpid=`pgrep -U $USER -x $d | head -1`
		else
			dpid=`env PATH=/usr/ucb:$PATH ps wwwwaux | grep -w $USER | grep -w $d | grep -v grep | head -1`
		fi
		echo "--------------------------------------------------------------"
		echo "Setting up Sound: pid=$dpid"
		if [ "X$dpid" != "X" ]; then
			dcmd=`env PATH=/usr/ucb:$PATH ps wwwwaux | grep -w $USER | grep -w $d | grep -w $dpid | grep -v grep | head -1 | sed -e "s/^.*$d/$d/"`
			if [ "X$DO_SOUND_KILL" = "X1" ]; then
				echo "Stopping sound daemon: $sound_daemon_remote_prog $dpid"
				echo "sound cmd: $dcmd"
				kill -TERM $dpid
			fi
		fi
		echo
		echo "done."
		echo "--------------------------------------------------------------"
		echo
	}

	reset_sound() {
		if [ "X$DO_SOUND_RESTART" = "X1" ]; then
			d=$sound_daemon_remote_prog
			a=$sound_daemon_remote_args
			echo "Restaring sound daemon: $d $a"
			$d $a </dev/null >/dev/null 2>&1 &
		fi
	}

	soundwait() {
		trap "" INT QUIT HUP
		wait_til_ssh_gone
		reset_sound
	}

	findpid

	if [ $DO_SMB = 1 ]; then
		do_smb_mounts
	fi

	waiter=0

	if [ $DO_CUPS = 1 ]; then
		update_client_conf
		cupswait </dev/null >/dev/null 2>/dev/null &
		waiter=1
	fi

	if [ $DO_SOUND = 1 ]; then
		setup_sound
		soundwait </dev/null >/dev/null 2>/dev/null &
		waiter=1
	fi
	if [ $DO_SMB_WAIT = 1 ]; then
		if [ $waiter != 1 ]; then
			smbwait </dev/null >/dev/null 2>/dev/null &
			waiter=1
		fi
	fi


	echo "--vnc-helper-exiting--"
	echo
	rm -f $0
	exit 0
};

	set cmdall ""

	for {set i 1} {$i <= 6} {incr i} {
		set v $cmd($i);
		regsub -all "\n" $v "%" v
		set cmd($i) $v
		append cmdall "echo "
		if {$i == 1} {
			append cmdall {TOPPID=$$%} 
		}
		append cmdall {'}
		append cmdall $cmd($i)
		append cmdall {' | tr '%' '\n'}
		if {$i == 1} {
			append cmdall {>}
		} else {
			append cmdall {>>}
		}
		append cmdall {$HOME/.vnc-helper-cmd__PID__; }
	}
	append cmdall {sh $HOME/.vnc-helper-cmd__PID__; }

	regsub -all {vnc-helper-cmd} $cmdall "vnc-helper-cmd-$mode" cmdall
	if {$tag == ""} {
		set tag [pid]
	}
	regsub -all {__PID__} $cmdall "$tag" cmdall

	set orig $cmdall

	global use_cups cups_local_server cups_remote_port cups_manage_rcfile
	if {$use_cups && $cups_manage_rcfile} {
		if {$mode == "post"} {
			regsub {DO_CUPS=0} $cmdall {DO_CUPS=1} cmdall
			regsub {cups_port=NNNN} $cmdall "cups_port=$cups_remote_port" cmdall
		}
	}
	
	global use_smbmnt smb_su_mode
	if {$use_smbmnt} {
		global smb_mounts 
		if {$smb_mounts != ""} {
			set smbm $smb_mounts
			regsub -all {%USER} $smbm "__USER__" smbm
			regsub -all {%HOME} $smbm "__HOME__" smbm
			if {$mode == "pre"} {
				regsub {DO_SMB=0} $cmdall {DO_SMB=1} cmdall
				if {$smb_su_mode == "su"} {
					regsub {DO_SMB_SU=0} $cmdall {DO_SMB_SU=1} cmdall
				} elseif {$smb_su_mode == "sudo"} {
					regsub {DO_SMB_SU=0} $cmdall {DO_SMB_SU=2} cmdall
				} elseif {$smb_su_mode == "none"} {
					regsub {DO_SMB_SU=0} $cmdall {DO_SMB_SU=0} cmdall
				} else {
					regsub {DO_SMB_SU=0} $cmdall {DO_SMB_SU=1} cmdall
				}
				regsub {smb_mounts=} $cmdall "smb_mounts=\"$smbm\"" cmdall
			} elseif {$mode == "post"} {
				regsub {DO_SMB_WAIT=0} $cmdall {DO_SMB_WAIT=1} cmdall
			}
		}
	}

	global use_sound
	if {$use_sound} {
		if {$mode == "pre"} {
			global sound_daemon_remote_cmd sound_daemon_kill sound_daemon_restart
			if {$sound_daemon_kill} {
				regsub {DO_SOUND_KILL=0} $cmdall {DO_SOUND_KILL=1} cmdall
				regsub {DO_SOUND=0} $cmdall {DO_SOUND=1} cmdall
			}
			if {$sound_daemon_restart} {
				regsub {DO_SOUND_RESTART=0} $cmdall {DO_SOUND_RESTART=1} cmdall
				regsub {DO_SOUND=0} $cmdall {DO_SOUND=1} cmdall
			}
			set sp [string trim $sound_daemon_remote_cmd]
			regsub {[ \t].*$} $sp "" sp
			set sa [string trim $sound_daemon_remote_cmd]
			regsub {^[^ \t][^ \t]*[ \t][ \t]*} $sa "" sa
			regsub {sound_daemon_remote_prog=} $cmdall "sound_daemon_remote_prog=\"$sp\"" cmdall
			regsub {sound_daemon_remote_args=} $cmdall "sound_daemon_remote_args=\"$sa\"" cmdall
		}
	}
	
	if {"$orig" == "$cmdall"} {
		return ""
	} else {
		return $cmdall
	}
}

proc cups_dialog {} {

	catch {destroy .cups}
	toplevel .cups
	wm title .cups "CUPS Tunnelling"
	global cups_local_server cups_remote_port cups_manage_rcfile
	global cups_local_smb_server cups_remote_smb_port

	scroll_text .cups.f

	set msg {
    CUPS Printing requires SSH be used to set up the Print service port
    redirection.  This will be either of the "Use SSH instead" or "Use
    SSH and SSL" modes under "Options".  Pure SSL tunnelling will not work.

    This method requires working CUPS software setups on both the remote
    and local sides of the connection.

    (See Method #1 below for perhaps the easiest way to get applications
    to print through the tunnel; it requires admin privileges however).

    You choose an actual remote CUPS port below under "Use Remote CUPS
    Port:" (6631 is just our default and used in the examples below).
    Note that the normal default CUPS server port is 631.

    The port you choose must be unused on the VNC server machine (n.b. no
    checking is done).  Print requests connecting to it are redirected to
    your local machine through the SSH tunnel.  Note: root permission is
    needed for ports less than 1024 (this is not recommended).

    Then enter the VNC Viewer side (i.e. where you are sitting) CUPS server
    under "Local CUPS Server".  E.g. use "localhost:631" if there is one
    on the viewer machine, or, say, "my-print-srv:631" for a nearby CUPS
    print server.

    Several methods are now described for how to get applications to
    print through the port redirected tunnel.

    Method #0: Create or edit the file $HOME/.cups/client.conf on the VNC
    server side by putting in something like this in it:

    	ServerName localhost:6631

    based on the port you selected above.
    
    NOTE: For this client.conf ServerName setting to work with lp(1)
    and lpr(1) CUPS 1.2 or greater is required.  The cmdline option 
    "-h localhost:6631" can be used for older versions.  For client.conf to
    work in general (e.g. Openoffice, Firefox), a bugfix found in CUPS 1.2.3
    is required.  Two Workarounds (Methods #1 and #2) are described below.

    After the remote VNC Connection is finished, to go back to the non-SSH
    tunnelled CUPS server and either remove the client.conf file or comment
    out the ServerName line.  This restores the normal CUPS server for
    you on the remote machine.

    Select "Manage ServerName in the $HOME/.cups/client.conf file for me" to
    attempt to do this editing of the CUPS config file for you automatically.

    Method #1: If you have admin permission on the VNC Server machine you
    can likely "Add a Printer" via a GUI dialog, wizard, lpadmin(8), etc.
    This makes the client.conf ServerName parameter unnecessary.  You will
    need to tell the GUI dialog that the printer is at, e.g., localhost:6631,
    and anything else needed to identify the printer (type, model, etc).

    Method #2: Restarting individual applications with the IPP_PORT
    set will enable redirected printing for them, e.g.:
    "env IPP_PORT=6631 firefox"

    Windows/SMB Printers:  Under "Local SMB Print Server" you can set
    a port redirection for a Windows (non-CUPS) SMB printer.  E.g. port
    6632 -> localhost:139.  If localhost:139 does not work, try IP:139,
    etc. or put in the IP address manually.  Then at the least you can
    print using the smbspool(8) program like this:

       smbspool smb://localhost:6632/lp job user title 1 "" myfile.ps

    You could put this in a script, "myprinter".  It appears on the the URI,
    the number of copies ("1" above) and the file itself are important.
    (XXX this might only work for Samba printers...)

    If you have root permission you can configure CUPS to know about this
    printer via lpadmin(8), etc.  You basically give it the smb:// URI.

    For more info see: http://www.karlrunge.com/x11vnc/#faq-cups
}
	.cups.f.t insert end $msg

	if {$cups_local_server == ""} {
		set cups_local_server "localhost:631"
	}
	if {$cups_remote_port == ""} {
		set cups_remote_port "6631"
	}
	if {$cups_local_smb_server == ""} {
		global is_windows
		if {$is_windows} {
			set cups_local_smb_server "IP:139"
		} else {
			set cups_local_smb_server "localhost:139"
		}
	}
	if {$cups_remote_smb_port == ""} {
		set cups_remote_smb_port "6632"
	}

	frame .cups.serv
	label .cups.serv.l -text "Local CUPS Server:      "
	entry .cups.serv.e -width 40 -textvariable cups_local_server
	pack .cups.serv.l -side left
	pack .cups.serv.e -side left -expand 1 -fill x

	frame .cups.port
	label .cups.port.l -text "Use Remote CUPS Port:"
	entry .cups.port.e -width 40 -textvariable cups_remote_port
	pack .cups.port.l -side left
	pack .cups.port.e -side left -expand 1 -fill x

	frame .cups.smbs
	label .cups.smbs.l -text "Local SMB Print Server:      "
	entry .cups.smbs.e -width 40 -textvariable cups_local_smb_server
	pack .cups.smbs.l -side left
	pack .cups.smbs.e -side left -expand 1 -fill x

	frame .cups.smbp
	label .cups.smbp.l -text "Use Remote SMB Print Port:"
	entry .cups.smbp.e -width 40 -textvariable cups_remote_smb_port
	pack .cups.smbp.l -side left
	pack .cups.smbp.e -side left -expand 1 -fill x

	checkbutton .cups.cupsrc -anchor w -variable cups_manage_rcfile -text \
		"Manage ServerName in the remote \$HOME/.cups/client.conf file for me"

	button .cups.done -text "Done" -command {destroy .cups; if {$use_cups} {set_ssh}}
	bind .cups <Escape> {destroy .cups; if {$use_cups} {set_ssh}}

	button .cups.guess -text "Help me decide ..." -command {}
	.cups.guess configure -state disabled

	pack .cups.done .cups.guess .cups.cupsrc .cups.smbp .cups.smbs .cups.port .cups.serv -side bottom -fill x
	pack .cups.f -side top -fill both -expand 1

	center_win .cups
}

proc sound_dialog {} {

	global is_windows

	catch {destroy .snd}
	toplevel .snd
	wm title .snd "ESD/ARTSD Sound Tunnelling"

	scroll_text .snd.f 80 30

	set msg {
    Sound daemon tunnelling requires SSH be used to set up the service
    port redirection.  This will be either of the "Use SSH instead" or "Use
    SSH and SSL" modes under "Options".  Pure SSL tunnelling will not work.

    This method requires working Sound daemon (e.g. ESD or ARTSD) software
    setups on both the remote and local sides of the connection.

    Often this means you want to run your ENTIRE remote desktop with all
    applications instructed to use the sound daemon's network port.  E.g.

        esddsp -s localhost:16001  startkde
        esddsp -s localhost:16001  gnome-session

    and similarly for artsdsp, etc.  You put this in your ~/.xession,
    or other startup file.  This is non standard.  If you do not want to
    do this you still can direct *individual* sound applications through
    the tunnel, for example "esddsp -s localhost:16001 soundapp", where
    "soundapp" is some application that makes noise (say xmms or mpg123).

    Also, usually the remote Sound daemon must be killed BEFORE the SSH port
    redir is established (because it is listening on the port we want to use
    for the SSH redir), and, presumably, restarted when the VNC connection
    finished.

    One may also want to start and kill a local sound daemon that will
    play the sound received over the network on the local machine.

    You can indicate the remote and local Sound daemon commands below and
    how they should be killed and/or restart.  Some examples:

        esd -promiscuous -as 5 -port 16001 -tcp -bind 127.0.0.1
        artsd -n -p 7265 -F 10 -S 4096 -n -s 5 -m artsmessage -l 3 -f

    or you can leave some or all blank and kill/start them manually.

    For convenience, a Windows port of ESD is provided in the util/esound
    directory, and so this might work for a Local command:

        esound\esd -promiscuous -as 5 -port 16001 -tcp -bind 127.0.0.1

    NOTE: If you indicate "Remote Sound daemon: Kill at start." below,
    then THERE WILL BE TWO SSH'S: THE FIRST ONE TO KILL THE DAEMON.
    So you may need to supply TWO SSH PASSWORDS, unless you are using
    something like ssh-agent(1), the Putty PW setting, etc.

    You will also need to supply the remote and local sound ports for the
    SSH redirs (even though in principle the could be guessed from the
    daemon commands...)  For esd the default port is 16001, but you can
    choose another one if you prefer.

    For "Local Sound Port" you can also supply "host:port" instead of just
    a numerical port to specify non-localhost connections, e.g. to another
    machine.

    For more info see: http://www.karlrunge.com/x11vnc/#faq-sound
}
	.snd.f.t insert end $msg

	global sound_daemon_remote_port sound_daemon_local_port sound_daemon_local_cmd
	if {$sound_daemon_remote_port == ""} {
		set sound_daemon_remote_port 16001
	}
	if {$sound_daemon_local_port == ""} {
		set sound_daemon_local_port 16001
	}

	if {$sound_daemon_local_cmd == ""} {
		global is_windows
		if {$is_windows} {
			set sound_daemon_local_cmd {esound\esd -promiscuous -as 5 -port %PORT -tcp -bind 127.0.0.1}
		} else {
			set sound_daemon_local_cmd {esd -promiscuous -as 5 -port %PORT -tcp -bind 127.0.0.1}
		}
		regsub {%PORT} $sound_daemon_local_cmd $sound_daemon_local_port sound_daemon_local_cmd
	}


	frame .snd.remote
	label .snd.remote.l -text "Remote Sound daemon cmd: "
	entry .snd.remote.e -width 40 -textvariable sound_daemon_remote_cmd
	pack .snd.remote.l -side left
	pack .snd.remote.e -side left -expand 1 -fill x

	frame .snd.local
	label .snd.local.l -text "Local Sound daemon cmd:     "
	entry .snd.local.e -width 40 -textvariable sound_daemon_local_cmd
	pack .snd.local.l -side left
	pack .snd.local.e -side left -expand 1 -fill x

	frame .snd.rport
	label .snd.rport.l -text "Remote Sound Port: "
	entry .snd.rport.e -width 40 -textvariable sound_daemon_remote_port
	pack .snd.rport.l -side left
	pack .snd.rport.e -side left -expand 1 -fill x

	frame .snd.lport
	label .snd.lport.l -text "Local Sound Port:     "
	entry .snd.lport.e -width 40 -textvariable sound_daemon_local_port
	pack .snd.lport.l -side left
	pack .snd.lport.e -side left -expand 1 -fill x


	checkbutton .snd.sdk -anchor w -variable sound_daemon_kill -text \
		"Remote Sound daemon: Kill at start."

	checkbutton .snd.sdr -anchor w -variable sound_daemon_restart -text \
		"Remote Sound daemon: Restart at end."

	checkbutton .snd.sdsl -anchor w -variable sound_daemon_local_start -text \
		"Local Sound daemon: Run at start."

	checkbutton .snd.sdkl -anchor w -variable sound_daemon_local_kill -text \
		"Local Sound daemon: Kill at end."

	button .snd.guess -text "Help me decide ..." -command {}
	.snd.guess configure -state disabled

	global is_win9x 
	if {$is_win9x} {
		.snd.local.e configure -state disabled
		.snd.local.l configure -state disabled
		.snd.sdsl configure -state disabled
		.snd.sdkl configure -state disabled
	}

	button .snd.done -text "Done" -command {destroy .snd; if {$use_sound} {set_ssh}}
	bind .snd <Escape> {destroy .snd; if {$use_sound} {set_ssh}}

	pack .snd.done .snd.guess .snd.sdkl .snd.sdsl .snd.sdr .snd.sdk .snd.lport .snd.rport \
		.snd.local .snd.remote -side bottom -fill x
	pack .snd.f -side bottom -fill both -expand 1

	center_win .snd
}

# Share ideas.
# 
# Unix:
# 
# if type smbclient
# first parse smbclient -L localhost -N
# and/or      smbclient -L `hostname` -N
# Get Sharenames and Servers and Domain.
# 
# loop over servers, doing smbclient -L server -N
# pile this into a huge list, sep by disk and printers.
# 
# WinXP:
# 
# parse "NET VIEW" output similarly.
# 
# Have checkbox for each disk.  Set default root to /var/tmp/${USER}-mnts
# Let them change that at once and have it populate. 
# 
# use   //hostname/share  /var/tmp/runge-mnts/hostname/share
# 
# 
# Printers, hmmm.  Can't add to remote cups list...  I guess have the list
# ready for CUPS dialog to suggest which SMB servers they want to redirect
# to...

proc get_hostname {} {
	global is_windows is_win9x
	set str ""
	if {$is_windows} {
		if {1} {
			catch {set str [exec hostname]}
			regsub -all {[\r]} $str "" str
		} else {
			catch {set str [exec net config]}
			if [regexp -nocase {Computer name[ \t]+\\\\([^ \t]+)} $str mv str] {
				;
			} else {
				set str ""
			}
		}
	} else {
		catch {set str [exec hostname]}
	}
	set str [string trim $str]
	return $str
}

proc smb_list_windows {smbhost} {
	global smb_local smb_local_hosts smb_this_host
	global is_win9x
	set dbg 0

	set domain ""

	if {$is_win9x} {
		# exec net view ... doesn't work.
		set smb_this_host "unknown"
		return
	}

	set this_host [get_hostname]
	set This_host [string toupper $this_host]
	set smb_this_host $This_host

	if {$smbhost == $smb_this_host} {
		catch {set out0 [exec net view]}
		regsub -all {[\r]} $out0 "" out0
		foreach line [split $out0 "\n"] {
			if [regexp -nocase {in workgroup ([^ \t]+)} $line mv wg] {
				regsub -all {[.]} $wg "" wg
				set domain $wg
			} elseif [regexp {^\\\\([^ \t]+)[ \t]*(.*)} $line mv host comment] {
				set smb_local($smbhost:server:$host) $comment
			}
		}
	}

	set out1 ""
	set h "\\\\$smbhost"
	catch {set out1 [exec net view $h]}
	regsub -all {[\r]} $out1 "" out1

	if {$dbg} {puts "SMBHOST: $smbhost"}

	set mode ""
	foreach line [split $out1 "\n"] {
		if [regexp {^[ \t]*---} $line] {
			continue
		}
		if [regexp -nocase {The command} $line] {
			continue
		}
		if [regexp -nocase {Shared resources} $line] {
			continue
		}
		if [regexp -nocase {^[ \t]*Share[ \t]*name} $line] {
			set mode "shares"
			continue
		}
		set line [string trim $line]
		if {$line == ""} {
			continue
		}
		if {$mode == "shares"} {
			if [regexp {^([^ \t]+)[ \t]+([^ \t]+)[ \t]*(.*)$} $line mv name type comment] {
				if {$dbg} {
					puts "SHR: $name"
					puts "---: $type"
					puts "---: $comment"
				}
				if [regexp -nocase {^Disk$} $type] {
					set smb_local($smbhost:disk:$name) $comment
				} elseif [regexp -nocase {^Print} $type] {
					set smb_local($smbhost:printer:$name) $comment
				}
			}
		}
	}

	set smb_local($smbhost:domain) $domain
}

proc smb_list_unix {smbhost} {
	global smb_local smb_local_hosts smb_this_host
	set smbclient [in_path smbclient]
	if {[in_path smbclient] == ""} {
		return ""
	}
	set dbg 0

	set this_host [get_hostname]
	set This_host [string toupper $this_host]
	set smb_this_host $This_host

	set out1 ""
	catch {set out1 [exec smbclient -N -L $smbhost 2>@ stdout]}

	if {$dbg} {puts "SMBHOST: $smbhost"}
	if {$smbhost == $this_host || $smbhost == $This_host} {
		if {$out1 == ""} {
			catch {set out1 [exec smbclient -N -L localhost 2>@ stdout]}
		}
	}

	set domain ""
	set mode ""
	foreach line [split $out1 "\n"] {
		if [regexp {^[ \t]*---} $line] {
			continue
		}
		if [regexp {Anonymous login} $line] {
			continue
		}
		if {$domain == "" && [regexp {Domain=\[([^\]]+)\]} $line mv domain]} {
			if {$dbg} {puts "DOM: $domain"}
			continue
		}
		if [regexp {^[ \t]*Sharename} $line] {
			set mode "shares"
			continue
		}
		if [regexp {^[ \t]*Server} $line] {
			set mode "server"
			continue
		}
		if [regexp {^[ \t]*Workgroup} $line] {
			set mode "workgroup"
			continue
		}
		set line [string trim $line]
		if {$mode == "shares"} {
			if [regexp {^([^ \t]+)[ \t]+([^ \t]+)[ \t]*(.*)$} $line mv name type comment] {
				if {$dbg} {
					puts "SHR: $name"
					puts "---: $type"
					puts "---: $comment"
				}
				if [regexp -nocase {^Disk$} $type] {
					set smb_local($smbhost:disk:$name) $comment
				} elseif [regexp -nocase {^Printer$} $type] {
					set smb_local($smbhost:printer:$name) $comment
				}
			}
		} elseif {$mode == "server"} {
			if [regexp {^([^ \t]+)[ \t]*(.*)$} $line mv host comment] {
				if {$dbg} {
					puts "SVR: $host"
					puts "---: $comment"
				}
				set smb_local($smbhost:server:$host) $comment
			}
		} elseif {$mode == "workgroup"} {
			if [regexp {^([^ \t]+)[ \t]+(.*)$} $line mv work host] {
				if {$dbg} {
					puts "WRK: $work"
					puts "---: $host"
				}
				if {$host != ""} {
					set smb_local($smbhost:master:$work) $host
				}
			}
		}
	}

	set smb_local($smbhost:domain) $domain
}

proc smb_list {} {
	global is_windows smb_local smb_local_hosts
	global smb_host_list

	set smb_local(null) ""

	if {! [info exists smb_host_list]} {
		set smb_host_list ""
	}
	if [info exists smb_local] {
		unset smb_local
	}
	if [info exists smb_local_hosts] {
		unset smb_local_hosts
	}
			
	set this_host [get_hostname]
	set this_host [string toupper $this_host]
	if {$is_windows} {
		smb_list_windows $this_host
	} else {
		smb_list_unix $this_host
	}
	set did($this_host) 1 
	set keys [array names smb_local]
	foreach item [split $smb_host_list] {
		if {$item != ""} {
			set item [string toupper $item]
			lappend keys "$this_host:server:$item"
		}
	}
	foreach key $keys {
		if [regexp "^$this_host:server:(.*)\$" $key mv host]  {
			if {$host == ""} {
				continue
			}
			set smb_local_hosts($host) 1
			if {! [info exists did($host)]} {
				if {$is_windows} {
					smb_list_windows $host
				} else {
					smb_list_unix $host
				}
				set did($host) 1 
			}
		}
	}
}

proc smb_check_selected {} {
	global smbmount_exists smbmount_sumode
	global smb_selected smb_selected_mnt smb_selected_cb smb_selected_en

	set ok 0
	if {$smbmount_exists && $smbmount_sumode != "dontknow"} {
		set ok 1
	}
	set state disabled
	if {$ok} {
		set state normal
	}

	foreach cb [array names smb_selected_cb] {
		catch {$cb configure -state $state}
	}
	foreach en [array names smb_selected_en] {
		catch {$en configure -state $state}
	}
}

proc make_share_widgets {w} {
	
	set share_label $w.f.hl
	catch {$share_label configure -text "Share Name: PROBING ..."}
	update

	smb_list

	set saw_f 0
	foreach child [winfo children $w] {
		if {$child == "$w.f"} {
			set saw_f 1
			continue
		}
		catch {destroy $child}
	}

	set w1 47
	set w2 44

	if {! $saw_f} {
		set wf $w.f
		frame $wf
		label $wf.hl -width $w1 -text "Share Name:" -anchor w
		label $wf.hr -width $w2 -text "  Mount Point:" -anchor w

		pack $wf.hl $wf.hr -side left -expand 1
		pack $wf -side top -fill x

		.smbwiz.f.t window create end -window $w
	}

	global smb_local smb_local_hosts smb_this_host smb_selected smb_selected_mnt
	global smb_selected_host smb_selected_name
	global smb_selected_cb smb_selected_en
	global smb_host_list
	if [info exists smb_selected]      {array unset smb_selected }
	if [info exists smb_selected_mnt]  {array unset smb_selected_mnt}
	if [info exists smb_selected_cb]   {array unset smb_selected_cb}
	if [info exists smb_selected_en]   {array unset smb_selected_en}
	if [info exists smb_selected_host] {array unset smb_selected_host}
	if [info exists smb_selected_name] {array unset smb_selected_name}

	set hosts [list $smb_this_host]
	lappend hosts [lsort [array names smb_local_hosts]]

	set smb_host_list ""
	set i 0

	global smb_mount_prefix
	set smb_mount_prefix "/var/tmp/%USER-mnts"

	foreach host [lsort [array names smb_local_hosts]] {

		if [info exists did($host)] {
			continue
		}
		set did($host) 1

		append smb_host_list "$host "

		foreach key [lsort [array names smb_local]] {
			if [regexp {^([^:]+):([^:]+):(.*)$} $key mv host2 type name] {
				if {$host2 != $host}  {
					continue
				}
				if {$type != "disk"} {
					continue
				}
				set wf $w.f$i
				frame $wf
				checkbutton $wf.c -anchor w -width $w1 -variable smb_selected($i) \
					-text "//$host/$name" -relief ridge 
				if {! [info exists smb_selected($i)]} {
					set smb_selected($i) 0
				}

				entry $wf.e -width $w2 -textvariable smb_selected_mnt($i)
				set smb_selected_mnt($i) "$smb_mount_prefix/$host/$name"

				set smb_selected_host($i) $host
				set smb_selected_name($i) $name

				set smb_selected_cb($wf.c) $i
				set smb_selected_en($wf.e) $i
				set comment $smb_local($key)

				bind $wf.c <Enter> "$share_label configure -text {Share Name: $comment}"
				bind $wf.c <Leave> "$share_label configure -text {Share Name:}"

				$wf.c configure -state disabled
				$wf.e configure -state disabled

				pack $wf.c $wf.e -side left -expand 1
				pack $wf -side top -fill x
				incr i
			}
		}
	}
	if {$i == 0} {
		global is_win9x
		#.smbwiz.f.t insert end "\nNo SMB Share Hosts were found!\n"
		$share_label configure -text {Share Name: No SMB Share Hosts were found!}
		if {$is_win9x} {
			.smbwiz.f.t insert end "\n(this feature does not work on Win9x you have have to enter them manually: //HOST/share /var/tmp/mymnt)\n"
		}
	} else {
		$share_label configure -text "Share Name: Found $i SMB Shares"
	}
	smb_check_selected
}

proc smb_help_me_decide {} {
	global is_windows
	global smb_local smb_local_hosts smb_this_host smb_selected smb_selected_mnt
	global smb_selected_host smb_selected_name
	global smb_selected_cb smb_selected_en
	global smb_host_list

	catch {destroy .smbwiz}
	toplevel .smbwiz
	set title "SMB Filesystem Tunnelling -- Help Me Decide"
	wm title .smbwiz $title
	set id "  "

	scroll_text .smbwiz.f 100 40

	set msg {
For now you will have to verify the following information manually.

You can do this by either logging into the remote machine to find the info or asking the sysadmin for it.  

}

	if {! $is_windows} {
		.smbwiz.f.t configure -font {Helvetica -12 bold}
	}
	.smbwiz.f.t insert end $msg

	set w .smbwiz.f.t.f1
	frame $w -bd 1 -relief ridge -cursor {top_left_arrow}

	.smbwiz.f.t insert end "\n"

	.smbwiz.f.t insert end "1) Indicate the existence of the 'smbmount' command on the remote system:\n"
	.smbwiz.f.t insert end "\n$id"
	global smbmount_exists
	set smbmount_exists 0

	checkbutton $w.smbmount_exists -pady 1 -anchor w -variable smbmount_exists \
		-text "Yes, the 'smbmount' command exists on the remote system." \
		-command smb_check_selected

	pack $w.smbmount_exists
	.smbwiz.f.t window create end -window $w

	.smbwiz.f.t insert end "\n\n\n"

	set w .smbwiz.f.t.f2
	frame $w -bd 1 -relief ridge -cursor {top_left_arrow}

	.smbwiz.f.t insert end "2) Indicate your authorization to run 'smbmount' on the remote system:\n"
	.smbwiz.f.t insert end "\n$id"
	global smbmount_sumode
	set smbmount_sumode "dontknow"

	radiobutton $w.dk -pady 1 -anchor w -variable smbmount_sumode -value dontknow \
		-text "I do not know if I can mount SMB shares on the remote system via 'smbmount'" \
		-command smb_check_selected
	pack $w.dk -side top -fill x

	radiobutton $w.su -pady 1 -anchor w -variable smbmount_sumode -value su \
		-text "I know the Password to run commands as root on the remote system via 'su'" \
		-command smb_check_selected
	pack $w.su -side top -fill x

	radiobutton $w.sudo -pady 1 -anchor w -variable smbmount_sumode -value sudo \
		-text "I know the Password to run commands as root on the remote system via 'sudo'" \
		-command smb_check_selected
	pack $w.sudo -side top -fill x

	radiobutton $w.ru -pady 1 -anchor w -variable smbmount_sumode -value none \
		-text "I do not need to be root on the remote system to mount SMB shares via 'smbmount'" \
		-command smb_check_selected
	pack $w.ru -side top -fill x

	.smbwiz.f.t window create end -window $w

	global smb_wiz_done
	set smb_wiz_done 0

	button .smbwiz.done -text "Done" -command {set smb_wiz_done 1}
	pack .smbwiz.done -side bottom -fill x 
	pack .smbwiz.f -side top -fill both -expand 1

	wm protocol .smbwiz WM_DELETE_WINDOW {set smb_wiz_done 1}
	center_win .smbwiz

	wm title .smbwiz "Searching for Local SMB shares..."
	update
	wm title .smbwiz $title

	global smb_local smb_this_host
	.smbwiz.f.t insert end "\n\n\n"

	set w .smbwiz.f.t.f3
	catch {destroy $w}
	frame $w -bd 1 -relief ridge -cursor {top_left_arrow}

	.smbwiz.f.t insert end "3) Select SMB shares to mount and their mount point on the remote system:\n"
	.smbwiz.f.t insert end "\n${id}"

	make_share_widgets $w

	.smbwiz.f.t insert end "\n(%USER will be expanded to the username on the remote system and %HOME the home directory)\n"

	.smbwiz.f.t insert end "\n\n\n"

	.smbwiz.f.t insert end "You can change the list of Local SMB hosts to probe and the mount point prefix here:\n"
	.smbwiz.f.t insert end "\n$id"
	set w .smbwiz.f.t.f4
	frame $w -bd 1 -relief ridge -cursor {top_left_arrow}
	set wf .smbwiz.f.t.f4.f
	frame $wf
	label $wf.l -text "SMB Hosts:  "  -anchor w
	entry $wf.e -textvariable smb_host_list -width 60
	button $wf.b -text "Apply" -command {make_share_widgets .smbwiz.f.t.f3}
	bind $wf.e <Return> "$wf.b invoke"
	pack $wf.l $wf.e $wf.b -side left
	pack $wf
	pack $w

	.smbwiz.f.t window create end -window $w

	.smbwiz.f.t insert end "\n$id"

	set w .smbwiz.f.t.f5
	frame $w -bd 1 -relief ridge -cursor {top_left_arrow}
	set wf .smbwiz.f.t.f5.f
	frame $wf
	label $wf.l -text "Mount Prefix:"  -anchor w
	entry $wf.e -textvariable smb_mount_prefix -width 60
	button $wf.b -text "Apply" -command {apply_mount_point_prefix .smbwiz.f.t.f5.f.e}
	bind $wf.e <Return> "$wf.b invoke"
	pack $wf.l $wf.e $wf.b -side left
	pack $wf
	pack $w

	.smbwiz.f.t window create end -window $w

	.smbwiz.f.t insert end "\n\n\n"

	.smbwiz.f.t see 1.0
	.smbwiz.f.t configure -state disabled
	update

	vwait smb_wiz_done
	catch {destroy .smbwiz}

	if {! $smbmount_exists || $smbmount_sumode == "dontknow"} {
		tk_messageBox -type ok -icon warning -message "Sorry we couldn't help out!\n'smbmount' info on the remote system is required for SMB mounting" -title "SMB mounting -- aborting"
		catch {raise .oa}
		return
	}
	global smb_su_mode
	set smb_su_mode $smbmount_sumode

	set max 0
	foreach en [array names smb_selected_en] {
		set i $smb_selected_en($en)
		set host $smb_selected_host($i)
		set name $smb_selected_name($i)

		set len [string length "//$host/$name"]
		if {$len > $max} {
			set max $len
		}
	}

	set max [expr $max + 8]

	set strs ""
	foreach en [array names smb_selected_en] {
		set i $smb_selected_en($en)
		if {! $smb_selected($i)} {
			continue
		}
		set host $smb_selected_host($i)
		set name $smb_selected_name($i)
		set mnt $smb_selected_mnt($i)

		set share "//$host/$name"
		set share [format "%-${max}s" $share]
		
		lappend strs "$share $mnt"
	}
	set text ""
	foreach str [lsort $strs] {
		append text "$str\n"
	}

	global smb_mount_list
	set smb_mount_list $text

	smb_dialog
}

proc apply_mount_point_prefix {w} {
	global smb_selected_host smb_selected_name
	global smb_selected_en smb_selected_mnt

	set prefix ""
	catch {set prefix [$w get]}
	if {$prefix == ""} {
		mesg "No mount prefix."
		bell
		return
	}

	foreach en [array names smb_selected_en] {
		set i $smb_selected_en($en)
		set host $smb_selected_host($i)
		set name $smb_selected_name($i)
		set smb_selected_mnt($i) "$prefix/$host/$name"
	}
}

proc smb_dialog {} {
	catch {destroy .smb}
	toplevel .smb
	wm title .smb "SMB Filesystem Tunnelling"
	global smb_su_mode smb_mount_list
	global use_smbmnt

	global help_font

	scroll_text .smb.f

	set msg {
    Windows/Samba Filesystem mounting requires SSH be used to set up the SMB
    service port redirection.  This will be either of the "Use SSH instead"
    or "Use SSH and SSL" modes under "Options".  Pure SSL tunnelling will
    not work.

    This method requires a working Samba software setup on the remote
    side of the connection (VNC server) and existing Samba or Windows file
    server(s) on the local side (VNC viewer).

    The smbmount(8) program MUST be installed on the remote side.
    This evidently limits the mounting to Linux systems.  Let us know
    of similar utilities on other Unixes.  Mounting onto remote Windows
    machines is currently not supported (our SSH mode only works to Unix).

    Depending on how smbmount is configured you may be able to run it
    as a regular user, or it may require running under su(1) or sudo(8)
    (root password or user password required, respectively).  You select
    which one you want via the checkbuttons below.

    In addition to a possible su(1) or sudo(8) password, you may ALSO
    need to supply passwords to mount each SMB share. This is an SMB passwd.
    If it has no password just hit enter after the "Password:" prompt.

    The passwords are supplied when the 1st SSH connection starts up;
    be prepared to respond to them.

    NOTE: USE OF SMB TUNNELLING MODE WILL REQUIRE TWO SSH'S, AND SO YOU
    MAY NEED TO SUPPLY TWO LOGIN PASSWORDS UNLESS YOU ARE USING SOMETHING
    LIKE ssh-agent(1) or the Putty PW setting.
    %WIN

    To indicate the Windows/Samba shares to mount enter them one per line
    in either one of the forms:

      //machine1/share   ~/Desktop/my-mount1
      //machine2/fubar   /var/tmp/my-foobar2  192.168.100.53:3456
      1139  //machine3/baz  /var/tmp/baz      [...]

    The first part is the standard SMB host and share name //hostname/dir
    (note this share is on the local viewer-side not on the remote end).
    A leading '#' will cause the entire line to be skipped.

    The second part, e.g. /var/tmp/my-foobar2, is the directory to mount
    the share on the remote (VNC Server) side.  You must be able to
    write to this directory.  It will be created if it does not exist.
    A leading character ~ will be expanded to $HOME.  So will the string
    %HOME.  The string %USER will get expanded to the remote username.

    An optional part like 192.168.100.53:3456 is used to specify the real
    hostname or IP address, and possible non-standard port, on the local
    side if for some reason the //hostname is not sufficient.

    An optional leading numerical value, 1139 in the above example, indicates
    which port to use on the Remote side to SSH redirect to the local side.
    Otherwise a random one is tried (a unique one is needed for each SMB
    server:port combination).  A fixed one is preferred: choose a free
    remote port.

    The standard SMB ports are 445 and 139.  139 is used by this application.

    Sometimes "localhost" will not work on Windows machines for a share
    hostname, and you will have to specify a different network interface
    (e.g. the machine's IP address).  If you use the literal string "IP"
    it will be attempted to replace it with the numerical IP address, e.g.:

      //machine1/share   ~/Desktop/my-mount1   IP

    VERY IMPORTANT: Before terminating the VNC Connection, make sure no
    applications are using any of the SMB shares (or shells are cd-ed
    into the share).  This way the shares will be automatically umounted.
    Otherwise you will need to log in again, stop processes from using
    the share, become root and umount the shares manually ("smbumount
    /path/to/share", etc.)

    For more info see: http://www.karlrunge.com/x11vnc/#faq-smb-shares
}

	set msg2 {
    To speed up moving to the next step, iconify the first SSH console
    when you are done entering passwords, etc. and then click on the
    main panel 'VNC Server' label.
}

	global is_windows
	if {! $is_windows} {
		regsub { *%WIN} $msg "" msg
	} else {
		set msg2 [string trim $msg2]
		regsub { *%WIN} $msg "    $msg2" msg
	}
	.smb.f.t insert end $msg

	frame .smb.r
	label .smb.r.l -text "smbmount(8) auth mode:" -relief ridge
	radiobutton .smb.r.none -text "None" -variable smb_su_mode -value "none"
	radiobutton .smb.r.su   -text "su(1)" -variable smb_su_mode -value "su"
	radiobutton .smb.r.sudo -text "sudo(8)" -variable smb_su_mode -value "sudo"

	pack .smb.r.l .smb.r.none .smb.r.sudo .smb.r.su -side left -fill x

	label .smb.info -text "Supply the mounts (one per line) below:" -anchor w -relief ridge

	eval text .smb.mnts -width 80 -height 5 $help_font
	.smb.mnts insert end $smb_mount_list

	#apply_bg .smb.mnts

	button .smb.guess -text "Help me decide ..." -command {destroy .smb; smb_help_me_decide}
	#.smb.guess configure -state disabled

	button .smb.done -text "Done" -command {if {$use_smbmnt} {set_ssh; set smb_mount_list [.smb.mnts get 1.0 end]}; destroy .smb}
	bind .smb <Escape> {if {$use_smbmnt} {set_ssh; set smb_mount_list [.smb.mnts get 1.0 end]}; destroy .smb}

	pack .smb.done .smb.guess .smb.mnts .smb.info .smb.r -side bottom -fill x
	pack .smb.f -side top -fill both -expand 1

	center_win .smb
}

proc help_advanced_opts {} {
	catch {destroy .ah}
	toplevel .ah

	scroll_text_dismiss .ah.f

	center_win .ah

	wm title .ah "Advanced Opts Help"

	set msg {
    These Advanced settings are experimental options that may require extra
    software installed on the VNC server-side (the remote server machine)
    and/or on the VNC client-side (where this gui is running).

    The Service redirection options, CUPS, ESD/ARTSD, and SMB will require
    that you use SSH for tunneling so that the -R port redirection will
    be enabled for each service.  I.e. "Use SSH instead" or "Use SSH and SSL"

    These options may also require additional configuration to get them
    to work properly.  Please submit bug reports if it appears it should
    be working for your setup but is not.

    Brief descriptions:

         CUPS Print tunnelling: redirect localhost:6631 (say) on the VNC
         server to your local CUPS server.

         ESD/ARTSD Audio tunnelling: redirect localhost:16001 (say) on
         the VNC server to your local ESD, etc. sound server.

         SMB mount tunnelling: redirect localhost:1139 (say) on the VNC
         server and through that mount SMB file shares from your local
         server.  The remote machine must be Linux.

         Change vncviewer: specify a non-bundled VNC Viewer (e.g.
         UltraVNC or RealVNC) to run instead of the bundled TightVNC Viewer.

         Extra Redirs: specify additional -L port:host:port and 
         -R port:host:port cmdline options for SSH to enable additional
         services.

         Port Knocking: for "closed port" services, first "knock" on the
         firewall ports in a certain way to open the door for SSH or SSL.
	
    About the CheckButtons:

         Ahem, Well...., a klunky UI: you have to toggle the CheckButton
         to pull up the Dialog box a 2nd, etc. time... your settings will
         still be there.
}

	.ah.f.t insert end $msg
	#raise .ah
}

proc set_viewer_path {} {
	global change_vncviewer_path
	set change_vncviewer_path [tk_getOpenFile]
	catch {raise .chviewer}
	update
}

proc change_vncviewer_dialog {} {
	global change_vncviewer change_vncviewer_path vncviewer_realvnc4
	
	catch {destroy .chviewer}
	toplevel .chviewer
	wm title .chviewer "Change VNC Viewer"

	global help_font
	eval text .chviewer.t -width 90 -height 16 $help_font
	apply_bg .chviewer.t

	set msg {
    To use your own VNC Viewer (i.e. one installed by you, not included in this
    package), e.g. UltraVNC or RealVNC, type in the program name, or browse for
    the full path to it.  You can put command line arguments after the program.

    Note that due to incompatibilities with respect to command line options
    there may be issues, especially if many command line options are supplied.
    You can specify your own command line options below if you like (and try to
    avoid setting any others in this GUI).

    If the path to the program name has any spaces it in, please surround it with
    double quotes, e.g. "C:\Program Files\My Vnc Viewer\VNCVIEWER.EXE"

    Since the command line options differ between them greatly, if you know it
    is of the RealVNC 4.x flavor, indicate so on the check box.
}
	.chviewer.t insert end $msg

	frame .chviewer.path
	label .chviewer.path.l -text "VNC Viewer:"
	entry .chviewer.path.e -width 40 -textvariable change_vncviewer_path
	button .chviewer.path.b -text "Browse..." -command set_viewer_path
	checkbutton .chviewer.path.r -anchor w -variable vncviewer_realvnc4 -text \
		"RealVNC 4.x"

	pack .chviewer.path.l -side left
	pack .chviewer.path.e -side left -expand 1 -fill x
	pack .chviewer.path.b -side left
	pack .chviewer.path.r -side left

	button .chviewer.done -text "Done" -command {destroy .chviewer; catch {raise .oa}}
	bind .chviewer <Escape> {destroy .chviewer; catch {raise .oa}}

	pack .chviewer.t .chviewer.path .chviewer.done -side top -fill x

	center_win .chviewer
	wm resizable .chviewer 1 0

	focus .chviewer.path.e 
}

proc port_redir_dialog {} {
	global additional_port_redirs additional_port_redirs_list
	
	catch {destroy .redirs}
	toplevel .redirs
	wm title .redirs "Additional Port Redirections"

	global help_font
	eval text .redirs.t -width 80 -height 35 $help_font
	apply_bg .redirs.t

	set msg {
    Specify any additional SSH port redirections you desire for the
    connection.  Put as many as you want separated by spaces.  These only
    apply to SSH and SSH+SSL connections, they do not apply to Pure SSL
    connections.

    -L port1:host:port2  will listen on port1 on the local machine (where
                         you are sitting) and redirect them to port2 on
                         "host".  "host" is relative to the remote side
                         (VNC Server).  Use "localhost" for the remote
                         machine itself.

    -R port1:host:port2  will listen on port1 on the remote machine
                         (where the VNC server is running) and redirect
                         them to port2 on "host".  "host" is relative
                         to the local side (where you are sitting).
                         Use "localhost" for this machine.

    Perhaps you want a redir to a web server inside an intranet:

        -L 8001:web-int:80

    Or to redir a remote port to your local SSH daemon:

        -R 5022:localhost:22

    etc.  There are many interesting possibilities.

    Sometimes, especially for Windows Shares, you cannot do a -R redir to
    localhost, but need to supply the IP address of the network interface
    (e.g. by default the Shares do not listen on localhost:139).  As a
    convenience you can do something like -R 1139:IP:139 (for any port
    numbers) and the IP will be attempted to be expanded.  If this fails
    for some reason you will have to use the actual numerical IP address.
}
	.redirs.t insert end $msg

	frame .redirs.path
	label .redirs.path.l -text "Port Redirs:"
	entry .redirs.path.e -width 40 -textvariable additional_port_redirs_list

	pack .redirs.path.l -side left
	pack .redirs.path.e -side left -expand 1 -fill x

	button .redirs.done -text "Done" -command {destroy .redirs}
	bind .redirs <Escape> {destroy .redirs}

	pack .redirs.t .redirs.path .redirs.done -side top -fill x

	center_win .redirs
	wm resizable .redirs 1 0

	focus .redirs.path.e
}

proc find_netcat {} {
	global env is_windows

	set nc ""

	if {! $is_windows} {
		set nc [in_path "netcat"]
		if {$nc == ""} {
			set nc [in_path "nc"]
		}
	} else {
		set try "netcat.exe"
		if [file exists $try] {
			set nc $try
		}
	}
	return $nc
}

proc pk_expand {cmd host} {
	global tcl_platform
	set secs [clock seconds]
	set msecs [clock clicks -milliseconds]
	set user $tcl_platform(user)
	if [regexp {%IP} $cmd] {
		set ip [guess_ip]
		if {$ip == ""} {
			set ip "unknown"
		}
		regsub -all {%IP} $cmd $ip cmd
	}
	if [regexp {%NAT} $cmd] {
		set ip [guess_nat_ip]
		regsub -all {%NAT} $cmd $ip cmd
	}
	regsub -all {%HOST} $cmd $host cmd
	regsub -all {%USER} $cmd $user cmd
	regsub -all {%SECS} $cmd $secs cmd
	regsub -all {%MSECS} $cmd $msecs cmd

	return $cmd
}

proc backtick_expand {str} {
	set str0 $str
	set collect ""
	set count 0
	while {[regexp {^(.*)`([^`]+)`(.*)$} $str mv p1 cmd p2]} {
		set out [eval exec $cmd]
		set str "$p1$out$p2"
		incr count
		if {$count > 10}  {
			break
		}
	}
	return $str
}

proc read_from_pad {file} {
	set fh ""
	if {[catch {set fh [open $file "r"]}] != 0} {
		return "FAIL"
	}

	set accum ""
	set match ""
	while {[gets $fh line] > -1} {
		if [regexp {^[ \t]*#} $line] {
			append accum "$line\n"
		} elseif [regexp {^[ \t]*$} $line] {
			append accum "$line\n"
		} elseif {$match == ""} {
			set match $line
			append accum "# $line\n"
		} else {
			append accum "$line\n"
		}
	}

	close $fh

	if {$match == ""} {
		return "FAIL"
	}
	
	if {[catch {set fh [open $file "w"]}] != 0} {
		return "FAIL"
	}

	puts -nonewline $fh $accum

	return $match
}

proc do_port_knock {hp} {
	global use_port_knocking port_knocking_list
	global is_windows

	if {! $use_port_knocking} {
		return
	}
	if {$port_knocking_list == ""} {
		return
	}

	set default_delay 0

	set host [string trim $hp]
	regsub {^.*@} $host "" host
	regsub {:.*$} $host "" host
	set host0 [string trim $host]

	if {$host0 == ""} {
		bell
		mesg "No host: $hp"
		return
	}
	if [regexp {PAD=([^\n]+)} $port_knocking_list mv padfile] {
		set tlist [read_from_pad $padfile] 
		set tlist [string trim $tlist]
		if {$tlist == "" || $tlist == "FAIL"} {
			tk_messageBox -type ok -icon error \
				-message "Failed to read entry from $padfile" \
				-title "Error: Padfile $padfile"
			return
		}
		regsub -all {PAD=([^\n]+)} $port_knocking_list $tlist list
	} else {
		set list $port_knocking_list
	}

	set spl ",\n\r"
	if [regexp {CMD=}   $list] {set spl "\n\r"}
	if [regexp {CMDX=}  $list] {set spl "\n\r"}
	if [regexp {SEND=}  $list] {set spl "\n\r"}
	if [regexp {SENDX=} $list] {set spl "\n\r"}

	set i 0
	set pi 0

	foreach line [split $list $spl] {
		set line [string trim $line]
		set line0 $line

		if {$line == ""} {
			continue
		}
		if [regexp {^#} $line] {
			continue
		}
		if [regexp {^sleep[ \t][ \t]*([0-9][0-9]*)} $line mv sl] {
			mesg "sleep: $sl"
			after $sl
			continue
		}
		if [regexp {^delay[ \t][ \t]*([0-9][0-9]*)} $line mv sl] {
			mesg "delay: $sl"
			set default_delay $sl
			continue
		}

		if [regexp {^CMD=(.*)} $line mv cmd] {
			mesg "CMD: $cmd"
			eval exec $cmd
			continue
		}
		if [regexp {^CMDX=(.*)} $line mv cmd] {
			set cmd [pk_expand $cmd $host0]
			mesg "CMDX: $cmd"
			eval exec $cmd
			continue
		}
	
		if [regexp {`} $line] {
			#set line [backtick_expand $line]
		}

		set snd ""
		if [regexp {^(.*)SEND=(.*)$} $line mv line snd]  {
			set line [string trim $line]
			set snd [string trim $snd]
			regsub -all {%NEWLINE} $snd "\n" snd
		} elseif [regexp {^(.*)SENDX=(.*)$} $line mv line snd]  {
			set line [string trim $line]
			set snd [string trim $snd]
			set snd [pk_expand $snd $host0]
			regsub -all {%NEWLINE} $snd "\n" snd
		}

		set udp 0
		if [regexp -nocase {/udp} $line] {
			set udp 1
			regsub -all -nocase {/udp} $line "" line
			set line [string trim $line]
		}
		regsub -all -nocase {/tcp} $line "" line
		set line [string trim $line]

		set delay 0
		if [regexp {^(.*)[ \t][ \t]*([0-9][0-9]*)$} $line mv first delay] {
			set line [string trim $first]
		}

		if {[regexp {^(.*):(.*)$} $line mv host port]} {
			;
		} else {
			set host $host0
			set port $line
		}
		set host [string trim $host]
		set port [string trim $port]

		if {$host == ""} {
			set host $host0
		}

		if {$port == ""} {
			bell
			mesg "No port: $line0"
			continue
		}

		set nc ""
		if {$udp || $snd != ""} {
			set nc [find_netcat]
			if {$nc == ""} {
				bell
				mesg "UDP: netcat(1) not found"
				after 1000
				continue
			}
		}

		if {$snd != ""} {
			global env
			set pfile "payload$pi.txt" 
			if {! $is_windows} {
				set pfile "$env(HOME)/.$pfile"
			}
			set pfiles($pi) $pfile
			incr pi
			set fh [open $pfile "w"]
			puts -nonewline $fh "$snd"
			close $fh

			mesg "SEND: $host $port"
			if {$is_windows} {
				if {$udp} {
					catch {exec $nc -d -u -w 1 "$host" "$port" < $pfile &}
				} else {
					catch {exec $nc -d    -w 1 "$host" "$port" < $pfile &}
				}
			} else {
				if {$udp} {
					catch {exec $nc    -u -w 1 "$host" "$port" < $pfile &}
				} else {
					catch {exec $nc       -w 1 "$host" "$port" < $pfile &}
				}
			}
			catch {after 50; file delete $pfile}
			
		} elseif {$udp} {
			mesg "UDP: $host $port"
			if {! $is_windows} {
				catch {exec echo a | $nc -u -w 1 "$host" "$port" &}
			} else {
				set fh [open "nc_in.txt" "w"]
				puts $fh "a"
				close $fh
				catch {exec $nc -d -u -w 1 "$host" "$port" < "nc_in.txt" &}
			}
		} else {
			mesg "TCP: $host $port"
			set s ""
			set emess ""
			set rc [catch {set s [socket -async $host $port]} emess]
			if {$rc != 0} {
				tk_messageBox -type ok -icon error -message $emess -title "Error: socket -async $host $port"
			}
			set socks($i) $s
			# seems we have to close it immediately to avoid multiple SYN's.
			# does not help on Win9x.
			catch {after 30; close $s};
			incr i
		}

		if {$delay == 0} {
			if {$default_delay > 0} {
				after $default_delay
			}
		} elseif {$delay > 0} {
			after $delay
		}
	}

	if {0} {
		for {set j 0} {$j < $i} {incr j} {
			set $s $socks($j)
			if {$s != ""} {
				catch {close $s}	
			}
		}
	}
	for {set j 0} {$j < $pi} {incr j} {
		set f $pfiles($j)
		if {$f != ""} {
			if [file exists $f] {
				after 100
			}
			catch {file delete $f}	
		}
	}
	if {$is_windows} {
		catch {file delete "nc_in.txt"}
	}
}

proc port_knocking_dialog {} {
	catch {destroy .pk}
	toplevel .pk
	wm title .pk "Port Knocking"
	global use_port_knocking port_knocking_list

	global help_font

	scroll_text .pk.f 85

	set msg {
    Port Knocking is where a network connection to a service is not provided
    to just any client, but rather only to those that immediately prior to
    connecting send a more or less secret pattern of connections to other
    ports on the firewall.

    Somewhat like "knocking" on the door with the correct sequence before it
    being opened (but not necessarily letting you in yet).  It is also possible
    to have a single encrypted packet (e.g. UDP) payload communicate with the
    firewall instead of knocking on a sequence of ports.

    Only after the correct sequence of ports is observed by the firewall does
    it allow the IP address of the client to attempt to connect to the service.

    So, for example, instead of allowing any host on the internet to connect
    to your SSH service and then try to login with a username and password, the
    client first must "tickle" your firewall with the correct sequence of ports.
    Only then will it be allowed to connect to your SSH service at all.

    This does not replace the authentication and security of SSH, it merely
    puts another layer of protection around it. E.g., suppose an exploit for
    SSH was discovered, you would most likely have more time to fix/patch
    the problem than if any client could directly connect to your SSH server.

    For more information http://www.portknocking.org/ and
    http://www.linuxjournal.com/article/6811

    Tip: if you just want to use the Port Knocking for an SSH shell and not
    for a VNC tunnel, then specify something like "user@hostname cmd=SHELL"
    (or "user@hostname cmd=PUTTY" on Windows) in the VNC Server entry box
    on the main panel.  This will do everything short of starting the viewer.
    A shortcut for this is Ctrl-S.
    
    In the text area below put in the pattern of "knocks" needed for this
    connection.  You can separate the knocks by commas or put them one per line.
    Whitespace is trimmed.

    Each "knock" is of this form:

           [host:]port[/udp] [delay]

    In the simplest form just a numerical port, e.g. 5433, is supplied.

    The packet is sent to the same host that the VNC (or SSH) connection will
    be made to.  If you want it to go to a different host or IP use the [host:]
    prefix.  It can be either a hostname or numerical IP.

    TCP is assumed by default.

    If you need to send a UDP packet, the netcat (aka "nc") program must be
    installed on Unix (tcl/tk does not support udp connections).  Indicate this
    with "/udp" following the port number (you can also use "/tcp", but since
    it is the default it is not necessary).  For convenience a Windows netcat
    binary is supplied.

    Because an external program must be launched for each packet udp knocking will
    be somewhat slower and less reliable.  ICMP (ping) is currently not supported.

    The last field is the number of milliseconds to delay before continuing.

    Examples:

           5433,12321,1661

           fw.example.com:5433, 12321/udp 3000,1661 2000

           fw.example.com:5433
           12321/udp 3000
           1661 2000


    Alternate actions:  If the string in the text field contains anywhere the
    strings "CMD=", "CMDX=", or "SEND=", then splitting on commas is not done:
    it is only split on lines.

    Then, if a line begins CMD=... the string after the = is run as an
    external command.  The command could be anything you want, e.g. it could
    be a port-knocking client that does the knocking, perhaps encrypting the
    "knocks" pattern somehow or using a Single Packet Authorization method such
    as http://www.cipherdyne.com/fwknop/

    Extra quotes (sometimes "'foo bar'") may be needed to preserve spaces in
    command line arguments because the tcl/tk eval(n) command is used.  You
    can also use {...} for quoting strings with spaces.

    If a line begins CMDX=... then before the command is run the following
    tokens are expanded to strings:

      %IP       Current machine's IP address (NAT may make this not useful).
      %NAT      Try to get effective IP by contacting http://www.whatismyip.com
      %HOST     The remote host of the connection.
      %USER     The current user.
      %SECS     The current time in seconds (platform dependent).
      %MSECS    Platform dependent time having at least millisecond granularity.

   Lines not matching CMD= or CMDX= are treated as normal port knocks but with
   one exception.  If a line ends in SEND=... (i.e. after the [host:]port,
   etc., part) then the string after the = is sent as a payload for the tcp
   or udp connection to [host:]port.  netcat is used for these SEND cases
   (and must be available on Unix).  If newlines (\n) are needed in the
   SEND string, use %NEWLINE.  Sending binary data is not yet supported;
   use CMD= with your own program.

   Examples:

      CMD=port_knock_client -pass wombat33
      CMDX=port_knock_client -pass wombat33 -host %HOST -src %NAT

      fw.example.com:5433/udp SEND=ASDLFKSJDF

   More tricks:

      To temporarily "comment out" a knock, insert a leading "#" character.

      Use "sleep N" to insert a raw sleep for N milliseconds (e.g. between
      CMD=... items or at the very end of the knocks to wait).

      If a knock entry matches "delay N" the default delay is set to
      N milliseconds.

   One Time Pads:

      If the text contains a (presumably single) line of the form:

           PAD=/path/to/a/one/time/pad/file

      then that file is opened and the first non-blank line not beginning
      with "#" is used as the knock pattern.  The pad file is rewritten
      with that line starting with a "#" (so it will be skipped next time).

      The PAD=... string is replaced with the read-in knock pattern line.
      So, if needed, one can preface the PAD=... with "delay N" to set the
      default delay, and one can also put a "sleep N" after the PAD=...
      line to indicate a final sleep.  One can also surround the PAD=
      line with other knock and CMD= CMDX= lines, but that usage sounds
      a bit rare.  Example:

           delay 1000
           PAD=C:\My Pads\work-pad1.txt
           sleep 4000
}
	.pk.f.t insert end $msg

	label .pk.info -text "Supply port knocking pattern:" -anchor w -relief ridge

	eval text .pk.rule -width 80 -height 5 $help_font
	.pk.rule insert end $port_knocking_list
	#apply_bg .pk.rule

	button .pk.done -text "Done" -command {if {$use_port_knocking} {set port_knocking_list [.pk.rule get 1.0 end]}; destroy .pk}
	bind .pk <Escape> {if {$use_port_knocking} {set port_knocking_list [.pk.rule get 1.0 end]}; destroy .pk}

	pack .pk.done .pk.rule .pk.info -side bottom -fill x
	pack .pk.f -side top -fill both -expand 1

	center_win .pk
}


proc set_advanced_options {} {
	global env
	global use_cups use_sound use_smbmnt
	global change_vncviewer
	global use_port_knocking port_knocking_list

	catch {destroy .o}
	catch {destroy .oa}
	toplevel .oa
	wm title .oa "Advanced options"

	set i 1

	checkbutton .oa.b$i -anchor w -variable use_cups -text \
		"Enable CUPS Print tunnelling" \
		-command {if {$use_cups} {cups_dialog}}
	incr i

	checkbutton .oa.b$i -anchor w -variable use_sound -text \
		"Enable ESD/ARTSD Audio tunnelling" \
		-command {if {$use_sound} {sound_dialog}}
	incr i

	checkbutton .oa.b$i -anchor w -variable use_smbmnt -text \
		"Enable SMB mount tunnelling" \
		-command {if {$use_smbmnt} {smb_dialog}}
	incr i


	checkbutton .oa.b$i -anchor w -variable change_vncviewer -text \
		"Change VNC Viewer" \
		-command {if {$change_vncviewer} {change_vncviewer_dialog}}
	incr i

	checkbutton .oa.b$i -anchor w -variable additional_port_redirs -text \
		"Additional Port Redirs" \
		-command {if {$additional_port_redirs} {port_redir_dialog}}
	incr i

	checkbutton .oa.b$i -anchor w -variable use_port_knocking -text \
		"Port Knocking" \
		-command {if {$use_port_knocking} {port_knocking_dialog}}
	incr i

	for {set j 1} {$j < $i} {incr j} {
		pack .oa.b$j -side top -fill x
	}

	frame .oa.b
	button .oa.b.done -text "Done" -command {destroy .oa}
	bind .oa <Escape> {destroy .oa}
	button .oa.b.help -text "Help" -command help_advanced_opts

	pack .oa.b.help .oa.b.done -fill x -expand 1 -side left

	pack .oa.b -side top -fill x 

	center_win .oa
	wm resizable .oa 1 0
	focus .oa
}

proc in_path {cmd} {
	global env
	set p $env(PATH)
	foreach dir [split $p ":"] {
		set try "$dir/$cmd"
		if [file exists $try] {
			return "$try"
		}
	}
	return ""
}

proc ssh_agent_restart {} {
	global env 

	set got_ssh_agent 0
	set got_ssh_add 0
	set got_ssh_agent2 0
	set got_ssh_add2 0

	if [in_path "ssh-agent"]  {set got_ssh_agent 1}
	if [in_path "ssh-agent2"] {set got_ssh_agent2 1}
	if [in_path "ssh-add"]    {set got_ssh_add 1}
	if [in_path "ssh-add2"]   {set got_ssh_add2 1}

	set ssh_agent ""
	set ssh_add ""
	if {[info exists env(USER)] && $env(USER) == "runge"} {
		if {$got_ssh_agent2} {
			set ssh_agent "ssh-agent2"
		}
		if {$got_ssh_add2} {
			set ssh_add "ssh-add2"
		}
	}
	if {$ssh_agent == "" && $got_ssh_agent} {
		set ssh_agent "ssh-agent"
	}
	if {$ssh_add == "" && $got_ssh_add} {
		set ssh_add "ssh-add"
	}
	if {$ssh_agent == ""} {
		bell
		mesg "could not find ssh-agent in PATH"
		return
	}
	if {$ssh_add == ""} {
		bell
		mesg "could not find ssh-add in PATH"
		return
	}
	set tmp $env(HOME)/.vnc-sa[pid]
	set fh ""
	catch {set fh [open $tmp "w"]}
	if {$fh == ""} {
		bell
		mesg "could not open tmp file $tmp"
		return
	}

	puts $fh "#!/bin/sh"
	puts $fh "eval `$ssh_agent -s`"
	puts $fh "$ssh_add"
	puts $fh "SSL_VNC_GUI_CHILD=\"\"" 
	puts $fh "export SSL_VNC_GUI_CHILD" 

	global buck_zero
	set cmd $buck_zero
	
	if [info exists env(SSL_VNC_GUI_CMD)] {
		set cmd $env(SSL_VNC_GUI_CMD) 
	}
	#puts $fh "$cmd </dev/null 1>/dev/null 2>/dev/null &"
	puts $fh "nohup $cmd &"
	puts $fh "sleep 1"
	puts $fh "#rm -f $tmp"
	close $fh

	wm withdraw .
	catch {wm withdraw .o}
	catch {wm withdraw .oa}

	exec xterm -geometry +200+200 -title "Restarting with ssh-agent/ssh-add" -e sh $tmp &
	after 10000
	destroy .
	exit
}

proc putty_pw_entry {mode} {
	if {$mode == "check"} {
		global use_sshssl use_ssh
		if {$use_sshssl || $use_ssh} {
			putty_pw_entry enable
		} else {
			putty_pw_entry disable
		}
		return
	}
	if {$mode == "disable"} {
		catch {.o.pw.l configure -state disabled}
		catch {.o.pw.e configure -state disabled}
	} else {
		catch {.o.pw.l configure -state normal}
		catch {.o.pw.e configure -state normal}
	}
}

proc set_options {} {
	global use_alpha use_grab use_ssh use_sshssl use_viewonly use_fullscreen use_bgr233
	global use_nojpeg use_raise_on_beep use_compresslevel use_quality
	global compresslevel_text quality_text
	global env is_windows 

	catch {destroy .o}
	toplevel .o
	wm title .o "Set SSL VNC Viewer options"

	set i 1

	checkbutton .o.b$i -anchor w -variable use_ssh -text \
		"Use SSH instead" \
		-command {if {$use_ssh} {set use_sshssl 0}; putty_pw_entry check}
	incr i

	checkbutton .o.b$i -anchor w -variable use_sshssl -text \
		"Use SSH and SSL" \
		-command {if {$use_sshssl} {set use_ssh 0}; putty_pw_entry check}
	set iss $i
	incr i

	checkbutton .o.b$i -anchor w -variable use_viewonly -text \
		"View Only"
	incr i

	checkbutton .o.b$i -anchor w -variable use_fullscreen -text \
		"Fullscreen"
	incr i

	checkbutton .o.b$i -anchor w -variable use_raise_on_beep -text \
		"Raise On Beep"
	incr i

	checkbutton .o.b$i -anchor w -variable use_bgr233 -text \
		"Use 8bit color (-bgr233)"
	incr i

	checkbutton .o.b$i -anchor w -variable use_alpha -text \
		"Cursor alphablending (32bpp required)"
	set ia $i
	incr i

	checkbutton .o.b$i -anchor w -variable use_grab -text \
		"Use XGrabServer"
	set ix $i
	incr i

	checkbutton .o.b$i -anchor w -variable use_nojpeg -text \
		"Do not use JPEG (-nojpeg)"
	incr i

	menubutton .o.b$i -anchor w -menu .o.b$i.m -textvariable compresslevel_text
	set compresslevel_text "Compress Level: $use_compresslevel"

	menu .o.b$i.m -tearoff 0
	for {set j -1} {$j < 10} {incr j} {
		set v $j
		set l $j
		if {$j == -1} {
			set v "default"
			set l "default"
		}
		.o.b$i.m add radiobutton -variable use_compresslevel \
			-value $v -label $l -command \
			{set compresslevel_text "Compress Level: $use_compresslevel"}
	}
	incr i

	menubutton .o.b$i -anchor w -menu .o.b$i.m -textvariable quality_text
	set quality_text "Quality: $use_quality"

	menu .o.b$i.m -tearoff 0
	for {set j -1} {$j < 10} {incr j} {
		set v $j
		set l $j
		if {$j == -1} {
			set v "default"
			set l "default"
		}
		.o.b$i.m add radiobutton -variable use_quality \
			-value $v -label $l -command \
			{set quality_text "Quality: $use_quality"}
	}
	incr i

	for {set j 1} {$j < $i} {incr j} {
		pack .o.b$j -side top -fill x
	}

	if {$is_windows} {
		.o.b$ia configure -state disabled
		.o.b$ix configure -state disabled
	}

	if {$is_windows} {
		frame .o.pw	
		label .o.pw.l -text "Putty PW:"
		entry .o.pw.e -width 10 -show * -textvariable putty_pw
		pack .o.pw.l -side left
		pack .o.pw.e -side left -expand 1 -fill x
		pack .o.pw -side top -fill x 
		putty_pw_entry check
	} else {
		button .o.sa -text "Use ssh-agent" -command ssh_agent_restart
		pack .o.sa -side top -fill x 
	}

	button .o.s_prof -text "Save Profile ..." -command {save_profile; raise .o}
	button .o.l_prof -text " Load Profile ..." -command {load_profile; raise .o}
	button .o.advanced -text "Advanced ..." -command set_advanced_options
	button .o.clear -text "Clear Options" -command set_defaults
	pack .o.s_prof -side top -fill x 
	pack .o.l_prof -side top -fill x 
	pack .o.clear -side top -fill x 
	pack .o.advanced -side top -fill x 

	frame .o.b
	button .o.b.done -text "Done" -command {destroy .o}
	bind .o <Escape> {destroy .o}
	button .o.b.help -text "Help" -command help_opts

	pack .o.b.help .o.b.done -fill x -expand 1 -side left

	pack .o.b -side top -fill x 

	center_win .o
	wm resizable .o 1 0
	focus .o
}

set is_windows 0
set help_font "-font fixed"
if { [regexp -nocase {Windows} $tcl_platform(os)]} {
	cd util
	set help_font ""
	set is_windows 1
}

if {[regexp -nocase {Windows.9} $tcl_platform(os)]} {
	set is_win9x 1
} else {
	set is_win9x 0
}

set putty_pw ""


wm title . "SSL VNC Viewer"
wm resizable . 1 0

set_defaults
set skip_pre 0

set vncdisplay ""

label .l -text "SSL TightVNC Viewer" -relief ridge
frame .f
label .f.l -text "VNC Server:" -relief ridge
entry .f.e -width 40 -textvariable vncdisplay
pack .f.l -side left 
pack .f.e -side left -expand 1 -fill x
bind .f.e <Return> launch

frame .b
button .b.help  -text "Help" -command help
button .b.certs -text "Certs ..." -command getcerts
button .b.opts  -text "Options ..." -command set_options
button .b.conn  -text "Connect" -command launch
button .b.exit  -text "Exit" -command {destroy .; exit}


pack .b.certs .b.opts .b.conn .b.help .b.exit -side left -expand 1 -fill x

pack .l .f .b -side top -fill x
if {![info exists env(SSL_VNC_GUI_CHILD)] || $env(SSL_VNC_GUI_CHILD) == ""} {
	center_win .
}
focus .f.e
#raise .

global system_button_face
set system_button_face ""
foreach item [.b.help configure -bg] {
	set system_button_face $item
}

global env
if {[info exists env(SSL_VNC_GUI_CMD)]} {
	set env(SSL_VNC_GUI_CHILD) 1
	bind . <Control-n> "exec $env(SSL_VNC_GUI_CMD) &"
}
bind . <Control-q> "destroy .; exit"
bind . <Shift-Escape> "destroy .; exit"
bind . <Control-s> "launch_shell_only"

global entered_gui_top
set entered_gui_top 0
bind . <Enter> {set entered_gui_top 1}


#smb_help_me_decide
update
