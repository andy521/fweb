%%%-------------------------------------------------------------------
%%% @author wangwenhai
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. 8月 2020 11:07 下午
%%%-------------------------------------------------------------------
-module(start).
-author("wangwenhai").

%% API
-export([start/0]).
start()->
  fweb:start(8080),
  fweb:add_interceptor([#{name => test_interceptor_accept, path => "/index"}]),
  fweb:add_mapping([#{name => test_handler, mapping => "/index"}]).

