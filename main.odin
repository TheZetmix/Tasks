package tasks

import "core:os"

main :: proc() {
    if len(os.args) == 1 {
        print_subcommands(cli_subcommands)
        error("first argument must be a subcommand")
    }
    
    if len(os.args) == 2 && !str_is_subcommand(os.args[1], cli_subcommands) {
        print_subcommands(cli_subcommands)
        error("unknown subcommand %s", os.args[1])
    }
    
    os.make_directory(todo_dir)
    
    // if the provided sumcommand is in the list, call its handler
    execute_subcommand_by_name(os.args[1], cli_subcommands)
}
