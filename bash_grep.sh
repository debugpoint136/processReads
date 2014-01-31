#!/bin/bash

properties=`readlink -f input.parameters`
preproperties=`readlink -f preprocess/build.properties`

echo "Parsing properties File..."
echo "..."

IFS=$'\n';
for i in `cat $properties`;do
key=`echo $i | awk -F'=' '{print $1}'`
value=`echo $i | awk -F'=' '{print $2}'`
[[ $key == "rnaseq.project.name" ]] && project=$value;
[[ $key == "rnaseq.project.experiment.file" ]] && expfile=$value;
[[ $key == "rnaseq.project.reads.type" ]] && readstype=$value;
[[ $key == "rnaseq.project.protocol.strandspecific" ]] && strandspecific=$value;
[[ $key == "rnaseq.project.proposal.id" ]] && projectId=$value;
[[ $key == "rnaseq.project.platform" ]] && platform=$value;
[[ $key == "rnaseq.project.organism" ]] && organism=$value;
done