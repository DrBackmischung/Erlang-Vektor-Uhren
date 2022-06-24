-module(worker).
-export([start/5, stop/1, peers/2]).

start(Name, Log, Seed, Sleep, Jitter) ->
  spawn_link(fun() -> init(Name, Log, Seed, Sleep, Jitter) end).

stop(Worker) ->
  Worker ! stop.

init(Name, Log, Seed, Sleep, Jitter) ->
  random:seed(Seed, Seed, Seed),
  receive
    {peers, Peers} ->
      loop(Name, Log, Peers, Sleep, Jitter, vect:zero());
    stop ->
      ok
  end.

peers(Wrk, Peers) ->
  Wrk ! {peers, Peers}.

loop(Name, Log, Peers, Sleep, Jitter, WorkerTime)->
  Wait = random:uniform(Sleep),
  receive
    {msg, Time, Msg} ->
      UpdatedWorkerTime = vect:inc(Name, vect:merge(WorkerTime, Time)),
      Log ! {log, Name, UpdatedWorkerTime, {received, Msg}},
      loop(Name, Log, Peers, Sleep, Jitter, UpdatedWorkerTime);
    stop ->
      ok;
    Error ->
      Log ! {log, Name, time, {error, Error}}
  after Wait ->
    Selected = select(Peers),
    UpdatedWorkerTime = vect:inc(Name, WorkerTime),
    Message = {hello, random:uniform(100)},
    Selected ! {msg, UpdatedWorkerTime, Message},
    jitter(Jitter),
    Log ! {log, Name, UpdatedWorkerTime, {sending, Message}},
    loop(Name, Log, Peers, Sleep, Jitter, UpdatedWorkerTime)
  end.

select(Peers) ->
  lists:nth(random:uniform(length(Peers)), Peers).

jitter(0) -> ok;
jitter(Jitter) -> timer:sleep(random:uniform(Jitter)).
