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
perl \$SCRIPT_DIR/../$src "\$@"
EOF

chmod +x $dst