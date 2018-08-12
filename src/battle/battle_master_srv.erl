%%%-------------------------------------------------------------------
%%% @author zhengjia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. 五月 2018 04:56
%%%-------------------------------------------------------------------
-module(battle_master_srv).
-author("zhengjia").
-include("type.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("def_player.hrl").
-include("def_battle.hrl").
-include("proto.hrl").
-include("def_rank.hrl").
-include("def_ets.hrl").
-include("option.hrl").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {
    status = 0 :: 0|1|2, %%阶段0匹配阶段1等待结算阶段2结算阶段
    time = 0 :: non_neg_integer() %%阶段结束时间
}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
    {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
    {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term()} | ignore).
init([]) ->
    process_flag(trap_exit, true),
    global:register_name(?SERVER, self()),
    erlang:send_after(1000, self(), loop),
    case public_data:get(battle_manager, {0, status_time(0)}) of
        {Status, Time} ->
            {ok, #state{status = Status, time = Time}};
        _ ->
            {ok, #state{status = 0, time = status_time(0)}}
    end.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
    {reply, Reply :: term(), NewState :: #state{}} |
    {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_cast(Req, State) ->
    try
        do_handle_cast(Req, State)
    catch
        C:R:Stacktrace ->
          lager:info("battle_master_srv handle_cast:~p fail:{~p,~p,~p}", [Req,C,R,Stacktrace]),
          {noreply, State}
    end.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_info(Info, State) ->
    try
        do_handle_info(Info, State)
    catch
        C:R:Stacktrace ->
          lager:info("battle_master_srv handle_info:~p fail:{~p,~p,~p}", [Info,C,R,Stacktrace]),
          {noreply, State}
    end.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, State) ->
    public_data:put(battle_manager, {State#state.status, State#state.time}),
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
    {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
%%进入匹配队列
do_handle_cast({join_match, ID, Key}, State) ->
    join_match(ID, Key),
    {noreply, State};
%%离开匹配队列
do_handle_cast({cancel_match, ID}, State) ->
    cancel_match(ID),
    {noreply, State};
%%发送对人模式信息
do_handle_cast({send_battle_info, _PlayerID}, State) ->
    {noreply, State};
do_handle_cast(_Request, State) ->
    {noreply, State}.

%%匹配操作
do_handle_info(loop, State) ->
    erlang:send_after(1000, self(), loop),
    Now = misc:unixtime(),
    case State#state.time > Now of
        true ->
            case State#state.status of
                0 ->
                    match(Now);
                _ ->
                    skip
            end,
            {noreply, State};
        false ->
            Status = status_change(State#state.status),
            State1 = State#state{status = Status, time = status_time(Status)},
            {noreply, State1}
    end;
do_handle_info(_Info, State) ->
    {noreply, State}.

%%阶段切换
status_change(0) ->
    1;
status_change(1) ->
    reward(),
    2;
status_change(2) ->
    gen_server:call(rank_manager_srv, {apply, rank_lib,reset,["pvp"]}),
    0.

%%加入匹配
join_match(ID, Key) ->
    {OldKey, _} = dictionary:key_get(?BATTLE_MATCH_PLAYER(ID), {Key, 0}),
    cancel_match(ID, OldKey),
    dictionary:key_put([?BATTLE_MATCH_LIST, ?BATTLE_MATCH_LIST(Key), ?BATTLE_MATCH_PLAYER(ID)], {Key, misc:unixtime()}).

%%退出匹配
cancel_match(ID) ->
    {OldKey, _} = dictionary:key_get(?BATTLE_MATCH_PLAYER(ID), {1, 0}),
    cancel_match(ID, OldKey).

cancel_match(ID, Key) ->
    dictionary:key_delete(?BATTLE_MATCH_LIST(Key), ?BATTLE_MATCH_PLAYER(ID)).

%%匹配
match(Now) ->
    KeyList = dictionary:key_get(?BATTLE_MATCH_LIST, sets),
    match(Now, lists:keysort(2, sets:to_list(KeyList))).

match(_, []) ->
    ok;
match(Now, [?BATTLE_MATCH_LIST(Key) | Keys]) ->
    IDList = dictionary:key_get(?BATTLE_MATCH_LIST(Key), sets),
    case sets:size(IDList) of
        0 ->
            match(Now, Keys);
        _ ->
            PlayerCount = data_battle:player_count(Key),
            sets:fold(fun(E, Acc) ->
                           case length(Acc) == PlayerCount - 1 of
                               true ->
                                   IDList1 = [E|Acc],
                                   [dictionary:key_delete(?BATTLE_MATCH_LIST(Key), ID)||ID <- IDList],
                                   battle_lib:start_battle_srv(IDList1),
                                   [];
                               false ->
                                   [E | Acc]
                           end
                        end, [], IDList),
            match(Now, Keys)
    end.

%%阶段结束时间
status_time(Status) ->
    {Week, WeekNum1, Time} = data_battle:status(Status),
    Date = date(),
    WeekNum2 = calendar:day_of_the_week(Date),
    misc:datetime_to_seconds({Date, Time}) + (WeekNum1 - WeekNum2) * 86400 + Week * 7 * 86400.

%%赛季结算
reward() ->
    case ets:lookup(?ETS_RANK_SRV, "pvp") of
        [#rank_srv{key_ets_name = KeyEtsName}] ->
            Ms = ets:fun2ms(fun(#rank{key = Key, value = Value}) -> {Key, Value} end),
            RankInfo = ets:select(KeyEtsName, Ms),
            reward(RankInfo);
        _ ->
            skip
    end,
    ok.

reward([]) ->
    ok;
reward([{ID, Star} | RankInfo]) ->
    {StarLv, _} = battle_lib:star(Star),
    Reward = data_battle:reward(StarLv),
    reward_lib:reward(ID, Reward, ?OPTION_BATTLE_STAR_REWARD, Star),
    reward(RankInfo).
