-module(test2).
-export([run/2]).

run(Sleep, Jitter) ->
  Log = log:start([john, paul, ringo, george, mathis]),
  A = worker:start(john, Log, 13, Sleep, Jitter),
  B = worker:start(paul, Log, 23, Sleep, Jitter),
  C = worker:start(ringo, Log, 36, Sleep, Jitter),
  D = worker:start(george, Log, 49, Sleep, Jitter),
  E = worker:start(mathis, Log, 56, Sleep, Jitter),
  worker:peers(A, [B, C, D, E]),
  worker:peers(B, [A, C, D, E]),
  worker:peers(C, [A, B, D, E]),
  worker:peers(D, [A, B, C, E]),
  worker:peers(E, [A, B, C, D]),
  timer:sleep(5000),
  log:stop(Log),
  worker:stop(A),
  worker:stop(B),
  worker:stop(C),
  worker:stop(D),
  worker:stop(E).
