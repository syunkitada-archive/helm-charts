%% -*- mode: erlang -*-
%% ----------------------------------------------------------------------------
%% RabbitMQ Sample Configuration File.
%%
%% See http://www.rabbitmq.com/configure.html for details.
%% See https://github.com/rabbitmq/rabbitmq-server/tree/master/docs
%% ----------------------------------------------------------------------------
[
 {rabbit,
  [
   {heartbeat, 60},
   {tcp_listen_options, [{backlog,       32768},
                         {sndbuf,        32768},
                         {recbuf,        32768},
                         {nodelay,       true},
                         {keepalive,     true},
                         {exit_on_close, false}]},
   {vm_memory_high_watermark, 0.4},
   {memory_monitor_interval, 2500},
   {cluster_partition_handling, autoheal},
   {mirroring_sync_batch_size, 4096},
   {cluster_keepalive_interval, 10000},
   {collect_statistics_interval, 50000},
   {hipe_compile, false},
   {mnesia_table_loading_retry_limit, 10},
   {mnesia_table_loading_retry_timeout, 30000},
   {queue_index_embed_msgs_below, 4096}
  ]},
 {rabbitmq_management,
  [
   {rates_mode, none}
  ]}
].
