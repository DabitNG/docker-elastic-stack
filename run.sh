#!/bin/bash
source ./.env

nodes=${ES_NODES}
echo "Nodes: ${nodes}"
node_list="es01"
i=2
while [ "$i" -le "${nodes}" ] ;do
    node_list=${node_list}",es0$i"
    i=$[$i+1]
done
echo "Node list: ${node_list}"
mkdir "es01"
cp node/.template.env "es01/.env"
cp node/node-template.yml "es01/docker-compose.yml"
sed -i -e 's/node/es01/g' ./es01/docker-compose.yml
sed -i -e 's/nnode/es01/g' ./es01/.env
echo "cluster.initial_master_nodes=${node_list}" >> ./es01/.env
echo "discovery.seed_hosts=$(echo "${node_list/es01,/""}")" >> ./es01/.env

i=2
cmd=" -f docker-compose.template.yml"
cmd=${cmd}" -f es01/docker-compose.yml"

echo "Creating nodes"
while [ $i -le $nodes ] ;do
    nodename="es0$i"
    mkdir "$nodename"
    cp node/.template.env "$nodename/.env"
    cp node/node-template.yml "$nodename/docker-compose.yml"
    sed -i -e 's/node/es0'${i}'/g' ./$nodename/docker-compose.yml
    sed -i -e 's/nnode/es0'${i}'/g' ./$nodename/.env
    sed -i '/.*ports.*/d' ./$nodename/docker-compose.yml
    sed -i '/.*ES_PORT.*/d' ./$nodename/docker-compose.yml
    search=",$nodename"
    sublist="${node_list//$search}"
    echo "cluster.initial_master_nodes=${node_list}" >> ./$nodename/.env
    echo "discovery.seed_hosts=${sublist}" >> ./$nodename/.env
    cmd=${cmd}" -f es0$i/docker-compose.yml"

    i=$[$i+1]
done


echo "Creating kibana"
cp kibana/.template.env kibana/.env
cp kibana/kibana.template.yml kibana/docker-compose.yml
cmd=${cmd}" -f kibana/docker-compose.yml"



echo "Creating kibana dependencies"
i=2
if [[ "1" != "$nodes" ]];
then
    echo "Generating conditions"
    echo -ne \
    "services:\n"\
    "  kibana:\n"\
    "    depends_on:\n"\
    "      es01:\n"\
    "        condition: service_healthy\n" > kibana/kibana.condition.yml
    while [ $i -le "$nodes" ] ;do
        echo -ne \
            "       es0$i:\n"\
            "        condition: service_healthy\n" >> kibana/kibana.condition.yml  
        i=$[$i+1]
    done
    cmd=${cmd}" -f kibana/kibana.condition.yml"
else
    echo "No additional dependencies"
fi

docker-compose ${cmd} config > docker-compose.yml && docker-compose -p ${COMPOSE_PROJECT} up
