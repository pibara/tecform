#!/usr/local/bin/perl
$SENDMAIL = "/usr/lib/sendmail";
$REMOTE_OK = "0";
$MAILDOMAIN = "flnet.nl";
$SINGLEUSER = "";
$DATADIR = "/usr/local/tecform/data";
$SHADOW = "http://www.flnet.nl/tecform/";
$VERSION = "2.0";
########################################################################
#                  TECForm 2.0  (Mar 24 1997)                          #
########################################################################
# Copyright (C) 1997  Rob J Meijer (rmeijer@xs4all.nl)                 #
#                                                                      #
# This program is free software; you can redistribute it and/or modify #
# it under the terms of the GNU General Public License as published by #
# the Free Software Foundation; either version 2 of the License.       #
#                                                                      #
# This program is distributed in the hope that it will be useful,      #
# but WITHOUT ANY WARRANTY; without even the implied warranty of       #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        #
# GNU General Public License for more details.                         #
#                                                                      #
# You should have received a copy of the GNU General Public License    #
# along with this program; if not, write to the Free Software          #
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.            #
########################################################################
$TIMEOUT=300;                     # timeout of 5 minutes.
$ENCODING="8bit";		  # default bodypart encoding 8bit
$MULTIPART="non";		  # default multipart typenon
$MULTI_OK=0;			  # default multipart off
sub header
{
  if ($headdone ne "1")
  {
    print "Content-type: text/html\n\n";
    print "<HTML><HEAD><TITLE>Template Extended CGI Form Mailer</TITLE>";
    print "</HEAD><BODY>\n";
    print " $RESP_HEADER";
    $headdone="1";
  }
}
sub footer
{
  print "<HR><CENTER>";
  if ($ENV{"PATH_INFO"} =~ /\/$/)
  {
     @tmplist=split(/\//,$ENV{"PATH_INFO"});
     $backcount=$#tmplist;
     print "<b><A HREF=\"../../tecform.pl/shadow/\">TECForM</A> ";
  }
  elsif ($ENV{"PATH_INFO"})
  {
     @tmplist=split(/\//,$ENV{"PATH_INFO"});
     $backcount=$#tmplist;
     print "<b><A HREF=\"../tecform.pl/shadow/\">TECForM</A> ";
  }
  else
  {
     print "<b><A HREF=\"tecform.pl/shadow/\">TECForM</A> ";
  }
  print "Template Extended CGI Form Mailer</b><br>";
  print "</CENTER>";
}
sub stopit
{
  local($head,$text)=@_;
  &header();
  print "<H3>$head</H3>$text\n";
  &footer();
  exit;
}
sub killthis
{
  select(STDOUT);
  do header();
  print "<TITLE>Error timeout ( $TIMEOUT sec )</TITLE>";
  print "<H3>Error: timeout ( $TIMEOUT sec )</H3>";
  print "A timeout error occured in the mail-a-form script.";
  exit;
}
sub printencoded {
 local($encoding,$string)=@_;
 $_=$string;
 if($encoding eq "quoted-printable")
 {
   s/\r//;
   s/=/Q5dsw34amMz/g;
   foreach $letter (0..9,"B","C","E","F")
   {
     s/\x0$letter/=0$letter/g;
   }
   foreach $letter (0..9,"A","B","C","D","E","F")
   {
     foreach $letterb (1,8,9,"A","B","C","D","E","F")
     {
       s/\x$letterb$letter/=$letterb$letter/g;
     }
   }
   s/\x20/=20/g;
   s/\x7F/=7F/g;
   s/Q5dsw34amMz/=3D/g;
   while (/([^\n]{73})([^\n])([^\n])([^\n]{2})/)
   {
       $s1=$1;$s2=$2;$s3=$3;$s4=$4;
       $s5="$1$2$3$4";
       if ($s3 eq "\=") 
       { 
         $s6="${s1}${s2}\=\n${s3}${s4}";
         s/$s5/$s6/;
       }
       elsif ($s2 eq "\=") 
       { 
         $s6="${s1}=\n${s2}${s3}${s4}";
         s/$s5/$s6/;
       }
       else 
       { 
         $s6="${s1}${s2}${s3}=\n${s4}";
         s/$s5/$s6/;
       }
   }
 print;
 }
 elsif(($encoding eq "8bit")||($encoding eq "7bit"))
 {
   if ($encoding eq "7bit")
   {
    foreach $letter (0..9,"A","B","C","D","E","F")
    {
      foreach $letterb (8..9,"A","B","C","D","E","F")
      {
       s/\x$letterb$letter/\$/g;
      }
    }
   }
   s/([^\n]{60}\w{0,15}) /$1\n /gs;
   s/([^\n]{75})([^\n]{2}])/$1\n$2/gs;
   print;
 }
 elsif($encoding eq "base64")
 {
    @base64tabel=('A' .. 'Z','a' .. 'z',0..9,"+","/","=");
    $ts="$_";
    $ln=length($ts)-1;
    $kn=int($ln/3);
    foreach $index (0 .. $kn)
    {
      $start=$index*3;
      $sub=substr($ts,$start,3);
      $tuplen=length($sub);
      $byte1=ord(substr($sub,0,1));
      $val1=int($byte1/4);
      if ($tuplen < 1) {$byte2=0;}
      else {$byte2=ord(substr($sub,1,1));}
      $val2=($byte1%4)*16+int($byte2/16);
      if ($tuplen < 1) {$byte3=0;}
      else {$byte3=ord(substr($sub,2,1));}
      $val3=($byte2%16)*4+int($byte3/64);
      $val4=$byte3%64;
      if ($tuplen < 3) {$val4=64;};
      if ($tuplen < 2) {$val3=64;};
      $txt1=$base64tabel[$val1];
      $txt2=$base64tabel[$val2];
      $txt3=$base64tabel[$val3];
      $txt4=$base64tabel[$val4];
      print "$txt1$txt2$txt3$txt4";
      if (($index%19)==18) {print "\n";}
    }
    print "\n";
 }
 else
 {
   print;
 }
}

#Return values from stalkers Mail.exe
%stalkerrorlist=(1,"Stalker Mail Invalid parameter error",
2,"Stalker Mail Invalid mail.ini error",
3,"Stalker Mail TCP/IP error",
4,"Stalker Mail SMTP error",
5,"Stalker Mail Mail not send (bad receipients)",
6,"Stalker Mail Mail partialy sent (some bad receipients)",
7,"Stalker Mail Program error");
#Return values from regular sendmail
%sendmailerrorlist=(
64,"command line usage error",
65,"data format error", 
66,"cannot open input", 
67,"addressee unknown", 
68,"host name unknown", 
69,"service unavailable", 
70,"internal software error", 
71,"system error (e.g., can't fork)", 
72,"critical OS file missing", 
73,"can't create (user) output file", 
74,"input/output error", 
75,"temp failure; user is invited to retry", 
76,"remote error in protocol", 
77,"permission denied", 
78,"configuration error"); 
# Lets see what errorlist we should use, for now we only have regular
# sendmail and 'stalkers' Mail.exe
if($SENDMAIL =~ /\/sendmail/)
{
 %errorlist=%sendmailerrorlist
}
else #ok, its not sendmail, lets gues its stalkers mail
{
 %errorlist=%stalkerrorlist
}
#We set a time limit, so a infinite loop, or other crap will always be killed. 
$SIG{'ALRM'}='killthis';
alarm($TIMEOUT);
##############################################################################
# Here we are asked for the position of the shadow site.
if ($ENV{"PATH_INFO"} =~ /^\/admin/) {$ADMIN=1;$UPDATE=0;}
if ($ENV{"PATH_INFO"} =~ /^\/update/){$ADMIN=1;$UPDATE=1;}
if ($ENV{"PATH_INFO"} =~ /^\/shadow/){$SHD=1;}
if(($DATADIR ne "")&&(chdir($DATADIR)))
{
  #Get all on/off options
  if(!open(INIFIL,"admin.dat"))
    {&stopit("Configuration Error", "cant open admin.dat");}
  while(<INIFIL>)
  {
    if (/^(\S+)\s+(\S+)/)
    {
      $INITLIST{"$1"}=$2;
    }
  }
  close(INIFIL);
  #
  if(!open(HEADER,"HEADER"))
    {&stopit("Configuration Error", "cant open HEADER");}
  while(<HEADER>)
  {
      $RESP_HEADER .= $_;
  }
  close(INIFIL);

  #Get the user/user-regex list
  if (($ADMIN)||($INITLIST{"UserListActive"} eq "on"))
  {
    if(!open(USERLIST,"userlist"))
      {&stopit("Configuration Error", "cant open userlist");}
    while(<USERLIST>)
    {
      if (/^(\S.*)$/)
      {
        push(@userlist,$1);
        $userlist{"$1"}=1;
      }
    }
    $UserListActive=1;
    close(USERLIST);
  }
  #Get the referer regular expression list.
  if (($ADMIN)||($INITLIST{"RefererCheck"} eq "on"))
  {  
    if(!open(REVLIST,"refererlist"))
      {&stopit("Configuration Error", "cant open userlist");}
    while(<REVLIST>)
    {
      if (/^(\S.*)$/)
      {
        push(@refererlist,$1);
      }
    }
    $RefererCheck=1;
    close(REVLIST);
  }  
  $AdminHosts=$INITLIST{"AdminHosts"};
  if ($INITLIST{"DenyDebug"} eq "on") {$DenyDebug=1;}
  if ($INITLIST{"UserListPlain"} eq "on") {$UserListPlain=1;}
  if ($INITLIST{"DisableEnv"} eq "on") {$DisableEnv=1;}
  if ($INITLIST{"DisableInfo"} eq "on") {$DisableInfo=1;}
  if ($INITLIST{"DenyRefLess"} eq "on") {$DenyRefLess=1;}
}
if ($ENV{"PATH_INFO"} =~ /^\/shadow/)
{
  &header();
  print "<H3>TECFORM</H3>For more information on TECForM, check out one\n";
  print "of the following TECForM sites\n<UL>";
  if ($SHADOW)
  {
     print "<LI><A HREF=\"$SHADOW\">Lokal</A> TECForM shadow site";
  }
  print "<LI><A HREF=\"http://www.xs4all.nl/~rmeijer/tecform.htm\">Main</A>";
  print " TECForM site.";
  print "</UL>";
  &footer();
  exit;
}
if((!$ADMIN)&&($ENV{"HTTP_REFERER"} eq "")&&($DenyRefLess))
{
  &stopit("Error","You seem to be directly calling TECForM,
   and the webmaster has disabled this. If you did submit
   a form, you are probably using a very limited or old browser");
}
if(($RefererCheck)&&(!$ADMIN)&&(!$SHD)&&($ENV{"HTTP_REFERER"} ne ""))
{
  $RefererOK=0;
  $Referer=$ENV{"HTTP_REFERER"};
  $index=0;
  while(($index<($#refererlist+1))&&(!$RefererOK))
  {
    $regex=$refererlist[$index];
    if ($Referer =~ /^$regex$/)
    {
      $RefererOK=1;
    }
    $index++;
  }
  if (!$RefererOK)
  {
    &stopit("Error","The webmaster has prohibited the use of
      TECForM from the place that you submitted the form");
  }
}
#Check if a form is submitted with debug set to on
if (($ENV{"PATH_INFO"} =~ /^\/debug/)&&(!$DenyDebug))
{
  &header();
  $DEBUG=1;
}
#############################################################################
#Check if the person calling on TECFoRM to post a form is so completely
#lame that he has chosen to use Microsoft Internet Exploder
if ($ENV{"HTTP_USER_AGENT"} =~ /MSIE/)
{
  $MSIEBUG=1;
} 
#Special case for '%'
$QUERYTABLE{'%'}="%";
#Ok, lets read in all the form content.
$QUERY= "$ENV{'QUERY_STRING'}";
$CL= "$ENV{'CONTENT_LENGTH'}";
$METHOD= "$ENV{'REQUEST_METHOD'}";
if ($METHOD eq "POST")
{
   while ($CL!=0)
   {
     $QUERY.=getc(STDIN);
     --$CL;
   }
}
#And now let split the crap up into lose queries
@QUERIES = split(/&/,$QUERY);
#And than process each of these queries
foreach $SplitIndex (0..$#QUERIES)
{
  ($queryname,$queryval)=split(/=/,$QUERIES[$SplitIndex]);
  #There is no escape from this unescape, lets start with querynames.
  while($queryname =~ /%[0123456789abcdefABCDEF][0123456789abcdefABCDEF]/)
  {
    $queryname =~ /.*%([0123456789abcdefABCDEF][0123456789abcdefABCDEF]).*/;
    $numtemp=hex("0$1");
    $kartemp=sprintf("%c",$numtemp);
    $queryname =~ s/%$1/$kartemp/;
  }
  #Lets get regular expressions out from those querynames.
  ($queryname,$errornum,$regexval)=split(/:/,$queryname,3);
  $_="$queryval";
  while(/\+/)
  {
    s/\+/ /;
  }
  #And now lets unescape those query values.
  while(/%[0123456789abcdefABCDEF][0123456789abcdefABCDEF]/)
  {
    /.*%([0123456789abcdefABCDEF][0123456789abcdefABCDEF]).*/;
    $numtemp=hex("0$1");
    $kartemp=sprintf("%c",$numtemp);
    if ($queryname ne "mltemplate")
    {
     if ($kartemp eq "&")
     {
       $kartemp="\\&";
     }
     if ($kartemp eq ";")
     {
       $kartemp="\\;";
     }
    }
    s/%$1/$kartemp/;
  }
  #Ok, lets try to fix that stupid Microsoft Internet Exploder bug.
  #It sents all newlines as returns, lets reconvert them so it will
  #be right again i hope.
  if ($MSIEBUG)
  {
     s/\r/\n/g;
  }
  $queryval=$_;
  #Check the query value against the regular expression
  if ($regexval ne "")
  {
    if ($queryval =~ /$regexval/)
    { $REGOK=1; }
    else
    {
      $REGEXERR=1;
      if ($errornum>$MAXERROR){$MAXERROR=$errornum};
      if ($DEBUG)
      {
        print "<BR><b>regular expression error:</b> $queryname=$queryval ; $regexval";
        print "  ( $errornum , $MAXERROR )\n";
      }
    }
  }
  # Put mlheader fields into a seperate hash
  if ($queryname =~ /^mlheader_/)
  {
    ($temp,$headername)=split(/_/,$queryname,2);
    $HEADERTABLE{$headername}="$queryval";
  }
  #process special form fields
  elsif($queryname eq "mlto")
  {
    $TO=$queryval;
  }
  elsif($queryname =~ /^mltemplate/)
  {
    ($tmp,$mimetype)=split(/_/,$queryname,2);
    push(@TEMPLATE,$queryval);
    if ($mimetype eq "")
    {
      $mimetype="text/plain";
    }
    push(@mimetype,$mimetype);
  }
  elsif($queryname eq "mloktxt")
  {
    $OKTXT=$queryval;
  }
  elsif($queryname eq "mlokurl")
  {
    $OKURL=$queryval;
  }
  elsif($queryname eq "mlerrurl")
  {
    $ERRURL=$queryval;
  }
  elsif($queryname =~ /^mlerrurl/)
  {
    ($tmp,$num)=split(/_/,$queryname,2);
    if($num =~ /^\d{2}$/)
    {
      $ERRURL{"$num"}=$queryval;
    }
  }
  elsif($queryname eq "mlerrtxt")
  {
    $ERRTXT=$queryval;
  }
  elsif($queryname =~ /^mlerrtxt/)
  {
    ($tmp,$num)=split(/_/,$queryname,2);
    if($num =~ /^\d{2}$/)
    {
      $ERRTXT{"$num"}=$queryval;
    }
  }
  elsif($queryname eq "mlneeded")
  {
    push(@NEEDED,$queryval);
    push(@NEEDEDERR,$errornum);
  }
  elsif($queryname eq "mlencoding")
  {
     if (($queryval eq "binary")||($queryval eq "7bit")||
        ($queryval eq "quoted-printable")||($queryval eq "base64"))
     {
       $ENCODING=$queryval;
     }
     else {$ENCODING="8bit";}
     
  }
  elsif($queryname eq "mlmultipart")
  {
     if (($queryval eq "alternative")||($queryval eq "paralel")||($queryval eq "mixed"))
     {
       $MULTIPART=$queryval;
       $MULTI_OK=1;       
     }
  }
  elsif ($queryname eq "mltecbase")
  {
    $TECBASE=$queryval;
    $TEMPLATE[0]="This message is TECBase encoded, and not readable for humans";
  }
  else
  {
    if($QUERYTABLE{$queryname} eq "")
    {
      $QUERYTABLE{$queryname}="$queryval";
    }
    else
    {
      $QUERYTABLE{$queryname}.=",$queryval";
    }
  }
}
#Add all enviroment stuff to the querytable
if (!$DisableEnv)
{
  foreach $index (sort keys(%ENV))
  {
    $QUERYTABLE{$index}=$ENV{$index};
  }
}
#Ok lets chech out if all the needed fields are filled out.
$NEEDEDOK=1;
foreach $index (0..$#NEEDED)
{
  $THISLINEOK=0;
  @NEEDLINE=split(/,/,$NEEDED[$index]);
  foreach $index2 (0..$#NEEDLINE)
  {
    if ($QUERYTABLE{$NEEDLINE[$index2]} ne "")
    {
       $THISLINEOK=1;
    }
  }
  if ($THISLINEOK==0)
  {
    $NEEDEDOK=0;
    $error=$NEEDEDERR[$index]; 
    if ($error> $MAXERROR) {$MAXERROR= $error;}
    if ($DEBUG)
    {
      print "<BR><b>mlneeded error:</b> $NEEDED[$index] ( $error, $MAXERROR )\n";
    }
  }
}



##############################################################################
#Special admin function of TECForM
if ($ENV{"PATH_INFO"} =~ /^\/admin/)
{
   do header();
   print "<H3>Tecform admin</H3>\n";
   if(!(chdir($DATADIR)))
   {
     print "Oops, instalation error, cant cd to \'$DATADIR\'";
     exit;
   }
   if (!($ENV{"REMOTE_HOST"} =~ /^${AdminHosts}$/))
   {
     $HOST=$ENV{"REMOTE_HOST"};    
     print "Error: you cant use admin from $HOST, the host regex is: $AdminHosts\n";
     exit;
   } 
   if ($QUERYTABLE{"adminpasswd"})
   {
      if (open(PASSWD,"passwd"))
      {
         $pass1=<PASSWD>;chop($pass1);
         $tmp=$QUERYTABLE{"adminpasswd"};
         $pass2=crypt("$tmp","TF");
         if ($pass1 eq $pass2)
         {
            sleep(4);
            print "Logged in.<br><br>\n";
            print "<FORM action=\"/cgi-bin/tecform.pl/update/\" method=\"post\">\n";
            foreach $key (sort keys %INITLIST)
            {
               $val=$INITLIST{"$key"};
               if ($val eq "on")
               {
                 print "$key <INPUT type=\"checkbox\" name=\"$key\" checked>\n";
               }
               elsif ($val eq "off")
               {
                 print "$key <INPUT type=\"checkbox\" name=\"$key\">\n";
               }
               else
               {
                 print "$key <INPUT type=\"text\" name=\"$key\" value=\"$val\" size=\"70\">\n";
               }
               print "<BR>";
            }
            print "<b>Userlist</b>\n<TEXTAREA ROWS=\"10\" COLS=\"40\" NAME=\"userlisttext\">\n";
            foreach $index (0 .. $#userlist)
            {        
              print "$userlist[$index]\n";
            }
            print "</TEXTAREA><BR>";
            print "<b>Refererlist</b>\n<TEXTAREA ROWS=\"10\" COLS=\"40\" NAME=\"refererlisttext\">\n";
            foreach $index (0 .. $#refererlist)
            {       
              print "$refererlist[$index]\n";
            }
            print "</TEXTAREA><BR>";
            print "<INPUT type=\"HIDDEN\" name=\"adminpasswd\" value=\"$tmp\">\n";
            print "<br><INPUT type=\"submit\"></FORM>\n";
         }
         else
         {
           sleep(6);
           print "Error: wrong password\n";
           print STDERR "\[$^T\] tecform.pl : password error $REMOTE_ADDR\n";
         }
      }
      else
      {
        print "Oops, instalation error, cant open passwd file";
        exit;
      }
   }
   else
   {
      print "<b>Admin login</b><BR>\n";
      print "<FORM action=\"/cgi-bin/tecform.pl/admin/\" method=\"post\">\n";
      print "Password: <INPUT type=\"TEXT\" name=\"adminpasswd\" SIZE=15>\n";
      print "<br><INPUT type=\"submit\"></FORM>\n";
   }
   &footer();
   exit;
}
#############################################################################
#Update part of the admin function
if ($ENV{"PATH_INFO"} =~ /^\/update/)
{
   do header();
   print "<H3>Tecform admin update</H3>\n";
   if(!(chdir($DATADIR)))
   {
     print "Oops, instalation error, cant cd to \'$DATADIR\'";
     exit;
   }
   if (!($ENV{"REMOTE_HOST"} =~ /^${AdminHosts}$/))
   {
     $HOST=$ENV{"REMOTE_HOST"};    
     print "Error: you cant use admin from $HOST, the host regex is: $AdminHosts\n";
     exit;
   } 
   if ($QUERYTABLE{"adminpasswd"})
   {
      if (open(PASSWD,"passwd"))
      {
        $pass1=<PASSWD>;chop($pass1);
        $tmp=$QUERYTABLE{"adminpasswd"};
        $pass2=crypt("$tmp","TF");
        if ($pass1 eq $pass2)
        {
          sleep(2);
          print "UPDATING ....<br><br>\n";
          if(!open(DATFIL,">admin.dat"))
          {
            print "Error: cant write to admin.dat, check file owner!!\n";
            &footer;
            exit;
          }
          foreach $key (sort keys %INITLIST)
          {
              $val=$INITLIST{"$key"};
              $oldval=$val;
              $newval=$QUERYTABLE{"$key"};
              if ($newval ne "")
              {
                $val = $newval; 
              }
              if (($newval eq "")&&($val eq "on"))
              {
                $val="off";
              }
              if ($key eq "AdminHosts")
              {
                 $host=$ENV{"REMOTE_HOST"};
                 if($host =~ /^$val$/)
                 {
                   print "<LI>OK, \"$host\" fits inside \"$val\"\n"; 
                 }
                 else 
                 {
                   print "<LI>Error: \"$host\" doesn't fit inside \"$val\"\n"; 
                   print ", you will expell yourself, using old one\n";
                   $val=$oldval;
                 }
              }
              print "<LI>$key : $val . \n";
              print DATFIL "$key $val\n";
          }
          close(DATFIL);
          if(!open(REVLIST,">refererlist"))
          {
            print "Error: cant write to refererlist, check file owner!!\n";
            &footer();
            exit;
          }
          $refererlisttext=$QUERYTABLE{"refererlisttext"};
          $refererlisttext=~ s/\r//g;
          print REVLIST "$refererlisttext";
          close(REVLIST);
          if(!open(USERLIST,">userlist"))
          {
            print "Error: cant write to userlist, check file owner!!\n";
            &footer();
            exit;
          }
          $userlisttext=$QUERYTABLE{"userlisttext"};
          $userlisttext=~ s/\r//g;
          print USERLIST "$userlisttext";
          close(USERLIST);
        }
        else
        {
         sleep(6);
         print "Error: wrong password\n";
         print STDERR "\[$^T\] tecform.pl : password error $REMOTE_ADDR\n";
        }
      }
      else
      {
        print "Oops, instalation error, cant open passwd file";
        exit;
      }
   }
   else
   {
      print "<b>Update error</b><BR>\n";
      print "There is no password\n";
   }
   &footer();
   exit;

  print "The update function should still be written, this is alpha software\n"; 
  &footer();
  exit;
}
#############################################################################
if ($DEBUG){ print "<HR>";}
if (($NEEDEDOK == 0)||($REGEXERR==1))
{
  if ($MAXERROR)
  {
    if ($ERRTXT{"$MAXERROR"})
    {
       $ERRTXT=$ERRTXT{"$MAXERROR"};
       &stopit("Error","$ERRTXT");
    }
    elsif ($ERRURL{"$MAXERROR"})
    {
      $ERRURL=$ERRURL{"$MAXERROR"};
      print "Location: http://$ENV{'SERVER_NAME'}$ERRURL\n\n";
      exit;
    }
    else
    {
      &stopit("multi error error","No errortext or url for Error $MAXERROR");
    }
  }
  if ($ERRTXT)
  {
       &stopit("Error","$ERRTXT");
  }
  if ($ERRURL)
  {
    print "Location: http://$ENV{'SERVER_NAME'}$ERRURL\n\n";
    exit;
  }
  else
  {
    &header();
    print "<H3>User Error</H3><UL>";
    if ($NEEDEDOK == 0) {print "<LI>Not all the required fields are filled in";}
    if ($REGEXERR == 1) {print "<LI>Not every field has a valid value";}
    print "</UL>";
    &footer();
  }
  exit;
}
#Substitute all the variables in the template.
foreach $index (0 .. $#TEMPLATE)
{
  $TEMPLATE=$TEMPLATE[$index];
  while ($TEMPLATE =~ /@\{.*\}@/)
  {
    ($a,$b)=split(/@\{/,$TEMPLATE,2);
    ($c,$d)=split(/\}@/,$b,2);  
    $TEMPLATE="$a$QUERYTABLE{$c}$d";
  }
  #Dont let a '.' end it all for sendmail
  while ($TEMPLATE =~ /\n.\r/)
  {
    $TEMPLATE =~ s/\n.\r/\n. \r/;
  }
  while ($TEMPLATE =~ /\n.\n/)
  {
    $TEMPLATE =~ s/\n.\n/\n. \n/;
  }
  $TEMPLATE[$index]=$TEMPLATE;
}
#We have got to put $TO into a system call, so lets check for funny stuff
$TO="" if ($TO =~ /!/);
$TO="" if ($TO =~ /;/);
$TO="" if ($TO =~ /\&/);
$TO="" if ($TO =~ /\|/);
$TO="" if ($TO =~ /\`/);
if ($SINGLEUSER)
{
  $TO=$SINGLEUSER;
}
if (($REMOTE_OK == 0)&&(!($UserListActive)))
{
  if ($TO =~ /\@/)
  {
        &header();
        print "<H3>Form Error</H3>";
        print "A valid mlto value should be in the form as hidden value\n<br>";
        print "The configuration of TECForM does not permit mailing $TO";
        &footer();
        exit;
  }
  else
  {$TO="$TO\@$MAILDOMAIN";}
}
elsif ($UserListActive)
{
  if($UserListPlain)
  {
     if (!($userlist{"$TO"}))
     {
        &header();
        print "<H3>Form Error</H3>";
        print "A valid mlto value should be in the form as hidden value\n<br>";
        print "The configuration of TECForM does not permit mailing $TO";
        &footer();
        exit;
     }
  }
  else
  {
    $ToOK=0;
    $index=0;
    while(($index<($#userlist+1))&&(!$ToOK))
    {
      $regex=$userlist[$index];
      if ($TO =~ /^$regex$/)
      {
        $ToOK=1;
      }
      $index++;
    }
    if (!$ToOK)
    {
        &header();
        print "<H3>Form Error</H3>";
        print "A valid mlto value should be in the form as hidden value\n<br>";
        print "The configuration of TECForM does not permit mailing $TO";
        &footer();
        exit;
    }
  }
}
if ($TO eq "")
{
  &stopit("Form Error","A valid mlto value should be in the form as hidden value"); }
if (!(@TEMPLATE))
{
  &stopit("Form Error","A valid mltemplate value should be in the form as hidden value");
}
#Now it comes down to it, we are calling sendmail now
if(!open(SENDMAIL,"|$SENDMAIL $TO"))
{
  &stopit("Fork error","Unable to fork $SENDMAIL");
}
select(SENDMAIL);
#Lets send the headers
$remhost=$ENV{"REMOTE_HOST"};
$localhost=$ENV{"SERVER_NAME"};
@date=gmtime(time);
$day=(Sun,Mon,Tue,Wed,Thu,Fri,Sat)[$date[6]];
foreach $index (0 ..2) {if ($day[$index]<10) {$day[$index]="0".$day[$index]}}
$month=(Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec)[$date[4]];
$year=$date[5]+1900;
$date="$day, $date[3] $month $year $date[2]:$date[1]:$date[0] GMT";
print "Received: from $remhost by $localhost with HTTP;$date\n";
print "Date: $date\n";
print "Message-Id: $^T$$\@$localhost\n"; 
print "To: $TO\n";
foreach $index (sort keys(%HEADERTABLE))
{
  print "$index: $HEADERTABLE{$index}\n";
}
print "Mime-Version : 1.0\n";
if ($TECBASE)
{
  print "Content-type : x-tecbase/querytable\n";
  print "X-TECBaseName: $TECBASE\n";  
  print "\n";
  foreach $key (keys %QUERYTABLE)
  {
    print "\$$key\n";
    $val=$QUERYTABLE{"$key"};
    &printencoded("base64","$val");
  }
}
else
{
 $boundary="TFb$^Tx04bxPFB";
 if($MULTI_OK)
 {
   print "Content-type : multipart/$MULTIPART; boundary=$boundary\n";  
   print "\n";
   print "This is a MIME message generated by the TECForM www/email gateway\n";
   print "$SHADOW\nhttp://www.xs4all.nl/~rmeijer/tecform.htm\n\n";
 }
 else {@TEMPLATE=$TEMPLATE[0];}
 foreach $index (0 .. $#TEMPLATE)
 {
     $mimetype=$mimetype[$index];
     $TEMPLATE=$TEMPLATE[$index];
     if($MULTI_OK){print "\n--$boundary\n";} 
     print "Content-type: $mimetype\n";
     print "Content-Transfer-Encoding: $ENCODING\n\n";
     &printencoded("$ENCODING","$TEMPLATE");
 }
 if($MULTI_OK)
 {
   if ((!$DisableInfo)&&($#TEMPLATE < 1)&&($MULTI_OK))
   {
     print "\n--${boundary}\n";
     print "Content-type: text/plain; name=tecform.txt
Content-Transfer-Encoding: 7bit

TECForM Information.

This message has been generated by a TECForM www/e-mail gateway.
TECForM is a freeware cgi script, and is usable for most
of your CGI scripting needs that involve mail.
You can find information about TECForM at:

* $SHADOW (your local tecform shadow site)
* http://www.xs4all.nl/~rmeijer/tecform.htm

Note that although the TECForM program is Freeware, your ISP may need
to charge you for its use, for it does consume some of your ISP's
system resources (as do all CGI programs). 

";
   }
 print "\n--${boundary}--\n";
 }
}
print "\r\n.\r\n\r\n";
select(STDOUT);
#Lets check if sendmail did ok.
if(close(SENDMAIL))
{ 
  if ($OKURL)
  {
    print "Location: http://$ENV{'SERVER_NAME'}$OKURL\n\n";
    exit;
  }
  else
  {
    &stopit("OK","Your mail has been successfully sent\n");
  }
}
else
{
  #Sendmail (or we) fucked up, lets find out what hapened.
  $probleem=$?/256;
  $descript=$errorlist{$probleem};
  if(!$descript){$descript = "Unknown error, probably bad tecform sendmail configuration, check if \"$SENDMAIL\" is a valid sendmail.\n\n";}
  &stopit("Configuration or Form error","sendmail or form error $probleem: $descript");
 }


