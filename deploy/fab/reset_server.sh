#!/bin/bash
export rs="reset_server.sh STATUS: "
echo $rs activate aei_dropq
export DEP=/home/ubuntu/deploy
export PATH="/home/ubuntu/miniconda2/bin:$PATH"

conda config --set always_yes yes --set changeps1 no
conda clean --all
conda env remove --name aei_dropq
conda env create -f $DEP/fab/dropq_environment.yml

source /home/ubuntu/miniconda2/bin/activate aei_dropq
pushd ${DEP}
python setup.py install
popd
echo $rs get taxpuf package
cd $DEP
export TAXPUF_CHANNEL="https://conda.anaconda.org/t/$(cat /home/ubuntu/.ospc_anaconda_token)/opensourcepolicycenter"
conda config --add channels $TAXPUF_CHANNEL
conda install taxpuf
rm -rf puf.csv.gz rm puf.csv
write-latest-taxpuf && gunzip -k puf.csv.gz
export SUPERVISORD_CONF=/home/ubuntu/deploy/fab/supervisord.conf
echo $rs stop all
supervisorctl -c $SUPERVISORD_CONF stop all

for repeat in 1 2 3;
    do
        bash ${DEP}/taxbrain_server/scripts/ensure_procs_killed.sh flask;
        bash ${DEP}/taxbrain_server/scripts/ensure_procs_killed.sh celery;
        sleep 2;
    done
cd $DEP/..
echo $rs configure conda
echo $rs remove old versions
echo $rs Install taxcalc
cd $DEP/.. && rm -rf Tax-Calculator B-Tax OG-USA

cd $DEP

# TODO LATER
# conda install -c ospc btax --no-deps
echo $rs redis-cli FLUSHALL
redis-cli FLUSHALL

conda list
echo $rs Remove asset_data.pkl and recreate it with btax execute
rm -f asset_data.pkl
python -c "from btax.execute import runner;runner(False,2013,{})"
echo $rs supervisorctl -c $SUPERVISORD_CONF start all
supervisorctl -c $SUPERVISORD_CONF start all
python -c "from taxcalc import *;from btax import *;from ogusa import *" && ps ax | grep flask | grep python && ps ax | grep celery | grep python && echo $rs RUNNING FLASK AND CELERY PIDS ABOVE
echo $rs DONE - OK
