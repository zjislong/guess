#!/bin/bash
#control script
pwd=`pwd`
cd `dirname $0`
nodename=`escript bin/node_name`
pa='-pa ebin deps/ebin'
config='-config config/app.config'
cookie='-setcookie guess'
option='+P 100000 +K true -noinput'
rand=`openssl rand -hex 10`
case $1 in
    make)
        erl -noshell -pa deps/ebin tools/mmake/ebin -eval "mmake:all(8),erlang:halt(0)."
        ;;
    start)
        nohup erl -s server start -name ${nodename} ${pa} ${config} ${cookie} ${option} >start.log 2>&1 &
        ;;
    stop)
        erl -name stop_${rand}@127.0.0.1 -noshell -hidden ${cookie} -eval "rpc:call('${nodename}', server, stop, [], 5000),erlang:halt(0)."
        ;;
    debug)
        erl -name debug_${rand}@127.0.0.1 -hidden ${cookie} -remsh ${nodename}
        ;;
    node_list)
        erl -name node_list_${rand}@127.0.0.1 -noshell -hidden ${cookie} -eval "Nodes = rpc:call('${nodename}', erlang, nodes, [], 5000),io:format(\"~p~n\", [Nodes]),erlang:halt(0)."
        ;;
    debug_node)
        erl -name debug_node_${rand}@127.0.0.1 -hidden ${cookie} -remsh $2
        ;;
    patch)
        erl -noshell -pa deps/ebin tools/mmake/ebin -eval "mmake:all(8),erlang:halt(0)."
        tar cvf guess_server.tar bin deps/ebin ebin priv ctl
        ;;
    lm)
        erl -name stop@127.0.0.1 -noshell -hidden %cookie% -eval "{[ReloadMod], _} = rpc:call('%nodename%', user_default, lm, [], 5000),io:format(\"Reload:~p\", [ReloadMod]),erlang:halt(0)."
        ;;
    *)
        echo make: compile all code
	echo start: start server
	echo stop: stop server
        echo debug: remsh server
        echo node_list: list all nodes
        echo debug_node: remsh optional server
	echo patch: create ptach tar file
	echo lm: reload beam files which have changed
        ;;
esac
cd ${pwd}
