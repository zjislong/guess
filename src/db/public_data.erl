%%% @author ZhengJia <zj952067409@163.com>
%%% @copyright 2018 ZhengJia
%%% @doc gen_server callback module implementation:
%%%
%%% @end
-module(public_data).
-author('ZhengJia <zj952067409@163.com>').

-export([add/1, get/2, put/2]).

%%====================================================================
%% API functions
%%====================================================================
get(Key, Default) ->
    RedisKey = key(Key),
    case redis:get(RedisKey) of
        {ok, Value} ->
            misc:bitstring_to_term(Value, Default);
        _ ->
            case db:query("select `Value` from GPublicData where `Key` = ?", [Key]) of
                [[Value]] ->
                    redis:set(RedisKey, Value),
                    misc:bitstring_to_term(Value, Default);
                _ ->
                    Default
            end
    end.

put(Key, Value) ->
    RedisKey = key(Key),
    db:query("replace into GPublicData values (?, ?)", [Key, misc:term_to_bitstring(Value)]),
    redis:set(RedisKey, misc:term_to_bitstring(Value)).

add(Key) ->
    RedisKey = key(Key),
    get(Key, 0),
    case redis:incr(RedisKey) of
        {ok, Value} ->
            db:query("replace into GPublicData values (?, ?)", [Key, Value]),
            misc:bitstring_to_term(Value, 1);
        _ ->
            db:query("replace into GPublicData values (?, ?)", [Key, <<"1">>]),
            1
    end.
%%====================================================================
%% Internal functions
%%====================================================================
key(Key) ->
    "data_" ++ Key.
