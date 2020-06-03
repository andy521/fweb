%%%-------------------------------------------------------------------
%%% @author wangwenhai
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. 8月 2020 11:01 下午
%%%-------------------------------------------------------------------
-module(test_interceptor_deny).
-author("wangwenhai").

%% API
-export([handle/1]).
handle(Params) ->
  io:format("[DENY] Params is:~p~n", [Params]),
  deny.