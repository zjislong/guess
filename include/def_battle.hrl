%%%-------------------------------------------------------------------
%%% @author zhengjia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 五月 2018 11:29
%%%-------------------------------------------------------------------
-author("zhengjia").

-define(BATTLE_DESK, battle_desk). %%牌桌
-define(BATTLE_PLAYER(ID), {battle_player, ID}). %%战斗玩家
-define(BATTLE_MATCH_LIST, battle_match_list). %%匹配队列
-define(BATTLE_MATCH_LIST(Key), {battle_match_list, Key}). %%匹配队列
-define(BATTLE_MATCH_PLAYER(ID), {battle_match_player, ID}). %%匹配key

%%战斗玩家结构
-record(battle_player, {
    id = 0 :: string()|matchspec_atom(),    %%玩家ID
    pos = 1 :: non_neg_integer()|matchspec_atom(), %%位置
    score = 0 :: non_neg_integer()|matchspec_atom(), %%积分
    mvp = 0 :: non_neg_integer()|matchspec_atom(), %%mvp
    higher = 0 :: non_neg_integer()|matchspec_atom() %%higher
}).

%%牌桌
-record(battle_card, {
    pos = 1 :: non_neg_integer()|matchspec_atom(), %%位置
    cardID = 0 :: non_neg_integer()|matchspec_atom(), %%卡牌ID
    id = "" :: string()|matchspec_atom(),    %%玩家ID
    vote = [] :: [string()]|matchspec_atom()    %%投票
}).

%%对战信息
-record(battle_srv, {
    id = 0 :: string()|matchspec_atom(),            %%玩家1
    pid = 0 :: 0|pid()|matchspec_atom()                      %%战斗pid
}).
