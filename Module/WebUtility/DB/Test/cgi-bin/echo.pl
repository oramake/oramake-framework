#!C:/cygwin/bin/perl.exe
##
##  echo -- demo CGI program which just prints parameters of requests.
##

print "Content-type: text/plain; charset=iso-8859-1\n\n";
foreach $var (sort(keys(%ENV))) {
  if ( $var =~ /CONTENT_|^HTTP_|QUERY_STRING|^REQUEST_|^REMOTE_/ ) {
    $val = $ENV{$var};
    $val =~ s|\n|\\n|g;
    $val =~ s|"|\\"|g;
    print "${var}=\"${val}\"\n";
  }
}

my $inStr = "";

print "\n\n*** STDIN: BEGIN\n";
while (<STDIN>) {
  $inStr = $inStr . $_;
  print $_ . "\n";
}
print "*** STDIN: END\n";

print "\n\n*** STDIN dump: BEGIN\n";
@str_dump = unpack( "C*", $inStr);
print "@str_dump";
print "\n*** STDIN dump: END\n";
