#!/bin/bash -eu

# Tobias Wood 2015
# Test script for multiecho and similar programs

source ./test_common.sh
SILENCE_TESTS="1"

DATADIR="relax"
mkdir -p $DATADIR
cd $DATADIR
if [ "$(ls -A ./)" ]; then
    rm *
fi

SIZE="11 11 101"
$QUITDIR/qinewimage --size "$SIZE" -f 1 PD.nii
$QUITDIR/qinewimage --size "$SIZE" -g "0 0.5 1.5" T1.nii
$QUITDIR/qinewimage --size "$SIZE" -g "1 0.01 0.1" T2.nii
$QUITDIR/qinewimage --size "$SIZE" -g "2 -25.0 25.0" f0.nii
$QUITDIR/qinewimage --size "$SIZE" -f 1 B1.nii
# Setup parameters
SPIN_FILE="me.nii"
SPIN_PAR="2.5
0.005
0.005
16"

# Create input for Single Component
MCSIG_INPUT="PD.nii
T1.nii
T2.nii
f0.nii
B1.nii
$SPIN_FILE
SPINECHO
$SPIN_PAR
END"
echo "$MCSIG_INPUT" > qisignal.in
NOISE="0.002"
run_test "CREATE_SIGNALS" $QUITDIR/qisignal --1 -n -v --noise=$NOISE < qisignal.in

echo "$SPIN_PAR" > multiecho.in
run_test "SPINECHO_LOGLIN" $QUITDIR/qimultiecho $SPIN_FILE -n -v -al -oLL_     < multiecho.in
run_test "SPINECHO_LEVMAR" $QUITDIR/qimultiecho $SPIN_FILE -n -v -an -oLEVMAR_ < multiecho.in
run_test "SPINECHO_ARLO"   $QUITDIR/qimultiecho $SPIN_FILE -n -v -aa -oARLO_   < multiecho.in

compare_test "LOGLIN" T2.nii LL_ME_T.nii     $NOISE 50
compare_test "LEVMAR" T2.nii LEVMAR_ME_T.nii $NOISE 50
compare_test "ARLO"   T2.nii ARLO_ME_T.nii   $NOISE 50

cd ..
SILENCE_TESTS="0"
