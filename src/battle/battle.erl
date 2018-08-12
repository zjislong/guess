%%%-------------------------------------------------------------------
%%% @author zhengjia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 五月 2018 10:27
%%%-------------------------------------------------------------------
-module(battle).
-author("zhengjia").
-include("type.hrl").
-include("def_ets.hrl").
-include("def_player.hrl").
-include("def_battle.hrl").
-include("proto.hrl").

%% API
-export([c_pick_card/2,
    c_speak_card/2,
    c_follow_card/2,
    c_vote_card/2]).

c_pick_card(#c_pick_card{}, PlayerID) ->
    {ok, []}.
c_speak_card(#c_speak_card{}, PlayerID) ->
    {ok, []}.
c_follow_card(#c_follow_card{}, PlayerID) ->
    {ok, []}.
c_vote_card(#c_vote_card{}, PlayerID) ->
    {ok, []}.