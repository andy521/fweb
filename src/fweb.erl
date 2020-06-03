-module(fweb).

-export([start/1, add_mapping/1, add_interceptor/1]).

-include("fweb_type.hrl").

start(Port) ->
    EtsOptions = [named_table,
                  public,
                  set,
                  {write_concurrency, true},
                  {read_concurrency, true}],
    ets:new(fweb_cache, EtsOptions ++ [{keypos, #cache.k}]),
    ets:new(fweb_mapping, EtsOptions ++ [{keypos, #handler.mapping}]),
    ets:new(fweb_interceptor, EtsOptions ++ [{keypos, #interceptor.name}]),
    Dispatch = cowboy_router:compile([{'_',
                                       [{'_', fweb_dispatcher, #{}}]}]),
    Started = cowboy:start_clear(fweb_http_listener,
                                 [{port, Port}],
                                 #{env => #{dispatch => Dispatch}}),
    case Started of
        {ok, _} -> ok;
        {error, eaddrinuse} -> error(eaddrinuse);
        {error, Any} -> error(Any)
    end.

add_mapping(Handlers) ->
    lists:foreach(fun (#{name := Handler, mapping := Mapping}) when is_atom(Handler) and is_list(Mapping) ->
                      ets:insert(fweb_mapping, #handler{name = Handler, mapping = Mapping})
                  end, Handlers).

add_interceptor(Interceptors) ->
    lists:foreach(fun (#{name := Name, path := Path}) when is_atom(Name) and is_list(Path) ->
                      ets:insert(fweb_interceptor, #interceptor{name = Name, path = Path})
                  end, Interceptors).
