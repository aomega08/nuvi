# NUVI INTERVIEW CODE PROJECT

This repository contains the code for the NUVI interview project.

## How it works

My first attempt was to download the whole HTTP directory in one shot, unzipping all the files,
and adding them to Redis. However:

* The zip files in the directory where changing in front of my eyes. New files were added and others where removed.
* The directory contains in average ~800 files with each file being ~10mb.
* The download speed of the file is quite limited (wget reports ~170KB/s, even though I'm on a 100mbps line)

So downloading the whole dataset would have required ~13 hours, being stale right after the download.

Instead, I'm now downloading and processing each file one after another:

* Download the zip file (unless it was downloaded earlier - having a cache helps on low speed connections)
* Extract the XMLs to a tmp directory
* Add the XMLs to Redis
* Delete the XMLs tmp directory

### Idempotency

The task requires the code to be idempotent - parsing the same zip twice should not add the same XML files to the Redis list, generating duplications.

Checking whether an element is in a list is an O(n) operation on Redis.

This is instead achieved by using a support SET to keep the hashes of the XML files. Adding an item to a Redis SET or checking an item presence is O(1).

So we try to add the hash to the set using SADD. If the command returns 1, the hash was not in the set and we add the XML contents to the NEWS_XML list using RPUSH. Otherwise we just skip to the next item.

## The Task

This URL (http://bitly.com/nuvi-plz) is an http folder containing a list of zip files. Each zip file contains a bunch of xml files. Each xml file contains 1 news report.

Your application needs to download all of the zip files, extract out the xml files, and publish the content of each xml file to a Redis list called “NEWS_XML”.

Make the application idempotent. We want to be able to run it multiple times but not get duplicate data in the redis list.
