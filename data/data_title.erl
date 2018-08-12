%%%-------------------------------------------------------------------
%%% @author zhengjia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%% 称号
%%% @end
%%% Created : 05. 五月 2018 11:43
%%%-------------------------------------------------------------------
-module(data_title).
-author("zhengjia").

%% API
-export([title_list/0, title/1]).

title_list() ->
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10].

%%弱鸡
title(0) ->
    0;
%%小区名人
title(1) ->
    50;
%%街道霸主
title(2) ->
    81;
%%片区扛把子
title(3) ->
    121;
%%城市之星
title(4) ->
    181;
%%省级大佬
title(5) ->
    251;
%%民族英雄
title(6) ->
    321;
%%亚洲雄风
title(7) ->
    401;
%%地球卫士
title(8) ->
    501;
%%银河护卫
title(9) ->
    701;
%%宇宙无敌
title(10) ->
    1001.