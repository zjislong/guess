%%%-------------------------------------------------------------------
%%% @author zhengjia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 五月 2018 10:36
%%%-------------------------------------------------------------------
-module(battle_lib).
-author("zhengjia").
-include("type.hrl").
-include("def_battle.hrl").
-include("proto.hrl").
-include("def_player.hrl").
-include("def_ets.hrl").

%% API
-export([get_battle_player/1,
    set_battle_player/1,
    new_battle_id/0,
    battle_start/2,
    start_battle_srv/1,
    start_battle_srv_callback/1]).

%%获取战斗玩家
-spec get_battle_player(ID :: string()) -> #battle_player{}.
get_battle_player(ID) ->
    case get(?BATTLE_PLAYER(ID)) of
        #battle_player{} = Player ->
            Player;
        _ ->
            #battle_player{
                id = ID,
                hp = data_battle:init_hp()
            }
    end.

%%更新战斗玩家
-spec set_battle_player(Player :: #battle_player{}) -> #battle_player{}|undefined.
set_battle_player(Player) ->
    put(?BATTLE_PLAYER(Player#battle_player.id), Player).

%%生成battle_id
-spec new_battle_id() -> non_neg_integer().
new_battle_id() ->
    public_data:add(battle_id).

%%战斗开始
-spec battle_start(ID1::string(), ID2::string()) -> ok|error.
battle_start(ID1, [$a,$i|_]=ID2) ->
    #player{star = Star2, name = Name2, head = Head2, gender = Gender2} = player_lib:get_player(ID2),
    send_msg_to_client(ID1, [#s_battle_start{target_id = ID2,
     hp = data_battle:init_hp(),
      target_star = Star2,
      target_name = Name2,
      target_head = Head2,
      target_gender = Gender2}]);
battle_start(ID1, ID2) ->
    #player{star = Star1, name = Name1, head = Head1, gender = Gender1} = player_lib:get_player(ID1),
    #player{star = Star2, name = Name2, head = Head2, gender = Gender2} = player_lib:get_player(ID2),
    send_msg_to_client(ID1, [#s_battle_start{target_id = ID2,
     hp = data_battle:init_hp(),
      target_star = Star2,
      target_name = Name2,
      target_head = Head2,
      target_gender = Gender2}]),
    send_msg_to_client(ID2, [#s_battle_start{target_id = ID1,
     hp = data_battle:init_hp(),
      target_star = Star1,
      target_name = Name1,
      target_head = Head1,
      target_gender = Gender1}]).

send_msg_to_client([$a,$i|_], _)->
    ok;
send_msg_to_client(ID, Msgs)->
    player_lib:send_msg_to_client(ID, Msgs).

%%在第一个玩家所在节点的battle_sup下启动battle_srv
-spec start_battle_srv(Args :: [string(),...]) -> no_return().
start_battle_srv([ID|_]=Args) ->
    global:send({player, ID}, {apply, ?MODULE, start_battle_srv_callback, [Args]}).

-spec start_battle_srv_callback(Args :: [string(),...]) -> ok.
start_battle_srv_callback(Args) ->
    supervisor:start_child(battle_sup, Args),
    ok.