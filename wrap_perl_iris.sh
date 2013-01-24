#
# Wrap a perl script for execution in the development runtime environment.
#

if [ $# -ne 3 ] ; then
    echo "Usage: $0 dir source dest" 1>&2 
    exit 1
fi

dir=$1
src=$2
dst=$3

cat > $dst <<EOF
source /home/chenry/perl5/perlbrew/etc/bashrc
source /home/chenry/kbase/KBaseClient/user-env.sh
if [ ! \$KB_AUTH_TOKEN ]; then
if [ \$KB_IRIS_FOLDER ]; then
export KB_AUTH_TOKEN=IRIS-\$KB_IRIS_FOLDER
fi
fi
export KB_NO_FILE_ENVIRONMENT=1
export KB_WORKSPACEURL=http://bio-data-1.mcs.anl.gov/services/fba_gapfill
export KB_FBAURL=http://bio-data-1.mcs.anl.gov/services/fba
perl /home/chenry/kbase/KBaseClient/$src "\$@"
EOF

chmod +x $dst