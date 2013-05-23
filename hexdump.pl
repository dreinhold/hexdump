#!/usr/bin/perl
use strict;
# Perl script to emulate the linux hexdump command using -C
# Dylan Reinhold 05/22/2013

my $file = $ARGV[0] || die "No filename given\n";
my $count = 0;
my $read_size = "1024";

open(FH,"$file") or die "Could not open file $file $!\n";

while(my $full_len = sysread(FH,my $fh_data,$read_size)) {
 my $loop_count = int($full_len / 16 + .5);
 my $start_loc = 0;
 # An abitary string so the first line does not match
 my $last_line = "ZZZAAAZZZAAAZZZAAA"; 
 my $print_star = 1;
 for(my $j=0;$j<$loop_count;$j++) {
   my $len = 16;
   if($full_len - ($j * 16) < 16) {
     $len = $full_len - ($j * 16);
   }
   my $sub_data = substr($fh_data,$start_loc,$len);
   my $hex_data = unpack("(H*)*", $sub_data);
   if($last_line eq $hex_data) {
     # this line matches the last no need to print
     if($print_star) { 
       print "*\n"; 
       $print_star=0;
     }
   } else {
     $print_star = 1; #Reset the star print
     # Print Location
     printf("%08x  ",$count);
     # Loop the sting and format output
     my $loc = 0;
     my $print_str;
     for(my $i=0;$i<$len;$i++) {
       $loc = $i * 2;
       my $char = substr($hex_data,$loc,2);
       print "$char ";
       print " " if($i == 7); # Add extra space after 8th byte
     }
     # Pad the ASCII output when the data is not 16 bytes
     if($len < 16) {
       my $pad = (16 - $len) * 3;
       printf("% ${pad}s", "");
       if($len < 8) {
         print " ";
       }
     }
     # Turn non printable chars to .
     #$sub_data =~ tr/[\x0-\x1f\x7f-\xff]/./;
     print " |$sub_data|";
     print "\n";
   }
   $start_loc+=$len;
   $count += $len;
   $last_line = $hex_data;
 }
}
printf("%08x\n",$count);     
close(FH);
