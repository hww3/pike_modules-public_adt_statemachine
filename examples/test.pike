object s;

int main()
{
  s=Public.ADT.StateMachine.StateMachine("beginning");
  s->set_transition("blah", "beginning", lambda(mixed ... 
a){write("%O: %O\n", s, a);}, "state1");
  s->set_transition("blah2", "state1", lambda(mixed ... a){write("%O: %O\n", 
s, a);}, "state2");
  s->set_transition("blah1", "state1", lambda(mixed ... a){write("%O: %O\n", 
s, a);}, "end");

  // valid state progression
  s->process("blah", "1");
  s->process("blah1", "2");
  write(s->get_current_state() + "\n");

  s->reset();
  // invalid state progression
  s->process("blah", "1");
  s->process("blah", "2");

  return 1;
}
