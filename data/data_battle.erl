%%%-------------------------------------------------------------------
%%% @author zhengjia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 五月 2018 11:39
%%%-------------------------------------------------------------------
-module(data_battle).
-author("zhengjia").

%% API
-export([player_count/1]).

%%对局人数
player_count(1) -> 4;
player_count(2) -> 6;
player_count(3) -> 8;
player_count(4) -> 12.
