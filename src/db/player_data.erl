%%% @author ZhengJia <zj952067409@163.com>
%%% @copyright 2018 ZhengJia
%%% @doc gen_server callback module implementation:
%%%
%%% @end
-module(player_data).
-author('ZhengJia <zj952067409@163.com>').

-export([add/2, get/3, put/3]).

%%====================================================================
%% API functions
%%====================================================================
get(PlayerID, Key, Default) ->
    RedisKey = key(PlayerID, Key),
    case redis:get(RedisKey) of
        {ok, Value} ->
            misc:bitstring_to_term(Value, Default);
        _ ->
            case db:query("select `Value` from GPlayerData where `PlayerID` = ? and `Key` = ?", [PlayerID, Key]) of
                [[Value]] ->
                    redis:set(RedisKey, Value),
                    misc:bitstring_to_term(Value, Default);
                _ ->
                    Default
            end
    end.

put(PlayerID, Key, Value) ->
    RedisKey = key(PlayerID, Key),
    db:query("replace into GPlayerData values (?, ?, ?)", [PlayerID, Key, misc:term_to_bitstring(Value)]),
    redis:set(RedisKey, misc:term_to_bitstring(Value)),
    redis:expire(RedisKey, 7200).

add(PlayerID, Key) ->
    RedisKey = key(PlayerID, Key),
    get(PlayerID, Key, 0),
    case redis:incr(RedisKey) of
        {ok, Value} ->
            db:query("replace into GPlayerData values (?, ?, ?)", [PlayerID, Key, Value]),
            misc:bitstring_to_term(Value, 1);
        _ ->
            db:query("replace into GPlayerData values (?, ?, ?)", [PlayerID, Key, <<"1">>]),
            1
    end.
%%====================================================================
%% Internal functions
%%====================================================================
key(PlayerID, Key) ->
    "data_" ++ Key ++ PlayerID.
