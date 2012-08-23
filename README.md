bearded-ninja
=============

A svn pre-commit hook that allows you to freeze code down to the path level with token level overrides for individual access.  I wrote this script to allow me to bring the code to a slush state (essentially frozen with only authorized commits (those with tokens) allowed), the following features are available: 

<ul>
	<li>Path level locking/freezing.</li>
	<li>Token based authorizations - coupled with issue management association</li>
</ul>

Installation
=============
add the 'commit-access-control.pl' to your <svn-repos-path>/<repo>/hooks directory
make it executable: 
  chmod +x commit-access-control.pl
in that same directory, modify the 'pre-commit' script and add the following line: 

<svn-repos-path>/<repos>/hooks/commit-access-control.pl "$REPOS" "$TXN" || exit 1
