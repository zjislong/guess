%%%-------------------------------------------------------------------
%%% @author zhengjia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. 四月 2018 11:48
%%%-------------------------------------------------------------------
-author("zhengjia").

%%玩家信息
-record(player,
{
    player_id = 0 :: string()|matchspec_atom(),      %%玩家id
    battle_srv = 0 :: 0|pid()|matchspec_atom(),      %%战斗pid
    name = "" :: string()|matchspec_atom(),  %%昵称
    head = "" :: string()|matchspec_atom(),  %%头像
    gender = "0" :: string()|matchspec_atom(),    %%性别
    city = "" :: string()|matchspec_atom(),      %%市
    province = "" :: string()|matchspec_atom(),  %%省
    country = "" :: string()|matchspec_atom(),   %%国家
    gold = 0 :: non_neg_integer()|matchspec_atom(),           %%金币
    score = 0 :: non_neg_integer()|matchspec_atom(),          %%积分
    title = 0 :: non_neg_integer()|matchspec_atom(),          %%称号
    last_loop_time = 0 :: non_neg_integer()|matchspec_atom(),   %%上一次循环操作时间
    session_key = "" :: string()|matchspec_atom()    %%登录会话的key
}).
