#!/usr/bin/perl
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
#Get the version from the version file
open(VERS,"VERSION")|| die "Please run me from my own dir";
$vers=<VERS>;
close(VERS);
chop($vers);
$tarname="tecform.$vers.tar";
$host=$ENV{'HOSTNAME'};
if (!$host)
{
  print "Oops, you have no 'HOSTNAME' enviroment variable set, i will try\n";
  print "to find the hostname\n";
  if (-e "/etc/HOSTNAME"){open(HN,"/etc/HOSTNAME");$host=<HN>;chop($host);}
  elsif (-x "/bin/hostname"){$host=`/bin/hostname`;chop($host);}
  else {print "oops, cant find my hostname\n\n"; $host="localhost";}
}
$path=$ENV{'PWD'};
if(!$path)
{  
  print "Oops, you have no 'PWD' enviroment variable set, i will try\n";
  print "to find the path\n";
  if (-x "/bin/pwd"){$path=`/bin/pwd`;chop($path);}
  elsif (-x "/bin/pwd"){$path=`/bin/pwd`;chop($path);}
  elsif (-x "/sbin/pwd"){$path=`/sbin/pwd`;chop($path);}
  elsif (-x "/usr/bin/pwd"){$path=`/usr/bin/pwd`;chop($path);}
  elsif (-x "/usr/sbin/pwd"){$path=`/usr/sbin/pwd`;chop($path);}
  elsif (-x "/usr/local/bin/pwd"){$path=`/usr/local/bin/pwd`;chop($path);}
  elsif (-x "/usr/local/sbin/pwd"){$path=`/usr/local/sbin/pwd`;chop($path);}
  else {print "Oops cant find the pwd command\n";}
  if(!$path) { print "we fucked up i cant find the current path\n";exit;}
}
$user="$>";
$installpath="/usr/local/tecform/";
if ($path =~ /(.*\/tecform\/)src/)
{
   $installpath=$1;
} 
else
{
  print "\nError you must run this script from your tecform/src/ dir !!\n\n";
  exit;
}
if (($path ne "/usr/local/tecform/src")&&($user == 0))
{
  print "\n\nTECForM install WARNING !!!,

tecform will be installed in the \"$installpath\" dir 
instead of the /usr/local/tecform dir, if you do not wish that to happen,
Please untar tecform in your /usr/local dir and try again\n\n";
print "press enter to install into the $installpath dir, ore use ctrl-c 
to stop:"; 
$tmp=<>;
foreach $index (0 .. 40) {print "\n";}
}
if ($user !=0)
{  
($name)=getpwuid($user);
print "Single user instalation for user $name in $installpath !!
To run a full instalation you must be root
press enter to continue single user instalation or ctrl-c to stop\n\n";
$tmp=<>;
foreach $index (0 .. 40) {print "\n";}

  if ($host)
  {
    $tecformurl="http://$host/~$name/tecform/";
  }
}
else
{
  print "Full TECForM setup in  $installpath\n\n";
  if ($host)
  {
    $tecformurl="http://$host/tecform/";
  }
}
if ((!(-e "${installpath}www/dist/$tarname"))&&
      (!(-e "${installpath}www/dist/$tarname\.gz")))
{
   print "${installpath}www/$tarname does not yet exist, lets see ";
   print "if its in ${installpath}../$tarname\n";
   if ((!(-e "${installpath}../$tarname"))&&
      (!(-e "${installpath}../$tarname\.gz")))
   {
     print "Oops i cant find the tarfile, and i need it for the shadow site\n";
     print "I will nevertheless continue, you will need to put in in your\n";
     print "TECForM shadow site manualy\n\n";
     print "Press enter to continue, or CTRL-C to stop:\n";
     $tmp=<>;
     foreach $index (0 .. 40) {print "\n";}
   }
   else
   {
     print "Yes, i'v got it, making a copy\n";
     $tmp=`cp ${installpath}../$tarname ${installpath}../$tarname\.gz ${installpath}www/dist/`;
   }
}
print "This script will try to turn the tecform.raw file into a tecform.pl
script, that is usable on your system\n\n";
print "\n\ntriing to determine location of perl.\n";
if (-e "/usr/local/bin/perl") {$perl="/usr/local/bin/perl";}
elsif (-e "/usr/bin/perl") {$perl="/usr/bin/perl";}
elsif (-e "/bin/perl") {$perl="/bin/perl";}
else
{
  print "Oops, i seem to be retarded, i know it must be here,\n";
  print "I am running in it so it must be here\n";
  print "Cant seem to find perl, give me the path please:";
  $perl=<>;
  foreach $index (0 .. 40) {print "\n";}
  chop($perl);
}
print "triing to determine location of sendmail.\n\n";
if (-e "/usr/lib/sendmail") {$sendmail="/usr/lib/sendmail";}
elsif (-e "/usr/bin/sendmail") {$sendmail="/usr/bin/sendmail";}
elsif (-e "/usr/sbin/sendmail") {$sendmail="/usr/sbin/sendmail";}
elsif (-e "/bin/sendmail") {$sendmail="/bin/sendmail";}
elsif (-e "/sbin/sendmail") {$sendmail="/sbin/sendmail";}
else
{
  print "Oops, i seem to be retarded, i know it must be here,\n";
  print "Cant seem to find sendmail, give me the path please:";
  $sendmail=<>;
  foreach $index (0 .. 40) {print "\n";}
  chop($sendmail);
}
if ($user == 0)
{
print "\n\nShould remote e-mail adresses be allowed (not recomended) \[n\]:";
$tmp=<STDIN>;chop($tmp);
foreach $index (0 .. 40) {print "\n";}
}
else
{
  $tmp = "N";
}
if (($tmp eq "Y")||($tmp eq "y")) {$remote="1";} 
else 
{
  $remote = "0";
  print "\n\nOk, i need the domain name for local mail if mail is to be sent to an 
other host than the web server is on, if its the same host just type 
enter.\n\n Mail domain [$host]:";
  $domain=<STDIN>;chop($domain);
  foreach $index (0 .. 40) {print "\n";}
  if (!$domain){$domain="$host";}
  if ($user)
  {
    $singleuser="$name";
  }
}
if ($user)
{
  print "Ok, do you wish to try (you will need access to chown) multiuser[n]:";
  $tmp=<>;
  if ($tmp =~ /[yY]/){$user=0;$singleuser="";}
}
if ($user ==0)
{
  print "\nSETTING UP TECFORM ADMIN CONFIG\n\n";
  print "Here comes the tricky part, seting up advanced featutures\n";
  print "For this we need to set up the data directory to be readable\n";
  print "by a cgi script running on your http server.\n";
  print "\nWe will need a password for WWW administration of TECForM\n\n";
  $tmp="";
  print "";
  while ($tmp eq "")
  {
    print "Please give an initial admin password [tecform]:";
    $tmp=<>;chop($tmp);
    foreach $index (0 .. 40) {print "\n";}
    if(!$tmp){$tmp="tecform";}
  }
  $cpass=crypt($tmp,"TF");
  open(PASS,">${installpath}data/passwd")||
    die "Cant open outputfile ${installpath}data/passwd";
  print PASS "$cpass\n";
  close(PASS);
  $tmp="";
  ($httpuser)=getpwnam("nobody");
  if ($httpuser) {$tmp=$httpuser;}
  ($httpuser)=getpwnam("www");
  if ($httpuser) {$tmp=$httpuser;}
  ($httpuser)=getpwnam("http");
  if ($httpuser) {$tmp=$httpuser;}
  ($httpuser)=getpwnam("httpd");
  if ($httpuser) {$tmp=$httpuser;}
  while($httpuid eq "")
  {
    print "Please give the user your httpd is running as [$tmp]:";
    $httpuid=<>;chop($httpuid);
    if(!$httpuid) {$httpuid="$tmp";}
    ($httpuid)=getpwnam($httpuid);
    if (!($httpuid)){print "Non existing username on this system\n";}
  } 
  foreach $index (0 .. 40) {print "\n";}
  print "\nchanging read/write bits and owner of the data dir and files\n";
  $tmp=`chmod 700 ${installpath}data/`;
  $tmp=`chown $httpuid ${installpath}data/`;
  $tmp=`chmod 400 ${installpath}data/passwd`;
  $tmp=`chown $httpuid ${installpath}data/passwd`;
  $tmp=`chmod 600 ${installpath}data/admin.dat`;
  $tmp=`chown $httpuid ${installpath}data/admin.dat`;
  $tmp=`chmod 600 ${installpath}data/userlist`;
  $tmp=`chown $httpuid ${installpath}data/userlist`;
  $tmp=`chmod 600 ${installpath}data/refererlist`;
  $tmp=`chown $httpuid ${installpath}data/refererlist`;
  $tmp=`chmod 644 ${installpath}data/HEADER`;

}
print "\n\nIMPORTANT !!!\n\n";
print "TECForM is now distributed as so called \"ShadowWare\"\n";
print "This means you can use TECForM freely and without costs,\n";
print "but you need to set up a shadow site of TECForM in one of your\n";
print "sub directories (this won't take up much space, or bandwith)\n";
while (!($shadowurl =~ /^http:\/\/\w+.*/))
{
  print "Give the url of where you will be shadowing tecform\n";
  if ($tecformurl) 
  {
    print "\[$tecformurl\]\n:";
  }
  $shadowurl=<>;chop($shadowurl);
  foreach $index (0 .. 40) {print "\n";}
  if (!$shadowurl) {$shadowurl=$tecformurl;}
}
print "\n\ntriing to make tecform file\n";
open(TECFORM,">${installpath}cgi-bin/tecform.pl")|| 
   die "Cant open outputfile ${installpath}cgi-bin/tecform.pl"; 
print TECFORM "#!$perl\n";
print TECFORM "\$SENDMAIL = \"$sendmail\"\;\n";
print TECFORM "\$REMOTE_OK = \"$remote\"\;\n";
print TECFORM "\$MAILDOMAIN = \"$domain\"\;\n";
print TECFORM "\$SINGLEUSER = \"$singleuser\"\;\n";
print TECFORM "\$DATADIR = \"${installpath}data\"\;\n";
print TECFORM "\$SHADOW = \"$shadowurl\"\;\n";
print TECFORM "\$VERSION = \"$vers\"\;\n";

open(RAWFILE,"tecform.raw")||die "Cant open input file tecform.raw";
while(<RAWFILE>)
{
  print TECFORM "$_";
}
close(TECFORM);close(RAWFILE);
print "\nchanging execute bits of tecform.pl\n";
$tmp=`chmod 755 ${installpath}cgi-bin/tecform.pl`;
print "\n\n\nI think you can now copy tecform/cgi-bin/tecform.pl to your cgi-bin dir\n";
print "Please look at the first few lines of tecform.pl to see if it seems ok\n";
print "Also don't forget to set up the shadow site for tecform, by
moving the tecform/www dir to the place you specified as shadow url,
or setting a symbolic link from it to tecform/www in your document 
root.\n\n\n\n";

