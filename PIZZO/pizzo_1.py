def get_data():
    rejected = []
    accept = []
    n, m = input().split()
    for i in range(int(n)):
        word = input()
        if word[0] == '-':
            rejected.append(word[1:])
        else:
            accept.append(word[1:])
    return n, m, rejected, accept

class Node:
    def __init__(self, acceptance = None):
        self.acceptance = acceptance
        self.outputs = {'a': None, 'b': None, 'c': None}

def add_to_Trie(word, Trie: Node, acceptance):
    if len(word) != 0:
        if Trie.outputs[word[0]] is None:
            new_state = Node()
            if len(word) == 1:
                new_state.acceptance = acceptance
            Trie.outputs[word[0]] = new_state
        add_to_Trie(word[1:], Trie.outputs[word[0]], acceptance)
    else:
        return

def gen_state_name():
    n = 0
    def name():
        nonlocal n
        n += 1
        return f"q{n}"
    return name

def build_automaton_dict(trie):
    state_name_generator = gen_state_name()
    state_names = {}
    transitions = []
    accepting_states = []

    def traverse(node):
        if node is None:
            return

        if node not in state_names and node is not None:
            state_names[node] = state_name_generator()
        current_state = state_names[node]

        if node.acceptance == 1:
            accepting_states.append(current_state)

        for letter, child in node.outputs.items():
            if child is None:
                continue
            else:
                if child not in state_names:
                    state_names[child] = state_name_generator()
                to_state = state_names[child]
                transitions.append({"letter": letter, "from": current_state, "to": to_state})
                node.outputs[letter] = None
                traverse(child)

    initial_state = state_name_generator()
    state_names[trie] = initial_state
    traverse(trie)

    automaton_dict = {
        "alphabet": ["a", "b", "c"],
        "states": list(state_names.values()),
        "initial": initial_state,
        "accepting": accepting_states,
        "transitions": transitions
    }

    return automaton_dict

def minify_matrix(Trip_dict):
    T = {}
    states = Trip_dict["states"]
    accept = Trip_dict["accepting"]
    alphabet = Trip_dict["alphabet"]

    def sigma(state, letter):
        for transition in Trip_dict["transitions"]:
            if transition["letter"] == letter and transition["from"] == state:
                return transition["to"]


    for i_1, state_1 in enumerate(states):
        for i_2, state_2 in enumerate(states):
            if i_1 < i_2:
                T[(state_1, state_2)] = True

    for key, val in T.items():
        state_1, state_2 = key
        if (state_1 in accept and state_2 not in accept) or (state_2 in accept and state_1 not in accept):
            T[key] = False
    flag = True
    while flag:
        T_copy = T.copy()
        for key, val in T.items():
            for letter in alphabet:
                sigma_key = (sigma(key[0], letter), sigma(key[1], letter))
                if sigma_key not in T:
                    sigma_key = (sigma_key[1], sigma_key[0])
                if sigma_key in T and not T[sigma_key]:
                    T[key] = False

        if T_copy == T:
            flag = False

    return T

def merge_states(automata, T):
    transitions = automata["transitions"]
    accepting = automata["accepting"]
    states = automata["states"]
    initial = automata["initial"]
    for key, value in T.items(): ## usuwam state_2
        if value:
            state_1, state_2 = key
            for transition in transitions:
                if transition["from"] == state_2:
                    transition["from"] = state_1
                if transition["to"] == state_2:
                    transition["to"] = state_1
            automata["transitions"] = transitions
            if state_2 in initial:
                automata["initial"].remove(state_2)
                automata["initial"].append(state_1)

            if state_2 in states:
                states.remove(state_2)
            if state_2 in accepting:
                accepting.remove(state_2)

    unique_list = []
    for transition in automata["transitions"]:
        if transition not in unique_list:
            unique_list.append(transition)

    automata["transitions"] = unique_list

    return automata


def add_nonexist_transitions(trash_state: Node, Trie):
    if Trie is None:
        return
    add_nonexist_transitions(trash_state, Trie.outputs['a'])
    add_nonexist_transitions(trash_state, Trie.outputs['b'])
    add_nonexist_transitions(trash_state, Trie.outputs['c'])
    for letter, state in Trie.outputs.items():
        if state is None:
            Trie.outputs[letter] = trash_state


n, m, rejected, accept = get_data()

Trie = Node()
for word in accept:
    add_to_Trie(word, Trie, 1)

trash_state = Node(acceptance=0)
trash_state.outputs['a'] = trash_state
trash_state.outputs['b'] = trash_state
trash_state.outputs['c'] = trash_state

trash_state.outputs.items()
add_nonexist_transitions(trash_state, Trie)
automaton = build_automaton_dict(Trie)
T = minify_matrix(automaton)
print(merge_states(automaton, T))
