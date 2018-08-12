%%%-------------------------------------------------------------------
%%% @author zhengjia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. 四月 2018 11:18
%%%-------------------------------------------------------------------
-module(login).
-author("zhengjia").
-include("type.hrl").
-include("proto.hrl").
-include("def_player.hrl").

%% API
-export([c_login/2,
    c_heart/2]).

c_login(Clogin, _) ->
    Player = player_lib:get_player(Clogin#c_login.player_id),
    Msg1 = #s_login{player_id = Clogin#c_login.player_id},
    Msg2 = player_lib:s_player_info(Player),
    Player1 = Player#player{
        name = Clogin#c_login.name,
        head = Clogin#c_login.head,
        gender = Clogin#c_login.gender,
        city = Clogin#c_login.city,
        province = Clogin#c_login.province,
        country = Clogin#c_login.country},
    {ok, [Msg1, Msg2], Player1}.

c_heart(_, _) ->
    {ok, [#s_heart{}]}.
