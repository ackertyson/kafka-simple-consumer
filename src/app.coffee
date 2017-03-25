Kafka = require 'node-rdkafka'

class SimpleConsumer
  constructor: ({ @autoCommit, @batch, @batchSize, @batchWait, @brokers, @group, @topic }) ->
    throw new Error("Must provide BROKERS list") unless @brokers?
    throw new Error("Must provide GROUP name") unless @group?
    throw new Error("Must provide TOPIC name") unless @topic?
    @batch = false unless @batch is true # send msgs in batches or as they arrive?
    @batchSize ?= 5 # how many msgs constitute a batch?
    @batchWait ?= 1000 # how many milliseconds to wait between batches?
    options =
      'metadata.broker.list': @brokers,
      'group.id': @group,
      'socket.keepalive.enable': true,
      'enable.auto.commit': @autoCommit or false
    @consumer = new Kafka.KafkaConsumer options
    @consumer.on 'error', (err) ->
      throw err if err?

  commitMessage: (msg, callback) =>
    cb = callback or ->
    @consumer.commitMessage msg, cb

  subscribe: (callback) =>
    unless @batch # return individual messages
      @consumer.on 'data', (data) ->
        msg = JSON.parse data.value.toString 'utf8'
        msg.key = data.key
        callback msg, data # send back parsed object AND raw message (latter useful for manual commits)

    @consumer.on 'ready', =>
      console.log "Consumer #{@group} running..."
      @consumer.subscribe [@topic]
      setInterval =>
        @consumer.consume @batchSize, (err, messages) =>
          throw err if err?
          if @batch and messages.length > 0 # return batched array of messages
            parsed = []
            for msg in messages
              obj = JSON.parse msg.value.toString 'utf8'
              obj.key = msg.key
              parsed.push obj
            callback parsed, messages # send back parsed object AND raw msgs (latter useful for manual commits)
      , @batchWait

    @consumer.connect (err, metadata) ->
      throw err if err?


module.exports = SimpleConsumer
