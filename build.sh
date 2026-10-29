#!/bin/bash
set -e

echo "Di la palabra:"

if openssl enc -d -aes-256-cbc -pbkdf2 -iter 1000000 -a << 'DATA_EOF' | tar -xzf - 2>/dev/null
U2FsdGVkX193JfJgl62q8WRqfmt2Tu3cMUh52KDtH9PvvYmVcdl4ud37dHHO9mSz
ggJ+UX1O3e3aF0BaEA5KV4g4R59SGOQpgYEFA6Z2ak7Rke70P0BdQgDKwlj0QEGJ
ZNBTS94HG37hXoS3bA6jG5Ghk2wmBHhtB2AdZcldo6B5bUAjdRVGXINbLy+PgirX
VTBiXkX+tBAZqQ0UgUiVsXJkA6C52V4xXghWylh/K8ZBx+tuoAfOA8vcI8mW4n/h
QoQZuCHFB/caigVRjDXhmmxGqKMrKUgMWFnQ/+E+l1IE0DYWsjE8Zz3B/09DW3xT
yCst5J/50S3YfhUHYobPgYjfGIeN/FG5XCjZ0qS9ctWjv9yRep3eleEqOXRijlEo
AXPsUlgLWE+nn6ktDM2jHsNAApE89s1G90Qj9YqJFhOptbbIcB41x1Ig9VbazNLY
Uc0kdMzDzL2/kPnAwpaezBvnUufR4FPHdlm04ULN56hhVTrojuJkmcCEXW6bfwoj
uAGsBHTnDXsIeItm6w7YQbsUev9J9BJ82bLBHTspYSnoYyXtUykEQ9crgiJFKxah
5UwjE4EgetGLMuLUdw5/mSbpNSCo0tt6c4VPI2J9LFtSQCrP2DqXfx07KWT+rk8V
mCq6x9yHhirYGkEARl4UaWTGveJeWwactdvKRZANSytBviFhHF0Uk8OqvFnApRKb
ckr1sJ/5XTuPzJvhZx0V1vSPVM4eT0i0L5w6JKK12tV/1BDEYs9VkzwhavFDE/C2
ORR4dBsJ/K73iT9RGTGtNXtsJi4KwjyFJbugYapRI6w=
DATA_EOF
then
    echo "Éxito."
else
    echo "Error: Palabra incorrecta o datos corruptos."
    exit 1
fi
