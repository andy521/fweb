%%%-------------------------------------------------------------------
%%% @author wangwenhai
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. 8月 2020 10:58 下午
%%%-------------------------------------------------------------------
-module(test_interceptor_accept).
-author("wangwenhai").

%% API
-export([handle/1]).
handle(Params) ->
  io:format("[ACCEPT] Params is:~p~n", [Params]),
  accept.
