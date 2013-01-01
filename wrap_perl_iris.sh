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
pushd . > /dev/null
SCRIPT_DIR="\${BASH_SOURCE[0]}";
if ([ -h "\${SCRIPT_DIR}" ]) then
while([ -h "\${SCRIPT_DIR}" ]) do cd \`dirname "\$SCRIPT_DIR"\`; SCRIPT_PATH=\`readlink "\${SCRIPT_DIR}"\`; done
fi
cd \`dirname \${SCRIPT_DIR}\` > /dev/null
SCRIPT_DIR=\`pwd\`;
popd  > /dev/null
source /home/chenry/perl5/perlbrew/etc/bashrc
source /home/chenry/kbase/KBaseClient/user-env.sh
export KB_NO_FILE_ENVIRONMENT="1"
export KB_WORKSPACEURL="http://bio-data-1.mcs.anl.gov/services/fba_gapfill"
export KB_FBAURL="http://bio-data-1.mcs.anl.gov/services/fba"
perl \$SCRIPT_DIR/../$src "\$@"
EOF

chmod +x $dst