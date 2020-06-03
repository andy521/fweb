%%%-------------------------------------------------------------------
%%% @author wangwenhai
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. 8月 2020 10:57 下午
%%%-------------------------------------------------------------------
-module(test_handler).
-author("wangwenhai").
%% API
-compile(export_all).

post(<<"POST">>, Params, Body) ->
  io:format("Args:~p  Body:~p~n", [Params, Body]),
  {text ,"OK"}.

get(<<"GET">>, Params) ->
  io:format("Params:~p~n", [Params]),
  {text ,"OK"}.

put(<<"PUT">>, Params)  ->
  io:format("Params:~p~n", [Params]),
  {text ,"OK"}.