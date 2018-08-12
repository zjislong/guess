%%%-------------------------------------------------------------------
%%% @author zhengjia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 五月 2018 10:37
%%%-------------------------------------------------------------------
-module(battle_srv).
-author("zhengjia").
-include("type.hrl").
-include("def_battle.hrl").
-include("def_ets.hrl").
-include("def_player.hrl").
-behaviour(gen_server).

%% API
-export([start_link/1]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {
    battle_id = 0 :: non_neg_integer(),
    id_list = [] :: [string()],
    status = 0 :: non_neg_integer()
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
-spec(start_link(IDList :: [string()]) ->
    {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link(IDList) ->
    gen_server:start_link(?MODULE, [IDList], []).

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
init(IDList) ->
    process_flag(trap_exit, true),
    lager:info("player ~p start battle~n", [IDList]),
    BattleID = battle_lib:new_battle_id(),
    Pid = self(),
    erlang:send(Pid, battle_start),
    UpdateFun = fun(_, {value, Player}) -> {value, Player#player{battle_srv = Pid}} end,
    [begin 
        battle_lib:set_battle_player(battle_lib:get_battle_player(ID)),
        player_lib:update_player(ID, UpdateFun)
    end||ID<-IDList],
    {ok, #state{battle_id = BattleID, id_list = IDList}}.

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
          lager:info("battle_srv handle_cast:~p fail:{~p,~p,~p}", [Req,C,R,Stacktrace]),
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
%%状态 1讲述阶段 2混淆阶段 3答题阶段 4积分阶段
handle_info({battle_status, 1}, State) ->
    {noreply, State};
handle_info({battle_status, 2}, State) ->
    {noreply, State};
handle_info({battle_status, 3}, State) ->
    {noreply, State};
handle_info({battle_status, 4}, State) ->
    {noreply, State};
handle_info(Info, State) ->
    lager:info("~p recv unknown info ~p~n", [?MODULE, Info]),
    {noreply, State}.

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
    UpdateFun = fun(_, {value, Player}) -> {value, Player#player{battle_srv = 0}} end,
    [player_lib:update_player(ID, UpdateFun)||ID<-State#state.id_list],
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
%%讲述人盖牌
do_handle_cast({pick_card, ID, CardID}, State) ->
    battle_lib:pick_card(ID, CardID),
    {noreply, State};
%%讲述人讲述
do_handle_cast({speak_card, ID, Descript}, State) ->
    battle_lib:speak_card(ID, Descript),
    {noreply, State};
%%听众跟牌
do_handle_cast({follow_card, ID, CardID}, State) ->
    battle_lib:follow_card(ID, CardID),
    {noreply, State};
%%听众投票
do_handle_cast({vote_card, ID, CardID}, State) ->
    battle_lib:vote_card(ID, CardID),
    {noreply, State};
do_handle_cast(_Request, State) ->
    {noreply, State}.