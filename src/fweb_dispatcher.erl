-module(fweb_dispatcher).
-export([init/2]).

init(#{path := Path} = Request, State) ->
    Params = lists:map(fun ({_K, V}) -> V end, cowboy_req:parse_qs(Request)),
    MF = string:tokens(string:sub_string(binary_to_list(Path), 2), "@"),
    case erlang:length(MF) of
        2 ->
            handle_interceptor(Request, MF, Path, Params, State);
       _Not2 ->
            {ok, Request, State}
    end.


handle_interceptor(Request, MF, Path, Params, State) ->
    [Mapping, _] = MF,
    case ets:match_object(fweb_interceptor, {'_', '$1', Mapping}, 1) of
        {[{_, IName, _}], _} ->
            io:format("[LOG Interceptor ====>] Path accept ,apply(~p,~p,~p)~n", [IName, handler, Params]),
            try erlang:apply(IName, handle, Params) of
                accept ->
                  accept(Request, MF, Params, State);
                _Deny ->
                  r(text, 403, Request, State, <<"No permission">>)
            catch W : E  ->
                throw({handle_interceptor, W, E})
            end;
        _ ->
            io:format("[Accept] Path:~p~n", [Path]),
            accept(Request, MF, Params, State)
    end.

accept(Request, MF, Params, State) ->
    case erlang:length(MF) of
        2 ->
            handle_mappping(Request, MF, Params, State);
       _Not2 ->
            {ok, Request, State}
    end.

handle_mappping(#{method := Method, body_length := BodyLength, has_body := Hasbody} = Request, [Mapping, Action], Params, State) ->
    case ets:match_object(fweb_mapping, {'_', '$1', "/" ++ Mapping}, 1) of
         {[{_, HModule, _}], _} when
                                erlang:is_atom(HModule),
                                erlang:is_list(Action) ->
                    Body = case Hasbody of
                            true ->
                                {ok, Data, _} = cowboy_req:read_body(Request, #{length => BodyLength}),
                                Data;
                            _ ->
                                <<>>
                    end,
                    Args = case lists:member(Method, [<<"POST">>, <<"PUT">>]) of
                        true ->
                            [Method, Params, Body];
                        _ ->
                            [Method, Params]
                    end,
                    io:format("[LOG ====>] handle_mappping apply(~p,~p,~p)~n", [HModule, erlang:list_to_atom(Action), Args]),
                    try apply(HModule, erlang:list_to_atom(Action), Args) of
                            {_Type, Return} when is_list(Return);
                                                 is_binary(Return) ->
                                        r(text, 200, Request, State, Return);
                                                              _Not ->
                                        throw({handle_mappping, "Action return value must be list or binary!"})
                    catch W : E ->
                        case E of
                            undef ->
                                throw({handle_mappping, W, E, "Action undefined"});
                            _ ->
                                throw({handle_mappping, W, E})
                        end
                    end;
        _OtherRow ->
            r(text ,404, Request, State, <<"Resource not found.">>)
     end.


%%
%% 问题：返回值 可能是rest，或者HTML，或者 文件
%% 目前仅支持rest，HTML在考虑要不要支持 
%% 文件准备单独做一个
%%
r(Type, Code ,Request, State, Info) when is_binary(Info) ; is_list(Info)->
    HttpHeader = case Type of
        rest ->
            #{<<"content-type">> => <<"text/plain">>};
        _ ->
            #{<<"content-type">> => <<"text/plain">>}
    end,
    Response = cowboy_req:reply(Code, HttpHeader, Info, Request),
    {ok, Response, State}.


