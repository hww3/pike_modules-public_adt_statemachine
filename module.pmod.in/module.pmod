//! A module implimenting state machines and other automata.

//!
constant __version = "1.2";
constant __author  = "Bill Welliver <bill@welliver.org>";

//! A simple deterministic finite state machine (FSM)
class StateMachine {

private mapping deterministic_transitions=([]);
private mapping transitions=([]);

private string default_new_state;
private function default_action;

private string current_state;
private string begin_state;

//! create a new Finite State Machine with the initial state _begin_state.
void create(string _begin_state)
{
  begin_state=_begin_state;
  current_state=begin_state;
}

//! reset the current state to the beginning state.
void reset()
{
  current_state=begin_state;
}

//! clear all definied transitions, not including the default.
void clear_transitions()
{
  deterministic_transitions=([]);
  transitions=([]);
}

//! set a transition where the current state is considered when 
//! determining if a transition is available.
//! 
//! @param symbol
//!   the input symbol
//! @param state
//!   the state for which this transition will be effective.
//! @param action
//!   an optional function that will be called before making the state 
//!   transition. this function will take one or more arguments: the symbol 
//!   passed, as well as an arbitrary number of additional aguments.
//! @param new_state
//!   the new state the machine will be in after the transition.
void set_transition(string symbol, string state, 
  function|void action, string new_state)
{
  if(!deterministic_transitions[state])
    deterministic_transitions[state]=([]);

  deterministic_transitions[state][symbol]=({action, new_state});


}

//! set a transition available from any state 
//! 
//! @param symbol
//!   the input symbol
//! @param action
//!   an optional function that will be called before making the state 
//!   transition. this function will take one or more arguments: the symbol 
//!   passed, as well as an arbitrary number of additional aguments.
//! @param new_state
//!   the new state the machine will be in after the transition.
void set_transition_any(string symbol, function|void action, string 
new_state)
{

  deterministic_transitions[symbol]=({action, new_state});

}

//! get a transition for a given state transition
//!  
//! this function uses the following algorithm to select a transition:
//!
//! 1. Check to see if a state is defined for (symbol, state).
//!
//! 2. Check to see if a state is defined for (symbol).
//!
//! 3. Check to see if a default transition is defined.
//!
//! 4. Throw an error indicating a transition is not defined.
//!
//! @returns
//!   an array consisting of the action (if any), and the new state.
array get_transition(string symbol, string state)
{
  if(deterministic_transitions[state] && deterministic_transitions[state][symbol])
    return deterministic_transitions[state][symbol];
  else if(transitions[symbol])
    return transitions[symbol];
  else if(default_action && default_new_state)
    return ({ default_action, default_new_state });
  else error(sprintf("Transition undefined: (%s, %s)\n", symbol, state));
}

//! set the default transition.
//!  
//! useful for catching exceptions when a transition is not defined
//! for a given state.
void set_default_transition(function|void action, string new_state)
{
  default_action=action;
  default_new_state=new_state;
}

//!  returns the current state of the State Machine.
string get_current_state()
{
  return current_state;
}

//! process a state change, given the symbol symbol.
//!
//! this method will use the algorithm described in @[get_transition()]
//! to determine the appropriate transition to use. if an action is 
//! defined for the chosen transition, it will be called.
//!
//! symbol and args will be passed to the action function. 
//! state will then be advanced to the next state defined in the 
//! transition.
mixed process(string symbol, mixed ... args)
{
  string s;
  function f;
  mixed r;

  [f, s] = get_transition(symbol, current_state);

  if(f)
    r=f(symbol, @args);
  current_state=s;
  return r;
}

string _sprintf()
{
  return "StateMachine(" + current_state + ")";
}
}
