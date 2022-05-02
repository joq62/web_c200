%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : resource discovery accroding to OPT in Action 
%%% This service discovery is adapted to 
%%% Type = application 
%%% Instance ={ip_addr,{IP_addr,Port}}|{erlang_node,{ErlNode}}
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(web_server). 
 
-behaviour(gen_server). 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
-define(SERVER,?MODULE).


%% External exports
-export([

	 ping/0
	]).

-export([
	 websocket_init/1,
	 websocket_handle/1,
	 websocket_info/1
	]).

-export([
	 start/0,
	 stop/0
	]).


-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {
		pid,
		lamp_inglasad_status,
		lamps_indoor_status
	       }).

%% ====================================================================
%% External functions
%% ====================================================================


%% ====================================================================
%% Server functions
%% ====================================================================
%% Gen server functions

start()-> gen_server:start_link({local, ?SERVER}, ?SERVER, [], []).
stop()-> gen_server:call(?SERVER, {stop},infinity).

%% ====================================================================
%% Application handling
%% ====================================================================

%% ====================================================================
%% Support functions
%% ====================================================================

%% Websocket server functions

websocket_init(S)->
    gen_server:call(?SERVER, {websocket_init,S},infinity).
websocket_handle(Msg)->
    gen_server:call(?SERVER, {websocket_handle,Msg},infinity).
websocket_info(Msg)->
    gen_server:call(?SERVER, {websocket_info,Msg},infinity).

%% 
%% @doc:check if service is running
%% @param: non
%% @returns:{pong,node,module}|{badrpc,Reason}
%%
-spec ping()-> {atom(),node(),module()}|{atom(),term()}.
ping()-> 
    gen_server:call(?SERVER, {ping},infinity).


    
%% ====================================================================
%% Gen Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->

    
    {ok, #state{lamp_inglasad_status="Off",
		lamps_indoor_status="Off"}}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call({websocket_init,Pid},_From,State) ->
    {Reply,NewState}=format_text(init,State#state{pid=Pid}),
    {reply, Reply,NewState};


handle_call({websocket_handle,{text, <<"lamp_inglasad_on">>}},_From,State) ->
    io:format("lamp_inglasad_off_on  ~p~n",[{?MODULE,?LINE}]),
    NewState=State#state{lamp_inglasad_status="ON"},
    {Reply,NewState}=format_text(NewState),
    {reply, Reply, NewState};

handle_call({websocket_handle,{text, <<"lamp_inglasad_off">>}},_From,State) ->
    io:format("lamp_inglasad_off  ~p~n",[{?MODULE,?LINE}]),
    NewState=State#state{lamp_inglasad_status="OFF"},
    {Reply,NewState}=format_text(NewState),
    {reply, Reply, NewState};

handle_call({websocket_handle,{text, <<"lamps_indoor_on">>}},_From,State) ->
    io:format("lamps_indoor_on  ~p~n",[{?MODULE,?LINE}]),
    NewState=State#state{lamps_indoor_status="ON"},
    {Reply,NewState}=format_text(NewState),
    {reply, Reply, NewState};

handle_call({websocket_handle,{text, <<"lamps_indoor_off">>}},_From,State) ->
    io:format("lamps_indoor_off  ~p~n",[{?MODULE,?LINE}]),
    NewState=State#state{lamps_indoor_status="OFF"},
    {Reply,NewState}=format_text(NewState),
    {reply, Reply, NewState};




handle_call({ping},_From, State) ->
    Reply=pong,
    {reply, Reply, State};

handle_call({stopped},_From, State) ->
    Reply=ok,
    {reply, Reply, State}; 


handle_call({not_implemented},_From, State) ->
    Reply=not_implemented,
    {reply, Reply, State};

handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    io:format("unmatched signal  ~p~n",[{Request,?MODULE,?LINE}]),
    %rpc:cast(node(),log,log,[?Log_ticket("unmatched call",[Request, From])]),
    Reply = {ticket,"unmatched call",Request, From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------


handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{?MODULE,?LINE,Msg}]),
    {noreply, State}.
%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({gun_response,_X1,_X2,_X3,_X4,_X5}, State) ->
    {noreply, State};

handle_info({gun_up,_,_}, State) ->
    {noreply, State};

handle_info(Info, State) ->
    io:format("unmatched match info ~p~n",[{?MODULE,?LINE,Info}]),
    {noreply, State}.
%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
format_text(init,State)->
    format_text(State).


format_text(NewState)->
    Type=text,
    M=io_lib,
    F=format,
    StatusInglasad=NewState#state.lamp_inglasad_status,
    StatusLampsIndoor=NewState#state.lamps_indoor_status,

    A=["~s~s~s", [StatusLampsIndoor,",",StatusInglasad]],
    {{ok,Type,M,F,A},NewState}.
