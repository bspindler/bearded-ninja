#!/usr/bin/perl

use strict;

my $REPOS = $ARGV[0];
my $TXN = $ARGV[1];

my $logfile="pre-commit.log";
my $SVNLOOK="/usr/bin/svnlook";
my $svnlook_output = `$SVNLOOK dirs-changed -t "$TXN" "$REPOS"`;
$svnlook_output = trim($svnlook_output);
my @dirs_changed = split(/\n/, $svnlook_output);

my $author = `$SVNLOOK author -t "$TXN" "$REPOS"`;
$author = trim($author);

my $log = `$SVNLOOK log -t "$TXN" "$REPOS"`;
$log = trim($log);

my @locked_dirs =( 
"path/branches/somebranch");

my $tokenMap = {
    'TOKEN1' => 'JIRAISSUE'
};

open(FILE, ">>$logfile") || die "Can't open logfile: $!\n";
print FILE "***************************************************************\n";
print FILE "*** TXN: $TXN \n";
print FILE "*** DIRS-CHANGED(".@dirs_changed."): $svnlook_output\n";
print FILE "*** AUTHOR: $author \n";
print FILE "*** LOG: $log \n";
#############################################################
# if this is set to 1 - a token with an associated
# JIRA ticket is present which means it's authorized
# let the commit succeed without checking frozen dirs
#############################################################
my $override = 0;
foreach my $key ( keys %$tokenMap ) {
    if($log =~ $key 
            && $log =~ $tokenMap->{$key}) {
        print FILE "*** TOKEN OVERRIDE: \n";
        print FILE "* $key --> ". $tokenMap->{$key} . "\n";
        $override = 1;
    }
}
if(!$override) {
    foreach my $dir (@locked_dirs) {
        my @matches = grep(/^$dir.*/, @dirs_changed);
        if(@matches) {
            foreach(@matches) {
                print STDERR "Check-In failed - the path($_) is frozen.\n";
                print FILE "Check-In failed - the path($_) is frozen.\n";
            }
            print FILE "***************************************************************\n";
            exit 1;
         }
    }
}
close(FILE);

sub trim($)
{
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}
