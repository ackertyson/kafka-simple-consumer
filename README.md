# kafka-simple-consumer

Simple wrapper for `node-rdkafka` KafkaConsumer class

## Installation

`npm i --save kafka-simple-consumer`

The `node-rdkafka` compile requires that `libsasl2` libraries be installed on
your system.

## Build

`gulp clean && gulp build`

## Basic usage

```
Consumer = require 'kafka-simple-consumer'
mongo = require './mongo'

consumer = new Consumer {
  brokers: 'kafka:9092'
  group: 'mongo-consumer'
  topic: 'Vehicle'
}

mongo.connect (err, db) ->
  throw err if err?

  Vehicle = db.collection 'vehicle'

  consumer.subscribe (msg, raw) -> # read data from stream
    Vehicle.findOneAndUpdate({ make: msg.make }, { $push: { models: msg }}, { upsert: true }).then ->
      consumer.commitMessage raw
    .catch (err) ->
      console.log err if err?
```
