#!/bin/bash

copy () {
    rsync -avzp -e 'ssh' $1 $2
}

run () {
    ssh -o "StrictHostKeyChecking no" -t $SERVER $@
}

run_script () {
    ssh -o "StrictHostKeyChecking no" -t $SERVER 'bash -s' < $1 "$2"
}

clean () {
    # remove remote work dir
    run "rm -rf $REMOTE_WORK_DIR"
}

# make parallelism
NPROC=8

# verilator version
VERILATOR_VERSION=v4.028

# remote variables
REMOTE_WORK_DIR=$CI_DIR/$CIRCLE_PROJECT_REPONAME-$CIRCLE_BRANCH-$CIRCLE_SHA1-$CIRCLE_JOB
REMOTE_RISCV_DIR=$REMOTE_WORK_DIR/riscv-tools-install
REMOTE_ESP_DIR=$REMOTE_WORK_DIR/esp-tools-install
REMOTE_CHIPYARD_DIR=$REMOTE_WORK_DIR/chipyard
REMOTE_SIM_DIR=$REMOTE_CHIPYARD_DIR/sims/verilator
REMOTE_FIRESIM_DIR=$REMOTE_CHIPYARD_DIR/sims/firesim/sim
REMOTE_JAVA_ARGS="-Xmx8G -Xss8M -Dsbt.ivy.home=$REMOTE_WORK_DIR/.ivy2 -Dsbt.global.base=$REMOTE_WORK_DIR/.sbt -Dsbt.boot.directory=$REMOTE_WORK_DIR/.sbt/boot"
REMOTE_VERILATOR_DIR=$CI_DIR/$CIRCLE_PROJECT_REPONAME-$CIRCLE_BRANCH-$CIRCLE_SHA1-verilator-install

# local variables (aka within the docker container)
LOCAL_CHECKOUT_DIR=$HOME/project
LOCAL_RISCV_DIR=$HOME/riscv-tools-install
LOCAL_ESP_DIR=$HOME/esp-tools-install
LOCAL_CHIPYARD_DIR=$LOCAL_CHECKOUT_DIR
LOCAL_SIM_DIR=$LOCAL_CHIPYARD_DIR/sims/verilator
LOCAL_FIRESIM_DIR=$LOCAL_CHIPYARD_DIR/sims/firesim/sim

# key value store to get the build strings
declare -A mapping
mapping["chipyard-rocket"]="SUB_PROJECT=chipyard"
mapping["chipyard-sha3"]="SUB_PROJECT=chipyard CONFIG=Sha3RocketConfig"
mapping["chipyard-hetero"]="SUB_PROJECT=chipyard CONFIG=LargeBoomAndRocketConfig"
mapping["chipyard-boom"]="SUB_PROJECT=chipyard CONFIG=SmallBoomConfig"
mapping["chipyard-blkdev"]="SUB_PROJECT=chipyard CONFIG=SimBlockDeviceRocketConfig"
mapping["chipyard-hwacha"]="SUB_PROJECT=chipyard CONFIG=HwachaRocketConfig"
mapping["chipyard-gemmini"]="SUB_PROJECT=chipyard CONFIG=GemminiRocketConfig"
mapping["tracegen"]="SUB_PROJECT=chipyard CONFIG=NonBlockingTraceGenL2Config TOP=TraceGenSystem"
mapping["tracegen-boom"]="SUB_PROJECT=chipyard CONFIG=BoomTraceGenConfig TOP=TraceGenSystem"
mapping["firesim"]="DESIGN=FireSim TARGET_CONFIG=WithNIC_DDR3FRFCFSLLC4MB_FireSimRocketConfig PLATFORM_CONFIG=BaseF1Config"
mapping["fireboom"]="DESIGN=FireSim TARGET_CONFIG=WithNIC_DDR3FRFCFSLLC4MB_FireSimLargeBoomConfig PLATFORM_CONFIG=BaseF1Config"
mapping["chipyard-ariane"]="SUB_PROJECT=chipyard CONFIG=ArianeConfig"
mapping["fireariane"]="DESIGN=FireSim TARGET_CONFIG=WithNIC_DDR3FRFCFSLLC4MB_FireSimArianeConfig PLATFORM_CONFIG=BaseF1Config"
