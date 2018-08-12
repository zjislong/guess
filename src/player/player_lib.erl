%%%-------------------------------------------------------------------
%%% @author zhengjia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 四月 2018 09:52
%%%-------------------------------------------------------------------
-module(player_lib).
-author("zhengjia").
-include("type.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("def_player.hrl").
-include("def_ets.hrl").
-include("proto.hrl").

%% API
-export([get_all_players/0,
    get_player/1,
    put_player/1,
    update_player/2,
    del_player/1,
    save_player/1,
    s_player_info/1,
    update_title/2,
    send_msg_to_client/2,
    loop/2]).

-spec get_all_players() -> [{PlayerID :: string(), Player :: #player{}}].
get_all_players() ->
    {ok, Players} = lbm_kv:match_key(player, '_'),
    Players.

-spec get_player(PlayerID :: string()) -> #player{}.
get_player(PlayerID) ->
    case lbm_kv:get(player, PlayerID) of
        {ok, [{_, Player}]} ->
            Player;
        _ ->
            load_player(PlayerID)
    end.

-spec put_player(Player :: #player{}) -> term().
put_player(Player) ->
    lbm_kv:put(player, Player#player.player_id, Player).

-type update_fun() :: fun((term(), {value, term()} | undefined) ->
                                 {value, term()} | term()).
-spec update_player(PlayerID :: string(), Fun :: update_fun()) -> #player{}.
update_player(PlayerID, Fun) ->
    {ok, {_, [{_, Player}]}} = lbm_kv:update(player, PlayerID, Fun),
    Player.

-spec del_player(PlayerID :: string()) -> term().
del_player(PlayerID) ->
    lbm_kv:del(player, PlayerID).

%%加载玩家信息
-spec load_player(PlayerID :: string()) -> #player{}.
load_player(PlayerID) ->
    Player = case db:query("select * from GPlayer where PlayerID = ?", [PlayerID]) of
                 [[_,
                    Title,
                    Name,
                    Head,
                    Gender,
                    City,
                    Province,
                    Country,
                    Gold,
                    Score,
                    Title,
                    LoopTime]] ->
                     #player{player_id = PlayerID,
                         name = misc:bitstring_to_term(Name, ""),
                         head = misc:bitstring_to_term(Head, ""),
                         gender = misc:bitstring_to_term(Gender, ""),
                         city = misc:bitstring_to_term(City, ""),
                         province = misc:bitstring_to_term(Province, ""),
                         country = misc:bitstring_to_term(Country, ""),
                         gold = Gold,
                         score = Score,
                         title = Title,
                         last_loop_time = LoopTime};
                 _ ->
                     #player{player_id = PlayerID}
             end,
    Player.

-spec save_player(Player :: #player{}) -> term().
save_player(Player) ->
    #player{
        player_id = PlayerID,
        name = Name,
        head = Head,
        gender = Gender,
        city = City,
        province = Province,
        country = Country,
        gold = Gold,
        score = Score,
        title = Title,
        last_loop_time = LoopTime} = Player,
    db:query("replace into GPlayer values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        [PlayerID,
            Title,
            misc:term_to_bitstring(Name),
            misc:term_to_bitstring(Head),
            misc:term_to_bitstring(Gender),
            misc:term_to_bitstring(City),
            misc:term_to_bitstring(Province),
            misc:term_to_bitstring(Country),
            Gold,
            Score,
            Title,
            LoopTime]).

%%玩家信息s_player_info
-spec s_player_info(Player :: #player{}) -> #s_player_info{}.
s_player_info(Player) ->
    Msg = #s_player_info{
        gold = Player#player.gold,
        score = Player#player.score},
    Msg.

%%更新称号
-spec update_title(Player :: #player{}, Score :: non_neg_integer()) -> #player{}.
update_title(Player, Score) ->
    Title = score2title(Score),
    Player#player{title = max(Title, Player#player.title)}.

score2title(Score) ->
    TitleList = data_title:title_list(),
    score2title1(Score, TitleList, 0).

score2title1(_, [], Title) ->
    Title;
score2title1(Score, [Title | R], CurTitle) ->
    case data_title:title(Title) =< Score of
        true ->
            score2title1(Score, R, Title);
        false ->
            CurTitle
    end.

%%发送协议数据
-spec send_msg_to_client(PlayerID::string(), Msgs::[term()])->ok|error.
send_msg_to_client(PlayerID, Msgs) ->
    case global:whereis_name({player, PlayerID}) of
	    Pid when is_pid(Pid) ->
	        Pid ! {msg, Msgs},
            ok;
	    undefined ->
            error
    end.

%%循环
loop(PlayerID, LoopTime) ->
    battle_lib:recover_fight_count(PlayerID, LoopTime).