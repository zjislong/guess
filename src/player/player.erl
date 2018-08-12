%%%-------------------------------------------------------------------
%%% @author zhengjia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. 五月 2018 01:07
%%%-------------------------------------------------------------------
-module(player).
-author("zhengjia").
-include("type.hrl").
-include("proto.hrl").
-include("def_player.hrl").
-include("option.hrl").

%% API
-export([c_player_info/2,
    c_start_match/2,
    c_cancel_match/2]).

c_player_info(#c_player_info{}, PlayerID) ->
    Player = player_lib:get_player(PlayerID),
    Msg = player_lib:s_player_info(Player),
    {ok, [Msg]}.

c_start_match(#c_start_match{type = Type}, PlayerID) ->
    gen_server:cast({global, battle_master_srv}, {join_match, PlayerID, Type}),
    {ok, []}.

c_cancel_match(_, PlayerID) ->
    gen_server:cast({global, battle_master_srv}, {cancel_match, PlayerID}),
    {ok, []}.
