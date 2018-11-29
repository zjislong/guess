-module(user_default).

-include("type.hrl").
-include("def_active.hrl").
-include("def_battle.hrl").
-include("def_ets.hrl").
-include("def_player.hrl").
-include("def_rank.hrl").
-include("def_room.hrl").
-include("proto.hrl").
-include_lib("stdlib/include/ms_transform.hrl").

-export([ob/0,
         p/1,
         p/2,
         d/1,
         d/2,
         kill/1,
         u8/1,
         q/0,
         beam2erl/1,
         gm_time/6,
         l/1,
         lm/0]).

ob() ->
    observer:start().

p(A) when is_atom(A) ->
    whereis(A);
p(A) when is_list(A) ->
    list_to_pid(A);
p(A) when is_pid(A) ->
    A.

p(A, Flag) ->
    element(2, process_info(p(A), Flag)).

%% 查看一个进程的进程字典
d(Name) ->
    p(Name, dictionary).

d(Name, Key) ->
    Dicts = p(Name, dictionary),
    case lists:keyfind(Key, 1, Dicts) of
        {_, _} = Dict -> Dict;
        _ -> undefined
    end.

%% 杀死一个进程
kill(Process) ->
    exit(p(Process), kill).

%%erlang中文字符串格式化输出
u8(String) when is_list(String) ->
    try list_to_binary(String) of
        Bin ->
            u8(Bin)
    catch
        _:_:_->
            io:format("~ts~n", [String])
    end;
u8(Bin) when is_binary(Bin) ->
    io:format("~ts~n", [Bin]).

q() ->
    io:format("can not stop sever~n").

beam2erl(File) ->
    case beam_lib:chunks(File, [abstract_code]) of
        {ok, {Module, [{_, {_, Source}}]}} ->
            {ok, IO} = file:open(atom_to_list(Module) ++ ".erl", [write]),
            io:format(IO, "~s~n", [erl_prettypr:format(erl_syntax:form_list(Source))]),
            file:close(IO);
        _ ->
            error
    end.

gm_time(Y, M, D, H, Mu, S) ->
    Now = erlang:system_time(second),
    GMTime = misc:datetime_to_seconds({{Y, M, D}, {H, Mu, S}}),
    Diff = GMTime - Now,
    public_data:put(gm_time, Diff).

l(Module) ->
    rpc:multicall(c, l, [Module]).

lm() ->
    rpc:multicall(c, lm, []).

