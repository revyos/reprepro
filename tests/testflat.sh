#!/bin/bash

set -e
if [ "x$TESTINCSETUP" != "xissetup" ] ; then
	source $(dirname $0)/test.inc
fi

dodo test ! -d db
mkdir -p conf
cat > conf/distributions <<EOF
Codename: 1234
Components: a bb
UDebComponents: a
Architectures: x yyyyyyyyyy source
Update: flattest
EOF
cat > conf/updates.base <<EOF
Name: flattest
Flat: a
Method: file:$WORKDIR
Suite: flatsource
EOF

testrun - -b . export 1234 3<<EOF
stderr
stdout
-v2*=Created directory "./db"
-v1*=Exporting 1234...
-v2*=Created directory "./dists"
-v2*=Created directory "./dists/1234"
-v2*=Created directory "./dists/1234/a"
-v2*=Created directory "./dists/1234/a/binary-x"
-v6*= exporting '1234|a|x'...
-v6*=  creating './dists/1234/a/binary-x/Packages' (uncompressed,gzipped)
-v2*=Created directory "./dists/1234/a/binary-yyyyyyyyyy"
-v6*= exporting '1234|a|yyyyyyyyyy'...
-v6*=  creating './dists/1234/a/binary-yyyyyyyyyy/Packages' (uncompressed,gzipped)
-v2*=Created directory "./dists/1234/a/debian-installer"
-v2*=Created directory "./dists/1234/a/debian-installer/binary-x"
-v6*= exporting 'u|1234|a|x'...
-v6*=  creating './dists/1234/a/debian-installer/binary-x/Packages' (uncompressed,gzipped)
-v2*=Created directory "./dists/1234/a/debian-installer/binary-yyyyyyyyyy"
-v6*= exporting 'u|1234|a|yyyyyyyyyy'...
-v6*=  creating './dists/1234/a/debian-installer/binary-yyyyyyyyyy/Packages' (uncompressed,gzipped)
-v2*=Created directory "./dists/1234/a/source"
-v6*= exporting '1234|a|source'...
-v6*=  creating './dists/1234/a/source/Sources' (gzipped)
-v2*=Created directory "./dists/1234/bb"
-v2*=Created directory "./dists/1234/bb/binary-x"
-v6*= exporting '1234|bb|x'...
-v6*=  creating './dists/1234/bb/binary-x/Packages' (uncompressed,gzipped)
-v2*=Created directory "./dists/1234/bb/binary-yyyyyyyyyy"
-v6*= exporting '1234|bb|yyyyyyyyyy'...
-v6*=  creating './dists/1234/bb/binary-yyyyyyyyyy/Packages' (uncompressed,gzipped)
-v2*=Created directory "./dists/1234/bb/source"
-v6*= exporting '1234|bb|source'...
-v6*=  creating './dists/1234/bb/source/Sources' (gzipped)
EOF

mkdir lists

cp conf/updates.base conf/updates
cat >>conf/updates <<EOF
Components: a
EOF

testrun - -b . update 1234 3<<EOF
returns 255
stderr
*=./conf/updates:1 to 6: Update pattern may not contain Components and Flat fields ad the same time.
-v0*=There have been errors!
stdout
EOF

cp conf/updates.base conf/updates
cat >>conf/updates <<EOF
UDebComponents: a
EOF

testrun - -b . update 1234 3<<EOF
returns 255
stderr
*=./conf/updates:1 to 6: Update pattern may not contain UDebComponents and Flat fields ad the same time.
-v0*=There have been errors!
stdout
EOF

mv conf/updates.base conf/updates

testrun - -b . update 1234 3<<EOF
returns 255
stderr
*=aptmethod error receiving 'file:$WORKDIR/flatsource/Release':
*='File not found'
-v0*=There have been errors!
stdout
EOF

mkdir flatsource
touch flatsource/Release

testrun - -b . update 1234 3<<EOF
returns 255
stderr
-v1*=aptmethod got 'file:$WORKDIR/flatsource/Release'
-v2*=Copy file '$WORKDIR/flatsource/Release' to './lists/1234_flattest_rel_Release_data'...
*=Missing 'MD5Sum' field in Release file './lists/1234_flattest_rel_Release_data'!
-v0*=There have been errors!
stdout
EOF

echo "MD5Sum:" > flatsource/Release

testrun - -b . update 1234 3<<EOF
returns 254
stderr
-v1*=aptmethod got 'file:$WORKDIR/flatsource/Release'
-v2*=Copy file '$WORKDIR/flatsource/Release' to './lists/1234_flattest_rel_Release_data'...
*=Could not find 'Sources.gz' within the Release file of 'flattest':
*='./lists/1234_flattest_rel_Release_data'
-v0*=There have been errors!
stdout
EOF

echo " trash" >> flatsource/Release

testrun - -b . update 1234 3<<EOF
returns 255
stderr
-v1*=aptmethod got 'file:$WORKDIR/flatsource/Release'
-v2*=Copy file '$WORKDIR/flatsource/Release' to './lists/1234_flattest_rel_Release_data'...
*=Error parsing md5 checksum line ' trash' within './lists/1234_flattest_rel_Release_data'
-v0*=There have been errors!
stdout
EOF

touch flatsource/Sources.gz
touch flatsource/Packages.gz
cat > flatsource/Release <<EOF
MD5Sum:
 $(mdandsize flatsource/Sources.gz) Sources.gz
 $(mdandsize flatsource/Packages.gz) Packages.gz
EOF

testrun - -b . update 1234 3<<EOF
stderr
-v1*=aptmethod got 'file:$WORKDIR/flatsource/Release'
-v2*=Copy file '$WORKDIR/flatsource/Release' to './lists/1234_flattest_rel_Release_data'...
-v1*=aptmethod got 'file:$WORKDIR/flatsource/Sources.gz'
-v2*=Copy file '$WORKDIR/flatsource/Sources.gz' to './lists/1234_flattest_dsc_a_flat'...
-v1*=aptmethod got 'file:$WORKDIR/flatsource/Packages.gz'
-v2*=Copy file '$WORKDIR/flatsource/Packages.gz' to './lists/1234_flattest_deb_a_flat'...
stdout
-v0*=Calculating packages to get...
-v4*=  nothing to do for '1234|bb|source'
-v4*=  nothing to do for '1234|bb|yyyyyyyyyy'
-v4*=  nothing to do for '1234|bb|x'
-v3*=  processing updates for '1234|a|source'
-v5*=  reading './lists/1234_flattest_dsc_a_flat'
-v4*=  nothing to do for 'u|1234|a|yyyyyyyyyy'
-v3*=  processing updates for '1234|a|yyyyyyyyyy'
-v5*=  reading './lists/1234_flattest_deb_a_flat'
-v4*=  nothing to do for 'u|1234|a|x'
-v3*=  processing updates for '1234|a|x'
#-v5*=  reading './lists/1234_flattest_deb_a_flat'
-v0*=Getting packages...
-v1*=Shutting down aptmethods...
-v0*=Installing (and possibly deleting) packages...
EOF

cat > flatsource/Packages.gz <<EOF

EOF
cat > flatsource/Release <<EOF
MD5Sum:
 $(mdandsize flatsource/Sources.gz) Sources.gz
 $(mdandsize flatsource/Packages.gz) Packages.gz
EOF

testrun - -b . update 1234 3<<EOF
stderr
-v1*=aptmethod got 'file:$WORKDIR/flatsource/Release'
-v2*=Copy file '$WORKDIR/flatsource/Release' to './lists/1234_flattest_rel_Release_data'...
-v1*=aptmethod got 'file:$WORKDIR/flatsource/Packages.gz'
-v2*=Copy file '$WORKDIR/flatsource/Packages.gz' to './lists/1234_flattest_deb_a_flat'...
stdout
-v0*=Calculating packages to get...
-v4*=  nothing to do for '1234|bb|source'
-v4*=  nothing to do for '1234|bb|yyyyyyyyyy'
-v4*=  nothing to do for '1234|bb|x'
-v0*=  nothing new for '1234|a|source' (use --noskipold to process anyway)
-v4*=  nothing to do for 'u|1234|a|yyyyyyyyyy'
-v3*=  processing updates for '1234|a|yyyyyyyyyy'
-v5*=  reading './lists/1234_flattest_deb_a_flat'
-v4*=  nothing to do for 'u|1234|a|x'
-v3*=  processing updates for '1234|a|x'
#-v5*=  reading './lists/1234_flattest_deb_a_flat'
-v0*=Getting packages...
-v1*=Shutting down aptmethods...
-v0*=Installing (and possibly deleting) packages...
EOF

cat > flatsource/Packages.gz <<EOF
Package: test
Architecture: all
Version: 0
Filename: flatsource/test.deb
EOF
cat > flatsource/Release <<EOF
MD5Sum:
 $(mdandsize flatsource/Sources.gz) Sources.gz
 $(mdandsize flatsource/Packages.gz) Packages.gz
EOF

testrun - -b . update 1234 3<<EOF
stderr
-v1*=aptmethod got 'file:$WORKDIR/flatsource/Release'
-v2*=Copy file '$WORKDIR/flatsource/Release' to './lists/1234_flattest_rel_Release_data'...
-v1*=aptmethod got 'file:$WORKDIR/flatsource/Packages.gz'
-v2*=Copy file '$WORKDIR/flatsource/Packages.gz' to './lists/1234_flattest_deb_a_flat'...
stdout
-v0*=Calculating packages to get...
-v4*=  nothing to do for '1234|bb|source'
-v4*=  nothing to do for '1234|bb|yyyyyyyyyy'
-v4*=  nothing to do for '1234|bb|x'
-v0*=  nothing new for '1234|a|source' (use --noskipold to process anyway)
-v4*=  nothing to do for 'u|1234|a|yyyyyyyyyy'
-v3*=  processing updates for '1234|a|yyyyyyyyyy'
-v5*=  reading './lists/1234_flattest_deb_a_flat'
stderr
*=Missing 'Size' line in binary control chunk:
*=Missing 'MD5sum' line in binary control chunk:
*= 'Package: test
*=Architecture: all
*=Version: 0
*=Filename: flatsource/test.deb'
-v1*=Stop reading further chunks from './lists/1234_flattest_deb_a_flat' due to previous errors.
-v0*=There have been errors!
return 249
EOF

cat > flatsource/Packages.gz <<EOF
Package: test
Architecture: all
Version: 0
Filename: flatsource/test.deb
Size: 0
MD5Sum: $EMPTYMD5ONLY
EOF
cat > flatsource/Release <<EOF
MD5Sum:
 $(mdandsize flatsource/Sources.gz) Sources.gz
 $(mdandsize flatsource/Packages.gz) Packages.gz
EOF

testrun - -b . update 1234 3<<EOF
stderr
-v1*=aptmethod got 'file:$WORKDIR/flatsource/Release'
-v2*=Copy file '$WORKDIR/flatsource/Release' to './lists/1234_flattest_rel_Release_data'...
-v1*=aptmethod got 'file:$WORKDIR/flatsource/Packages.gz'
-v2*=Copy file '$WORKDIR/flatsource/Packages.gz' to './lists/1234_flattest_deb_a_flat'...
stdout
-v0*=Calculating packages to get...
-v4*=  nothing to do for '1234|bb|source'
-v4*=  nothing to do for '1234|bb|yyyyyyyyyy'
-v4*=  nothing to do for '1234|bb|x'
-v0*=  nothing new for '1234|a|source' (use --noskipold to process anyway)
-v4*=  nothing to do for 'u|1234|a|yyyyyyyyyy'
-v3*=  processing updates for '1234|a|yyyyyyyyyy'
-v5*=  reading './lists/1234_flattest_deb_a_flat'
-v4*=  nothing to do for 'u|1234|a|x'
-v3*=  processing updates for '1234|a|x'
#-v5*=  reading './lists/1234_flattest_deb_a_flat'
-v2=Created directory "./pool"
-v2=Created directory "./pool/a"
-v2=Created directory "./pool/a/t"
-v2=Created directory "./pool/a/t/test"
-v0*=Getting packages...
-v1*=Shutting down aptmethods...
stderr
*=aptmethod error receiving 'file:$WORKDIR/flatsource/test.deb':
*='File not found'
-v0*=There have been errors!
return 255
EOF

touch flatsource/test.deb

testrun - -b . update 1234 3<<EOF
stderr
-v1*=aptmethod got 'file:$WORKDIR/flatsource/Release'
-v2*=Copy file '$WORKDIR/flatsource/Release' to './lists/1234_flattest_rel_Release_data'...
-v1*=aptmethod got 'file:$WORKDIR/flatsource/test.deb'
-v2*=Linking file '$WORKDIR/flatsource/test.deb' to './pool/a/t/test/test_0_all.deb'...
stdout
-v0*=Calculating packages to get...
-v4*=  nothing to do for '1234|bb|source'
-v4*=  nothing to do for '1234|bb|yyyyyyyyyy'
-v4*=  nothing to do for '1234|bb|x'
-v0*=  nothing new for '1234|a|source' (use --noskipold to process anyway)
-v4*=  nothing to do for 'u|1234|a|yyyyyyyyyy'
-v3*=  processing updates for '1234|a|yyyyyyyyyy'
-v5*=  reading './lists/1234_flattest_deb_a_flat'
-v4*=  nothing to do for 'u|1234|a|x'
-v3*=  processing updates for '1234|a|x'
#-v5*=  reading './lists/1234_flattest_deb_a_flat'
-v2=Created directory "./pool"
-v2=Created directory "./pool/a"
-v2=Created directory "./pool/a/t"
-v2=Created directory "./pool/a/t/test"
-v0*=Getting packages...
-e1*=db: 'pool/a/t/test/test_0_all.deb' added to files.db(md5sums).
-d1*=db: 'pool/a/t/test/test_0_all.deb' added to checksums.db(pool).
-v1*=Shutting down aptmethods...
-v0*=Installing (and possibly deleting) packages...
-d1*=db: 'test' added to packages.db(1234|a|yyyyyyyyyy).
-d1*=db: 'test' added to packages.db(1234|a|x).
-v0*=Exporting indices...
-v6*= looking for changes in '1234|a|x'...
-v6*=  replacing './dists/1234/a/binary-x/Packages' (uncompressed,gzipped)
-v6*= looking for changes in 'u|1234|a|x'...
-v6*= looking for changes in '1234|a|yyyyyyyyyy'...
-v6*=  replacing './dists/1234/a/binary-yyyyyyyyyy/Packages' (uncompressed,gzipped)
-v6*= looking for changes in 'u|1234|a|yyyyyyyyyy'...
-v6*= looking for changes in '1234|a|source'...
-v6*= looking for changes in '1234|bb|x'...
-v6*= looking for changes in '1234|bb|yyyyyyyyyy'...
-v6*= looking for changes in '1234|bb|source'...
EOF

cat > flatsource/Packages.gz <<EOF
Package: test
Architecture: yyyyyyyyyy
Version: 1
Filename: flatsource/test.deb
Size: 0
MD5Sum: $EMPTYMD5ONLY
EOF
cat > flatsource/Release <<EOF
MD5Sum:
 $(mdandsize flatsource/Sources.gz) Sources.gz
 $(mdandsize flatsource/Packages.gz) Packages.gz
EOF

testrun - -b . update 1234 3<<EOF
stderr
-v1*=aptmethod got 'file:$WORKDIR/flatsource/Release'
-v2*=Copy file '$WORKDIR/flatsource/Release' to './lists/1234_flattest_rel_Release_data'...
-v1*=aptmethod got 'file:$WORKDIR/flatsource/Packages.gz'
-v2*=Copy file '$WORKDIR/flatsource/Packages.gz' to './lists/1234_flattest_deb_a_flat'...
-v1*=aptmethod got 'file:$WORKDIR/flatsource/test.deb'
-v2*=Linking file '$WORKDIR/flatsource/test.deb' to './pool/a/t/test/test_1_yyyyyyyyyy.deb'...
stdout
-v0*=Calculating packages to get...
-v4*=  nothing to do for '1234|bb|source'
-v4*=  nothing to do for '1234|bb|yyyyyyyyyy'
-v4*=  nothing to do for '1234|bb|x'
-v0*=  nothing new for '1234|a|source' (use --noskipold to process anyway)
-v4*=  nothing to do for 'u|1234|a|yyyyyyyyyy'
-v3*=  processing updates for '1234|a|yyyyyyyyyy'
-v5*=  reading './lists/1234_flattest_deb_a_flat'
-v4*=  nothing to do for 'u|1234|a|x'
-v3*=  processing updates for '1234|a|x'
-v2=Created directory "./pool"
-v2=Created directory "./pool/a"
-v2=Created directory "./pool/a/t"
-v2=Created directory "./pool/a/t/test"
-v0*=Getting packages...
-e1*=db: 'pool/a/t/test/test_1_yyyyyyyyyy.deb' added to files.db(md5sums).
-d1*=db: 'pool/a/t/test/test_1_yyyyyyyyyy.deb' added to checksums.db(pool).
-v1*=Shutting down aptmethods...
-v0*=Installing (and possibly deleting) packages...
-d1*=db: 'test' removed from packages.db(1234|a|yyyyyyyyyy).
-d1*=db: 'test' added to packages.db(1234|a|yyyyyyyyyy).
-v0*=Exporting indices...
-v6*= looking for changes in '1234|a|x'...
-v6*= looking for changes in 'u|1234|a|x'...
-v6*= looking for changes in '1234|a|yyyyyyyyyy'...
-v6*=  replacing './dists/1234/a/binary-yyyyyyyyyy/Packages' (uncompressed,gzipped)
-v6*= looking for changes in 'u|1234|a|yyyyyyyyyy'...
-v6*= looking for changes in '1234|a|source'...
-v6*= looking for changes in '1234|bb|x'...
-v6*= looking for changes in '1234|bb|yyyyyyyyyy'...
-v6*= looking for changes in '1234|bb|source'...
-v0*=Deleting files no longer referenced...
EOF

rm -r -f db conf dists pool lists flatsource
testsuccess