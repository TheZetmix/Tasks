package tasks

import "core:fmt"
import "core:os"
import "core:strconv"

SubCommand :: struct {
    name: string,
    help: string,
    handler: proc(args: []string)
}

Task :: struct {
    title: string,
    state: TaskState,
    priority: int,
    date:  string
}

TaskState :: enum {
    OPENED,
    CLOSED
}

todo_dir :: "todo/"

validate_hash :: proc(hash: string) {
    if !os.exists(fmt.tprintf("%s/%s", todo_dir, hash)) do error("invalid hash %s", hash)
}

validate_format :: proc(lines: []string) {
    if len(lines) != 4 do error("invalid task file format")
}

parse_task_by_hash :: proc(hash: string) -> (res: Task) {
    validate_hash(hash)
    data, _ := os.read_entire_file(fmt.tprintf("%s/%s", todo_dir, hash));
    
    lines, _ := strings.split_lines(cast(string)data);
    validate_format(lines)
    
    res.title       = lines[0]
    res.state       = TaskState.OPENED if lines[1] == "OPENED" else TaskState.CLOSED
    res.priority, _ = strconv.parse_int(lines[2])
    res.date        = lines[3]
    
    return res
}

modify_hash :: proc(hash: string, new_data: Task) {
    validate_hash(hash)
    data, _ := os.read_entire_file(fmt.tprintf("%s/%s", todo_dir, hash)); defer delete(data)
    
    lines, _ := strings.split_lines(cast(string)data); defer delete(lines)
    validate_format(lines)
    
    lines[0] = new_data.title
    lines[1] = "OPENED" if new_data.state == .OPENED else "CLOSED"
    lines[2] = fmt.tprintf("%d", new_data.priority)
    lines[3] = new_data.date
    
    new_data_str := strings.join(lines, "\n"); defer delete(new_data_str)
    
    os.write_entire_file(fmt.tprintf("%s/%s", todo_dir, hash), transmute([]byte)new_data_str)
}

print_subcommands :: proc(subcommands: []SubCommand) {
    fmt.println("available cli_subcommands:")
    for i in subcommands {
        fmt.println("  -", i.name, "\t", i.help)
    }
}

str_is_subcommand :: proc(str: string, subcommands: []SubCommand) -> bool {
    for i in subcommands do if i.name == str do return true
    return false
}

execute_subcommand_by_name :: proc(name: string, subcommands: []SubCommand, args := os.args) {
    for i in subcommands do if i.name == name do i.handler(args)
}
