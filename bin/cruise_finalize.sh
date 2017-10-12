#!/bin/bash

# cruise_finalize.sh
#  2010-01-22:jmeyer@ucsd.edu: create.
#  2010-01-23:jmeyer@ucsd.edu: clean up.

# Finalize a cruise directory by locking the write permissions and
# creating a meta data inventory of the data the way it left the
# ship.  Its a little kludgy for now, but better than nothing.
#
# This script should ultimately generate four files:
# md5sum.txt, sha1sum.txt, stat.txt and ls.txt
# ...in the directory you provide as an argument, E.G.
#	cruise_finalize.sh /vol/1/cruise/CURRENT
#
#  It will take a while to run...  20 min to hours?
#
# You'll see all the output spew by, but it's also
# getting written to the appropriate files.
# Once you see a prompt, verify the four files exist.

function Usage() {
	echo "You must provide a valid path to operate on." 1>&2
	echo "E.G. \`$0 /vol/1/cruise/CURRENT\`" 1>&2
	exit $1
}

dir=$1
[ '' == "$1" ] && Usage 1

# Change directory immediately, since automount dirs won't show until we do.
cd $dir || Usage 2

# Verify input
[ -d $1 ] || Usage 3

# Lock down group/other writing
chmod -R go-w $dir && \
echo "`date -u` $dir locked down for group/other writing."

# Remove files we're about to create, if they exist
if [ -d $dir/meta ]; then
	rm -fv $dir/meta/{md5sum,sha1sum,stat,ls}.txt
else
	mkdir -v $dir/meta
fi

# Generate metadata
ls -lR | tee $dir/meta/ls.txt
for i in md5sum sha1sum stat; do
	find . -type f -not -name meta -exec $i "{}" \; | tee $dir/meta/$i.txt
done

# Lock down user writing
chmod -R u-w .  && \
 echo "`date -u` $dir locked down for owner writing."
