#!/bin/bash
lastid=""

function geturls()
{
urls=( $(echo ${json} | jq -r ".items[].images.standard_resolution.url, .items[].videos.standard_resolution.url" ) )
}

function getjson()
{
json=$(wget --quiet -O - "http://instagram.com/${1}/media?max_id=${2}")
}

function downloadmedia()
{
for url in "${urls[@]}"
do
    if [[ "${url}" != "null" ]]
    then
        echo ${user}  ${url}
        wget --quiet -c ${url} &
    fi
done
}

function downloadall()
{
getjson ${1} ${lastid}
geturls
downloadmedia
ifmore=$(echo ${json} | jq -r ".more_available")
if [[ -f debug ]]; then echo  "${ifmore}"; fi
if [[ -f skip ]]; then ifmore="false"; fi
if [[ "${ifmore}" == "true" ]]
then
    lastid=$(echo ${json} | jq -r ".items[19].id" | sed -e 's/\"//g')
    if [[ -f debug ]]; then echo "${lastid}"; fi
    if [[ "${lastid}" != "null" ]]
    then
        downloadall ${1}
    fi
fi
}

while read user
do
    lastid=""
    if [[ -d "${user}" ]]
    then
       echo "${user} exists, crawling."
    else
       mkdir "${user}"
    fi
    if cd "${user}"
    then
        downloadall ${user}
        cd ..
    else
        echo "Could not enter directory"
    fi
done < users.txt
