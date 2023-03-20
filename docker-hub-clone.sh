#!/bin/bash -x

src_repo="<source_repository_name>"
dst_repo="<destination_repository_name>""
images=(
    image1
    image2
    ...
)

function get_tags() {
    wget -q https://registry.hub.docker.com/v2/repositories/$src_repo/$i/tags?page=$page -O $tmp_response_file
    tags=( $(jq -r '.results[].name' < $tmp_response_file ) )
    next="$(jq -r '.next' < $tmp_response_file )"
}

function process_tags() {
    for t in ${tags[@]}; do
        src_tag="$src_repo/$i:$t"
        dst_tag="$dst_repo/$i:$t"
        echo cloning "$src_tag" to "$dst_tag"
        docker pull "$src_tag"
        docker tag "$src_tag" "$dst_tag"
        docker push "$dst_tag"
    done
}

tmp_response_file=/tmp/hub.json

for i in ${images[@]}; do
    echo tags for $src_repo/$i
    page=0
    next=""
    while
        page=$(( $page + 1 ))
        get_tags
        process_tags
        [[ "$next" != "null" ]]
    do true; done
    docker image prune --all --force
done

